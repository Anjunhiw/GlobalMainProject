package com.example.demo.controller.product;

import com.example.demo.model.BOMDTO;
import com.example.demo.model.ProductDTO;
import com.example.demo.model.MaterialDTO;
import com.example.demo.service.product.BOMService;
import com.example.demo.service.stock.StockService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@Controller
@RequestMapping("/bom")
public class BOMController {
    @Autowired
    private BOMService bomService;

    @Autowired
    private StockService stockService;

    @GetMapping("")
    public String showBOM(@RequestParam(value = "category", required = false) String category,
                         @RequestParam(value = "name", required = false) String name,
                         @RequestParam(value = "id", required = false) String id,
                         Model model) {
        List<BOMDTO> bomList;
        if ((category != null && !category.isEmpty()) || (id != null && !id.isEmpty())) {
            bomList = bomService.getFilteredBOMWithNames(category, id);
        } else {
            bomList = bomService.getAllBOMWithNames();
        }
        List<ProductDTO> productList = stockService.getAllProducts();
        List<MaterialDTO> materialList = stockService.getAllMaterials();
        model.addAttribute("bomList", bomList);
        model.addAttribute("productList", productList);
        model.addAttribute("materialList", materialList);
        return "product/bom";
    }

    @PostMapping
    public void addBOM(@RequestBody BOMDTO bomDTO) {
        bomService.addBOM(bomDTO);
    }

    @PutMapping("")
    @ResponseBody
    public java.util.Map<String, Object> updateBOM(@RequestBody BOMDTO bomDTO) {
        bomService.updateBOM(bomDTO);
        java.util.Map<String, Object> result = new java.util.HashMap<>();
        result.put("success", true);
        return result;
    }

    @PostMapping("/search")
    public String searchBOM(@RequestBody java.util.Map<String, String> params, Model model) {
        String code = params.getOrDefault("code", null);
        String name = params.getOrDefault("name", null);
        // 카테고리는 입력만 받고 실제 검색 조건에는 반영하지 않음
        String modelCode = params.getOrDefault("model", null);
        String materialName = params.getOrDefault("materialName", null);
        List<BOMDTO> bomList = bomService.searchBOM(code, name, null, modelCode, materialName);
        List<ProductDTO> productList = stockService.getAllProducts();
        List<MaterialDTO> materialList = stockService.getAllMaterials();
        model.addAttribute("bomList", bomList);
        model.addAttribute("productList", productList);
        model.addAttribute("materialList", materialList);
        return "fragments/bom_search_result";
    }

    @PostMapping("/register")
    @ResponseBody
    public java.util.Map<String, Object> registerBOM(@RequestBody BOMDTO bomDTO) {
        bomService.addBOM(bomDTO);
        java.util.Map<String, Object> result = new java.util.HashMap<>();
        result.put("success", true);
        return result;
    }

    @GetMapping("/excel")
    public void downloadBomExcel(HttpServletResponse response) throws IOException {
        List<BOMDTO> bomList = bomService.getAllBOMWithNames();
        List<MaterialDTO> materialList = stockService.getAllMaterials();
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("BOM목록");
        int rowIdx = 0;
        Row header = sheet.createRow(rowIdx++);
        String[] headers = {"제품코드", "생산제품명", "소요원자재명", "소요원자재량", "소요금액"};
        for (int i = 0; i < headers.length; i++) header.createCell(i).setCellValue(headers[i]);
        for (BOMDTO bom : bomList) {
            int price = 0;
            for (MaterialDTO mat : materialList) {
                if (mat.getPk() == bom.getMaterialId()) {
                    price = mat.getPrice();
                    break;
                }
            }
            Row row = sheet.createRow(rowIdx++);
            row.createCell(0).setCellValue("prod2025" + (bom.getProductId() < 10 ? "0" + bom.getProductId() : bom.getProductId()));
            row.createCell(1).setCellValue(bom.getProductName());
            row.createCell(2).setCellValue(bom.getMaterialName());
            row.createCell(3).setCellValue(bom.getMaterialAmount());
            row.createCell(4).setCellValue(bom.getMaterialAmount() * price);
        }
        for (int i = 0; i < headers.length; i++) sheet.autoSizeColumn(i);
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=BOM목록.xlsx");
        workbook.write(response.getOutputStream());
        workbook.close();
    }

    @GetMapping("/excel-modal")
    public void downloadBomExcelModal(@RequestParam(required = false) String code,
                                      @RequestParam(required = false) String name,
                                      @RequestParam(required = false) String category,
                                      @RequestParam(required = false) String model,
                                      @RequestParam(required = false) String materialName,
                                      HttpServletResponse response) throws IOException {
        // 검색 조건에 맞는 BOM 리스트
        List<BOMDTO> bomList = bomService.searchBOM(code, name, category, model, materialName);
        // 전체 materialList를 항상 받아옴 (가격 정보 보장)
        List<MaterialDTO> materialList = stockService.getAllMaterials();
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("검색결과_BOM목록");
        int rowIdx = 0;
        Row header = sheet.createRow(rowIdx++);
        String[] headers = {"제품코드", "생산제품명", "소요원자재명", "소요원자재량", "소요금액"};
        for (int i = 0; i < headers.length; i++) header.createCell(i).setCellValue(headers[i]);
        for (BOMDTO bom : bomList) {
            int price = 0;
            for (MaterialDTO mat : materialList) {
                if (mat.getPk() == bom.getMaterialId()) {
                    price = mat.getPrice();
                    break;
                }
            }
            Row row = sheet.createRow(rowIdx++);
            row.createCell(0).setCellValue("prod2025" + (bom.getProductId() < 10 ? "0" + bom.getProductId() : bom.getProductId()));
            row.createCell(1).setCellValue(bom.getProductName());
            row.createCell(2).setCellValue(bom.getMaterialName());
            row.createCell(3).setCellValue(bom.getMaterialAmount());
            row.createCell(4).setCellValue(bom.getMaterialAmount() * price);
        }
        for (int i = 0; i < headers.length; i++) sheet.autoSizeColumn(i);
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=검색결과_BOM목록.xlsx");
        workbook.write(response.getOutputStream());
        workbook.close();
    }
}