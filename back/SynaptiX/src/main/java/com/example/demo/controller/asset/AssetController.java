package com.example.demo.controller.asset;

import com.example.demo.model.AssetDTO;
import com.example.demo.service.asset.AssetService;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@Controller
public class AssetController {
    @Autowired
    private AssetService assetService;

    @GetMapping("/managereport")
    public String getManageReport(Model model) {
        AssetDTO asset = assetService.getAsset();
        model.addAttribute("asset", asset);
        return "asset/managereport";
    }

    @GetMapping("/fund/report/search")
    public String searchAsset(@RequestParam(required = false) String startDate,
                             @RequestParam(required = false) String endDate,
                             Model model) {
        java.util.Map<String, Object> params = new java.util.HashMap<>();
        params.put("startDate", startDate);
        params.put("endDate", endDate);
        com.example.demo.model.AssetDTO asset = assetService.searchAsset(params);
        model.addAttribute("asset", asset);
        return "asset/ManageReportModalResult";
    }

    @GetMapping("/fund/report/excel")
    public void downloadReportExcel(HttpServletResponse response) throws IOException {
        AssetDTO asset = assetService.getAsset();
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("경영보고서");
        int rowIdx = 0;
        // 자금 현황 헤더
        Row header1 = sheet.createRow(rowIdx++);
        header1.createCell(0).setCellValue("총자금");
        header1.createCell(1).setCellValue("유동자금");
        // 자금 현황 데이터
        Row data1 = sheet.createRow(rowIdx++);
        data1.createCell(0).setCellValue(asset != null ? asset.getTotalAssets() : 0);
        data1.createCell(1).setCellValue(asset != null ? asset.getCurrentAssets() : 0);
        rowIdx++;
        // 수익/비용 현황 헤더
        Row header2 = sheet.createRow(rowIdx++);
        header2.createCell(0).setCellValue("총판매수익");
        header2.createCell(1).setCellValue("총구매비용");
        // 수익/비용 데이터
        Row data2 = sheet.createRow(rowIdx++);
        data2.createCell(0).setCellValue(asset != null ? asset.getTotalEarning() : 0);
        data2.createCell(1).setCellValue(asset != null ? asset.getTotalCost() : 0);
        sheet.autoSizeColumn(0);
        sheet.autoSizeColumn(1);
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=경영보고서.xlsx");
        workbook.write(response.getOutputStream());
        workbook.close();
    }
}