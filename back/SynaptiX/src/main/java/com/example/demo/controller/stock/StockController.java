// StockController.java
package com.example.demo.controller.stock;

import com.example.demo.model.MaterialDTO;
import com.example.demo.model.PageResult;
import com.example.demo.model.ProductDTO;
import com.example.demo.service.stock.StockService;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;


@Controller
public class StockController {
    private final StockService service;
    public StockController(StockService service) {
        this.service = service;
    }
    
    
    
    @GetMapping("/stock")
    public String showStockList(
            @RequestParam(value = "code", required = false) String code,
            @RequestParam(value = "name", required = false) String name,
            @RequestParam(value = "model", required = false) String model,
            @RequestParam(value = "category", required = false) String category,
            @RequestParam(value = "page", required = false, defaultValue = "0") int page,
            @RequestParam(value = "size", required = false, defaultValue = "15") int size,
            Model mv
    ) {
        PageResult<com.example.demo.model.MaterialDTO> materialPage = service.getPagedMaterials(page, size);
        mv.addAttribute("materials", materialPage.getContent());
        mv.addAttribute("totalCount", materialPage.getTotalCount());
        mv.addAttribute("page", materialPage.getPage());
        mv.addAttribute("size", materialPage.getSize());
        return "stock/MaterialStockList";
    }

    // 수정 폼 이동
    @GetMapping("/stock/edit")
    public String showEditForm(@RequestParam("pk") int pk,
                               @RequestParam("category") String cat,
                               Model mv) {
        if ("원자재".equals(cat)) {
            mv.addAttribute("material", service.getMaterialByPk(pk));
            mv.addAttribute("product", null);
        } else if ("제품".equals(cat)) {
            mv.addAttribute("product", service.getProductByPk(pk));
            mv.addAttribute("material", null);
        } else {
            mv.addAttribute("material", null);
            mv.addAttribute("product", null);
        }
        return "stock/StockEdit";
    }

    @PostMapping("/stock/editMaterial")
    public String editMaterial(@ModelAttribute MaterialDTO material) {
        service.updateMaterial(material);
        return "redirect:/stock";
    }

    @PostMapping("/stock/editProduct")
    public String editProduct(@ModelAttribute ProductDTO product) {
        service.updateProduct(product);
        return "redirect:/stock";
    }

    @PostMapping("/stock/delete")
    public String deleteStock(@RequestParam("pk") int pk,
                              @RequestParam("category") String cat) {
        if ("원자재".equals(cat)) service.deleteMaterial(pk);
        else if ("제품".equals(cat)) service.deleteProduct(pk);
        return "redirect:/stock";
    }

    @PostMapping("/stock/search")
    public String searchStock(
        @RequestParam(value = "code", required = false) String code,
        @RequestParam(value = "name", required = false) String name,
        @RequestParam(value = "model", required = false) String model,
        @RequestParam(value = "category", required = false) String category,
        @RequestParam(value = "searchName", required = false) String searchName,
        Model mv
    ) {
        code = (code != null && !code.isBlank()) ? code : null;
        String searchKey = (searchName != null && !searchName.isBlank()) ? searchName : (name != null && !name.isBlank() ? name : null);
        model = (model != null && !model.isBlank()) ? model : null;
        category = (category != null && !category.isBlank() && !"전체".equals(category)) ? category : null;
        List<MaterialDTO> materials = service.searchMaterials(code, searchKey, model, "원자재".equals(category) ? "원자재" : null);
        List<ProductDTO> products = service.searchProducts(code, searchKey, model, "제품".equals(category) ? "제품" : null);
        mv.addAttribute("materials", materials);
        mv.addAttribute("products", products);
        return "stock/StockSearchResult";
    }

    @GetMapping("/stock/search/material")
    public String searchMaterialStock(
        @RequestParam(value = "code", required = false) String code,
        @RequestParam(value = "name", required = false) String name,
        @RequestParam(value = "model", required = false) String model,
        @RequestParam(value = "specification", required = false) String specification,
        @RequestParam(value = "unit", required = false) String unit,
        @RequestParam(value = "searchName", required = false) String searchName,
        Model mv
    ) {
        code = (code != null && !code.isBlank()) ? code : null;
        String searchKey = (searchName != null && !searchName.isBlank()) ? searchName : (name != null && !name.isBlank() ? name : null);
        model = (model != null && !model.isBlank()) ? model : null;
        specification = (specification != null && !specification.isBlank()) ? specification : null;
        unit = (unit != null && !unit.isBlank()) ? unit : null;
        // category는 "원자재"로 고정
        List<MaterialDTO> materials = service.searchMaterials(code, searchKey, model, "원자재");
        mv.addAttribute("materials", materials);
        mv.addAttribute("products", List.of());
        return "stock/StockSearchResult";
    }

