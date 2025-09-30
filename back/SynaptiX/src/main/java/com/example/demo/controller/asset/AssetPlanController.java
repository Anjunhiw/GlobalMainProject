package com.example.demo.controller.asset;

import com.example.demo.service.asset.AssetPlanService;
import com.example.demo.model.AssetPlanDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@Controller
public class AssetPlanController {
    @Autowired
    private AssetPlanService assetPlanService;

    @GetMapping("/assetplan")
    public String getAssetPlanPage(Model model) {
        List<AssetPlanDTO> assetPlans = assetPlanService.getAssetPlans();
        model.addAttribute("assetPlans", assetPlans);
        return "asset/assetplan";
    }

    @GetMapping("/fund/plan/search")
    public String searchAssetPlans(@RequestParam(required = false) String planDate,
                                  @RequestParam(required = false) String productName,
                                  @RequestParam(required = false) String salesQty,
                                  Model model) {
        java.util.Map<String, Object> params = new java.util.HashMap<>();
        params.put("planDate", planDate);
        params.put("productName", productName);
        params.put("salesQty", salesQty);
        java.util.List<com.example.demo.model.AssetPlanDTO> assetPlans = assetPlanService.searchAssetPlans(params);
        model.addAttribute("assetPlans", assetPlans);
        return "asset/AssetPlanModalResult";
    }

    @GetMapping("/fund/plan/excel")
    public void downloadPlanExcel(@RequestParam(value = "planDate", required = false) String planDate,
                                  @RequestParam(value = "productName", required = false) String productName,
                                  @RequestParam(value = "salesQty", required = false) String salesQty,
                                  HttpServletResponse response) throws IOException {
        java.util.Map<String, Object> params = new java.util.HashMap<>();
        params.put("planDate", planDate);
        params.put("productName", productName);
        params.put("salesQty", salesQty);
        java.util.List<com.example.demo.model.AssetPlanDTO> assetPlans = assetPlanService.searchAssetPlans(params);
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("자금계획내역");
        int rowIdx = 0;
        Row header = sheet.createRow(rowIdx++);
        String[] headers = {"예정일", "제품명", "단가", "예상판매량", "예상수익"};
        for (int i = 0; i < headers.length; i++) header.createCell(i).setCellValue(headers[i]);
        for (com.example.demo.model.AssetPlanDTO dto : assetPlans) {
            Row row = sheet.createRow(rowIdx++);
            row.createCell(0).setCellValue(dto.getDate() != null ? dto.getDate().toString() : "");
            row.createCell(1).setCellValue(dto.getProductName());
            row.createCell(2).setCellValue(dto.getPrice());
            row.createCell(3).setCellValue(dto.getAmount());
            row.createCell(4).setCellValue(dto.getProfit());
        }
        for (int i = 0; i < headers.length; i++) sheet.autoSizeColumn(i);
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=자금계획내역.xlsx");
        workbook.write(response.getOutputStream());
        workbook.close();
    }

    @GetMapping("/fund/plan/excel-modal")
    public void downloadPlanExcelModal(@RequestParam(value = "planDate", required = false) String planDate,
                                       @RequestParam(value = "productName", required = false) String productName,
                                       @RequestParam(value = "salesQty", required = false) String salesQty,
                                       HttpServletResponse response) throws IOException {
        java.util.Map<String, Object> params = new java.util.HashMap<>();
        params.put("planDate", planDate);
        params.put("productName", productName);
        params.put("salesQty", salesQty);
        java.util.List<com.example.demo.model.AssetPlanDTO> assetPlans = assetPlanService.searchAssetPlans(params);
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("검색결과_자금계획내역");
        int rowIdx = 0;
        Row header = sheet.createRow(rowIdx++);
        String[] headers = {"예정일", "제품명", "단가", "예상판매량", "예상수익"};
        for (int i = 0; i < headers.length; i++) header.createCell(i).setCellValue(headers[i]);
        for (com.example.demo.model.AssetPlanDTO dto : assetPlans) {
            Row row = sheet.createRow(rowIdx++);
            row.createCell(0).setCellValue(dto.getDate() != null ? dto.getDate().toString() : "");
            row.createCell(1).setCellValue(dto.getProductName());
            row.createCell(2).setCellValue(dto.getPrice());
            row.createCell(3).setCellValue(dto.getAmount());
            row.createCell(4).setCellValue(dto.getProfit());
        }
        for (int i = 0; i < headers.length; i++) sheet.autoSizeColumn(i);
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=검색결과_자금계획내역.xlsx");
        workbook.write(response.getOutputStream());
        workbook.close();
    }
}