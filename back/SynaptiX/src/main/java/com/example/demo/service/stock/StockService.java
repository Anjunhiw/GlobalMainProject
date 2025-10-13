package com.example.demo.service.stock;

import com.example.demo.model.MaterialDTO;
import com.example.demo.model.ProductDTO;
import com.example.demo.model.PageResult;
import com.example.demo.mapper.stock.StockMapper;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class StockService {
    private final StockMapper mapper;

    public StockService(StockMapper mapper) {
        this.mapper = mapper;
        System.out.println("StockService Bean 생성됨, StockMapper 주입 상태: " + (mapper != null));
    }

    public List<MaterialDTO> getAllMaterials() {
        return mapper.selectAllMaterials();
    }

    public List<ProductDTO> getAllProducts() {
        return mapper.selectAllProducts();
    }

    public List<MaterialDTO> searchMaterialsByName(String name) {
        return mapper.selectMaterialsByName(name);
    }

    public List<ProductDTO> searchProductsByName(String name) {
        return mapper.selectProductsByName(name);
    }

    public List<MaterialDTO> searchMaterials(String code, String name, String model, String category) {
        return mapper.selectMaterialsByCondition(code, name, model, category);
    }
    public List<ProductDTO> searchProducts(String code, String name, String model, String category) {
        return mapper.selectProductsByCondition(code, name, model, category);
    }

    public Object getStockByPk(int pk) {
        MaterialDTO material = mapper.selectMaterialByPk(pk);
        if (material != null) return material;
        ProductDTO product = mapper.selectProductByPk(pk);
        return product;
    }
    public MaterialDTO getMaterialByPk(int pk) {
        return mapper.selectMaterialByPk(pk);
    }
    public ProductDTO getProductByPk(int pk) {
        return mapper.selectProductByPk(pk);
    }
    public void updateMaterial(MaterialDTO material) {
        mapper.updateMaterial(material);
    }
    public void updateProduct(ProductDTO product) {
        mapper.updateProduct(product);
    }
    public void deleteStock(int pk) {
        if (mapper.selectMaterialByPk(pk) != null) {
            mapper.deleteMaterial(pk);
        } else {
            mapper.deleteProduct(pk);
        }
    }
    public void deleteMaterial(int pk) {
        mapper.deleteMaterial(pk);
    }
    public void deleteProduct(int pk) {
        mapper.deleteProduct(pk);
    }
    public void insertMaterial(MaterialDTO dto) {
        mapper.insertMaterial(dto);
    }
    public void insertProduct(ProductDTO dto) {
        mapper.insertProduct(dto);
    }
    // 검색 결과 모달용 엑셀 생성
    public void writeExcel(List<MaterialDTO> materials, List<ProductDTO> products, java.io.OutputStream os) throws java.io.IOException {
        org.apache.poi.ss.usermodel.Workbook workbook = new org.apache.poi.xssf.usermodel.XSSFWorkbook();
        org.apache.poi.ss.usermodel.Sheet sheet = workbook.createSheet("검색결과");
        int rowIdx = 0;
        org.apache.poi.ss.usermodel.Row header = sheet.createRow(rowIdx++);
        String[] headers = {"구분", "품목코드", "품목명", "카테고리", "모델명", "규격", "단위", "단가", "재고수량", "재고금액"};
        for (int i = 0; i < headers.length; i++) header.createCell(i).setCellValue(headers[i]);
        for (MaterialDTO m : materials) {
            org.apache.poi.ss.usermodel.Row row = sheet.createRow(rowIdx++);
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
            org.apache.poi.ss.usermodel.Row row = sheet.createRow(rowIdx++);
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
        workbook.write(os);
        workbook.close();
    }
    // 제품만 엑셀 생성
    public void writeProductExcel(List<ProductDTO> products, java.io.OutputStream os) throws java.io.IOException {
        org.apache.poi.ss.usermodel.Workbook workbook = new org.apache.poi.xssf.usermodel.XSSFWorkbook();
        org.apache.poi.ss.usermodel.Sheet sheet = workbook.createSheet("제품목록");
        int rowIdx = 0;
        org.apache.poi.ss.usermodel.Row header = sheet.createRow(rowIdx++);
        String[] headers = {"품목코드", "제품명", "카테고리", "모델명", "규격", "단가", "재고수량", "재고금액"};
        for (int i = 0; i < headers.length; i++) header.createCell(i).setCellValue(headers[i]);
        for (ProductDTO p : products) {
            org.apache.poi.ss.usermodel.Row row = sheet.createRow(rowIdx++);
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
        workbook.write(os);
        workbook.close();
    }

    // 원자재만 엑셀 생성
    public void writeMaterialExcel(List<MaterialDTO> materials, java.io.OutputStream os) throws java.io.IOException {
        org.apache.poi.ss.usermodel.Workbook workbook = new org.apache.poi.xssf.usermodel.XSSFWorkbook();
        org.apache.poi.ss.usermodel.Sheet sheet = workbook.createSheet("원자재목록");
        int rowIdx = 0;
        org.apache.poi.ss.usermodel.Row header = sheet.createRow(rowIdx++);
        String[] headers = {"품목코드", "품목명", "카테고리", "규격", "단위", "단가", "재고수량", "재고금액"};
        for (int i = 0; i < headers.length; i++) header.createCell(i).setCellValue(headers[i]);
        for (MaterialDTO m : materials) {
            org.apache.poi.ss.usermodel.Row row = sheet.createRow(rowIdx++);
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
        workbook.write(os);
        workbook.close();
    }

    public PageResult<MaterialDTO> getPagedMaterials(int page, int size) {
        int offset = page * size;
        List<MaterialDTO> materials = mapper.selectAllMaterialsPaged(offset, size);
        int totalCount = mapper.countAllMaterials();
        return new PageResult<>(materials, totalCount, page, size);
    }
    public PageResult<MaterialDTO> searchMaterialsByNamePaged(String name, int page, int size) {
        int offset = page * size;
        List<MaterialDTO> materials = mapper.selectMaterialsByNamePaged(name, offset, size);
        int totalCount = mapper.countMaterialsByName(name);
        return new PageResult<>(materials, totalCount, page, size);
    }
    public PageResult<ProductDTO> getPagedProducts(int page, int size) {
        int offset = page * size;
        List<ProductDTO> products = mapper.selectAllProductsPaged(offset, size);
        int totalCount = mapper.countAllProducts();
        return new PageResult<>(products, totalCount, page, size);
    }
}