    @PostMapping("/stock/register")
    @ResponseBody
    public java.util.Map<String, Object> registerStock(
        @RequestParam("category") String category,
        @RequestParam("name") String name,
        @RequestParam(value = "model", required = false) String model,
        @RequestParam(value = "specification", required = false) String specification,
        @RequestParam(value = "unit", required = false) String unit,
        @RequestParam("price") int price,
        @RequestParam("stock") float stock,
        @RequestParam("amount") float amount
    ) {
        java.util.Map<String, Object> result = new java.util.HashMap<>();
        try {
            if ("원자재".equals(category)) {
                com.example.demo.model.MaterialDTO dto = new com.example.demo.model.MaterialDTO();
                dto.setCategory("원자재");
                dto.setName(name);
                dto.setSpecification(specification);
                dto.setUnit(unit);
                dto.setPrice(price);
                dto.setStock(stock);
                dto.setAmount(amount);
                service.insertMaterial(dto);
            } else if ("제품".equals(category)) {
                com.example.demo.model.ProductDTO dto = new com.example.demo.model.ProductDTO();
                dto.setCategory("제품");
                dto.setName(name);
                dto.setModel(model);
                dto.setSpecification(specification);
                dto.setPrice(price);
                dto.setStock(stock);
                dto.setAmount(amount);
                service.insertProduct(dto);
            } else {
                throw new IllegalArgumentException("카테고리 오류");
            }
            result.put("success", true);
        } catch (Exception e) {
            result.put("success", false);
            // 권한 문제일 경우 메시지 명시
            if (e instanceof org.springframework.security.access.AccessDeniedException) {
                result.put("message", "권한이 없습니다. 관리자에게 문의하세요.");
            } else {
                result.put("message", e.getMessage());
            }
        }
        return result;
    }

    @PostMapping("/stock/edit")
    public String editStock(
        @RequestParam("category") String category,
        @ModelAttribute MaterialDTO material,
        @ModelAttribute ProductDTO product
    ) {
        if ("원자재".equals(category)) {
            service.updateMaterial(material);
        } else if ("제품".equals(category)) {
            service.updateProduct(product);
        }
        return "redirect:/stock";
    }

    @GetMapping("/stock/excel")
    public void downloadExcel(HttpServletResponse response) throws IOException {
        List<MaterialDTO> materials = service.getAllMaterials();
        List<ProductDTO> products = service.getAllProducts();
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("재고목록");
        int rowIdx = 0;
        Row header = sheet.createRow(rowIdx++);
        String[] headers = {"구분", "품목코드", "품목명", "카테고리", "모델명", "규격", "단위", "단가", "재고수량", "재고금액"};
        for (int i = 0; i < headers.length; i++) header.createCell(i).setCellValue(headers[i]);
        for (MaterialDTO m : materials) {
            Row row = sheet.createRow(rowIdx++);
            row.createCell(0).setCellValue("원자재");
            row.createCell(1).setCellValue("mtr2025" + (m.getPk() < 10 ? "0" + m.getPk() : m.getPk()));
            row.createCell(2).setCellValue(m.getName());
            row.createCell(3).setCellValue(m.getCategory());
            row.createCell(4).setCellValue("");
            row.createCell(5).setCellValue(m.getSpecification());
            row.createCell(6).setCellValue(m.getUnit());
            row.createCell(7).setCellValue(m.getPrice());
            row.createCell(8).setCellValue(m.getStock());
            row.createCell(9).setCellValue(m.getAmount());
        }
        for (ProductDTO p : products) {
            Row row = sheet.createRow(rowIdx++);
            row.createCell(0).setCellValue("제품");
            row.createCell(1).setCellValue("prod2025" + (p.getPk() < 10 ? "0" + p.getPk() : p.getPk()));
            row.createCell(2).setCellValue(p.getName());
            row.createCell(3).setCellValue(p.getCategory());
            row.createCell(4).setCellValue(p.getModel());
            row.createCell(5).setCellValue(p.getSpecification());
            row.createCell(6).setCellValue("");
            row.createCell(7).setCellValue(p.getPrice());
            row.createCell(8).setCellValue(p.getStock());
            row.createCell(9).setCellValue(p.getAmount());
        }
        for (int i = 0; i < headers.length; i++) sheet.autoSizeColumn(i);
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=stock_list.xlsx");
        workbook.write(response.getOutputStream());
        workbook.close();
    }

    @GetMapping("/stock/excel-modal")
    public void downloadExcelFromModal(
            @RequestParam(value = "code", required = false) String code,
            @RequestParam(value = "name", required = false) String name,
            @RequestParam(value = "model", required = false) String model,
            @RequestParam(value = "category", required = false) String category,
            @RequestParam(value = "searchName", required = false) String searchName,
            HttpServletResponse response
    ) throws IOException {
        // 검색 조건에 따라 데이터 조회
        List<MaterialDTO> materials = service.searchMaterials(code, name, model, category);
        List<ProductDTO> products = service.searchProducts(code, name, model, category);
        // 엑셀 생성 및 응답
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=검색결과.xlsx");
        service.writeExcel(materials, products, response.getOutputStream());
    }

    // 원자재 재고관리 페이지
    @GetMapping("/stock/material")
    public String showMaterialStockList(
            @RequestParam(value = "code", required = false) String code,
            @RequestParam(value = "name", required = false) String name,
            @RequestParam(value = "specification", required = false) String specification,
            @RequestParam(value = "unit", required = false) String unit,
            @RequestParam(value = "page", required = false, defaultValue = "0") int page,
            @RequestParam(value = "size", required = false, defaultValue = "15") int size,
            Model mv
    ) {
        PageResult<MaterialDTO> materialPage = service.getPagedMaterials(page, size);
        mv.addAttribute("materials", materialPage.getContent());
        mv.addAttribute("totalCount", materialPage.getTotalCount());
        mv.addAttribute("page", materialPage.getPage());
        mv.addAttribute("size", materialPage.getSize());
        mv.addAttribute("q_code", code);
        mv.addAttribute("q_name", name);
        mv.addAttribute("q_specification", specification);
        mv.addAttribute("q_unit", unit);
        mv.addAttribute("active_stock", "active");
        return "stock/MaterialStockList";
    }

    // 제품 재고관리 페이지
    @GetMapping("/stock/product")
    public String showProductStockList(
            @RequestParam(value = "code", required = false) String code,
            @RequestParam(value = "name", required = false) String name,
            @RequestParam(value = "model", required = false) String model,
            @RequestParam(value = "specification", required = false) String specification,
            @RequestParam(value = "page", required = false, defaultValue = "0") int page,
            @RequestParam(value = "size", required = false, defaultValue = "15") int size,
            Model mv
    ) {
        PageResult<ProductDTO> productPage = service.getPagedProducts(page, size);
        mv.addAttribute("products", productPage.getContent());
        mv.addAttribute("totalCount", productPage.getTotalCount());
        mv.addAttribute("page", productPage.getPage());
        mv.addAttribute("size", productPage.getSize());
        mv.addAttribute("q_code", code);
        mv.addAttribute("q_name", name);
        mv.addAttribute("q_model", model);
        mv.addAttribute("q_specification", specification);
        mv.addAttribute("active_stock", "active");
        return "stock/ProductStockList";
    }

    // 제품 Ajax 검색 결과 반환
    @GetMapping("/stock/search/product")
    public String searchProductStock(
        @RequestParam(value = "code", required = false) String code,
        @RequestParam(value = "name", required = false) String name,
        @RequestParam(value = "model", required = false) String model,
        @RequestParam(value = "specification", required = false) String specification,
        Model mv
    ) {
        code = (code != null && !code.isBlank()) ? code : null;
        name = (name != null && !name.isBlank()) ? name : null;
        model = (model != null && !model.isBlank()) ? model : null;
        specification = (specification != null && !specification.isBlank()) ? specification : null;
        // category는 "제품"으로 고정
        List<ProductDTO> products = service.searchProducts(code, name, model, "제품");
        mv.addAttribute("products", products);
        mv.addAttribute("materials", List.of());
        return "stock/ProductSearchResult";
    }

    // 제품 등록 Ajax
    @PostMapping("/stock/register/product")
    @ResponseBody
    public java.util.Map<String, Object> registerProduct(
        @RequestParam("name") String name,
        @RequestParam(value = "model", required = false) String model,
        @RequestParam(value = "specification", required = false) String specification,
        @RequestParam("price") int price,
        @RequestParam("stock") float stock,
        @RequestParam("amount") float amount
    ) {
        java.util.Map<String, Object> result = new java.util.HashMap<>();
        try {
            ProductDTO dto = new ProductDTO();
            dto.setCategory("제품");
            dto.setName(name);
            dto.setModel(model);
            dto.setSpecification(specification);
            dto.setPrice(price);
            dto.setStock(stock);
            dto.setAmount(amount);
            service.insertProduct(dto);
            result.put("success", true);
        } catch (Exception e) {
            result.put("success", false);
            if (e instanceof org.springframework.security.access.AccessDeniedException) {
                result.put("message", "권한이 없습니다. 관리자에게 문의하세요.");
            } else {
                result.put("message", e.getMessage());
            }
        }
        return result;
    }

    // 제품 수정
    @PostMapping("/stock/edit/product")
    public String editProductDirect(@ModelAttribute ProductDTO product) {
        service.updateProduct(product);
        return "redirect:/stock/product";
    }

    // 제품 삭제
    @PostMapping("/stock/delete/product")
    @ResponseBody
    public java.util.Map<String, Object> deleteProduct(@RequestParam("pk") int pk) {
        java.util.Map<String, Object> result = new java.util.HashMap<>();
        try {
            service.deleteProduct(pk);
            result.put("success", true);
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", e.getMessage());
        }
        return result;
    }

    // 제품 검색결과 엑셀 다운로드
    @GetMapping("/stock/excel-modal/product")
    public void downloadProductExcelFromModal(
            @RequestParam(value = "code", required = false) String code,
            @RequestParam(value = "name", required = false) String name,
            @RequestParam(value = "model", required = false) String model,
            @RequestParam(value = "specification", required = false) String specification,
            HttpServletResponse response
    ) throws IOException {
        List<ProductDTO> products = service.searchProducts(code, name, model, "제품");
        // 엑셀 생성 및 응답
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=product_Result.xlsx");
        service.writeProductExcel(products, response.getOutputStream());
    }

    // 원자재 검색결과 엑셀 다운로드
    @GetMapping("/stock/excel-modal/material")
    public void downloadMaterialExcelFromModal(
            @RequestParam(value = "code", required = false) String code,
            @RequestParam(value = "name", required = false) String name,
            @RequestParam(value = "specification", required = false) String specification,
            @RequestParam(value = "unit", required = false) String unit,
            @RequestParam(value = "searchName", required = false) String searchName,
            HttpServletResponse response
    ) throws IOException {
        // 검색 조건에 따라 데이터 조회
        List<MaterialDTO> materials = service.searchMaterials(code, name, null, "원자재");
        // 엑셀 생성 및 응답
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=material_Result.xlsx");
        service.writeMaterialExcel(materials, response.getOutputStream());
    }

    // 원자재만 엑셀 다운로드
    @GetMapping("/stock/excel/material")
    public void downloadMaterialExcel(HttpServletResponse response) throws IOException {
        List<MaterialDTO> materials = service.getAllMaterials();
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("원자재목록");
        int rowIdx = 0;
        Row header = sheet.createRow(rowIdx++);
        String[] headers = {"품목코드", "품목명", "카테고리", "규격", "단위", "단가", "재고수량", "재고금액"};
        for (int i = 0; i < headers.length; i++) header.createCell(i).setCellValue(headers[i]);
        for (MaterialDTO m : materials) {
            Row row = sheet.createRow(rowIdx++);
            row.createCell(0).setCellValue("mtr2025" + (m.getPk() < 10 ? "0" + m.getPk() : m.getPk()));
            row.createCell(1).setCellValue(m.getName());
            row.createCell(2).setCellValue(m.getCategory());
            row.createCell(3).setCellValue(m.getSpecification());
            row.createCell(4).setCellValue(m.getUnit());
            row.createCell(5).setCellValue(m.getPrice());
            row.createCell(6).setCellValue(m.getStock());
            row.createCell(7).setCellValue(m.getAmount());
        }
        for (int i = 0; i < headers.length; i++) sheet.autoSizeColumn(i);
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=material_list.xlsx");
        workbook.write(response.getOutputStream());
        workbook.close();
    }

    // 제품만 엑셀 다운로드
    @GetMapping("/stock/excel/product")
    public void downloadProductExcel(HttpServletResponse response) throws IOException {
        List<ProductDTO> products = service.getAllProducts();
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("제품목록");
        int rowIdx = 0;
        Row header = sheet.createRow(rowIdx++);
        String[] headers = {"품목코드", "제품명", "카테고리", "모델명", "규격", "단가", "재고수량", "재고금액"};
        for (int i = 0; i < headers.length; i++) header.createCell(i).setCellValue(headers[i]);
        for (ProductDTO p : products) {
            Row row = sheet.createRow(rowIdx++);
            row.createCell(0).setCellValue("prd2025" + (p.getPk() < 10 ? "0" + p.getPk() : p.getPk()));
            row.createCell(1).setCellValue(p.getName());
            row.createCell(2).setCellValue(p.getCategory());
            row.createCell(3).setCellValue(p.getModel());
            row.createCell(4).setCellValue(p.getSpecification());
            row.createCell(5).setCellValue(p.getPrice());
            row.createCell(6).setCellValue(p.getStock());
            row.createCell(7).setCellValue(p.getAmount());
        }
        for (int i = 0; i < headers.length; i++) sheet.autoSizeColumn(i);
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=product_list.xlsx");
        workbook.write(response.getOutputStream());
        workbook.close();
    }
}