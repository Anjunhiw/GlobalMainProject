package com.example.demo.controller.stock;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.PostMapping;
import javax.servlet.http.HttpServletResponse;
import com.example.demo.mapper.stock.ProfitMapper;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@Controller
public class ProfitController {
    @Autowired
    private ProfitMapper profitMapper;


    @GetMapping("/profit")
    public String profitPage(
        @RequestParam(value = "item_code", required = false) String itemCode,
        @RequestParam(value = "item_name", required = false) String itemName,
        @RequestParam(value = "category", required = false) String category,
        Model model) {
        List<Map<String, Object>> profitList = profitMapper.selectProfitList(itemCode, itemName, category);
        model.addAttribute("profitList", profitList);
        return "stock/profit";
    }

    @PostMapping("/profit/excel")
    public void downloadProfitExcel(
        @RequestParam(value = "item_code", required = false) String itemCode,
        @RequestParam(value = "item_name", required = false) String itemName,
        @RequestParam(value = "category", required = false) String category,
        HttpServletResponse response
    ) throws IOException {
        List<Map<String, Object>> profitList = profitMapper.selectProfitList(itemCode, itemName, category);
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("이익현황");
        int rowIdx = 0;
        Row header = sheet.createRow(rowIdx++);
        String[] headers = {"품목코드", "품목명", "판매수량", "판매단가", "판매금액", "원가단가", "원가금액", "이익단가", "이익금액", "이익률"};
        for (int i = 0; i < headers.length; i++) header.createCell(i).setCellValue(headers[i]);
        for (Map<String, Object> item : profitList) {
            Row row = sheet.createRow(rowIdx++);
            row.createCell(0).setCellValue(item.getOrDefault("code", "").toString());
            row.createCell(1).setCellValue(item.getOrDefault("name", "").toString());
            row.createCell(2).setCellValue(item.getOrDefault("salesQty", "").toString());
            row.createCell(3).setCellValue(item.getOrDefault("salesPrice", "").toString());
            row.createCell(4).setCellValue(item.getOrDefault("salesAmount", "").toString());
            row.createCell(5).setCellValue(item.getOrDefault("costPrice", "").toString());
            row.createCell(6).setCellValue(item.getOrDefault("costAmount", "").toString());
            row.createCell(7).setCellValue(item.getOrDefault("profitUnit", "").toString());
            row.createCell(8).setCellValue(item.getOrDefault("profitAmount", "").toString());
            row.createCell(9).setCellValue(item.getOrDefault("profitRate", "").toString());
        }
        for (int i = 0; i < headers.length; i++) sheet.autoSizeColumn(i);
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=이익현황.xlsx");
        workbook.write(response.getOutputStream());
        workbook.close();
    }

    @PostMapping("/profit/search")
    public String searchProfit(
        @RequestParam(value = "item_code", required = false) String itemCode,
        @RequestParam(value = "item_name", required = false) String itemName,
        @RequestParam(value = "category", required = false) String category,
        Model model
    ) {
        List<Map<String, Object>> profitList = profitMapper.selectProfitList(itemCode, itemName, category);
        model.addAttribute("profitList", profitList);
        return "stock/ProfitSearchResult";
    }

    @PostMapping("/profit/excel-modal")
    public void downloadExcelFromModal(
        @RequestParam(value = "item_code", required = false) String itemCode,
        @RequestParam(value = "item_name", required = false) String itemName,
        @RequestParam(value = "category", required = false) String category,
        HttpServletResponse response
    ) throws IOException {
        List<Map<String, Object>> profitList = profitMapper.selectProfitList(itemCode, itemName, category);
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("검색결과");
        int rowIdx = 0;
        Row header = sheet.createRow(rowIdx++);
        String[] headers = {"품목코드", "품목명", "판매수량", "판매단가", "판매금액", "원가단가", "원가금액", "이익단가", "이익금액", "이익률"};
        for (int i = 0; i < headers.length; i++) header.createCell(i).setCellValue(headers[i]);
        for (Map<String, Object> item : profitList) {
            Row row = sheet.createRow(rowIdx++);
            row.createCell(0).setCellValue(item.getOrDefault("code", "").toString());
            row.createCell(1).setCellValue(item.getOrDefault("name", "").toString());
            row.createCell(2).setCellValue(item.getOrDefault("salesQty", "").toString());
            row.createCell(3).setCellValue(item.getOrDefault("salesPrice", "").toString());
            row.createCell(4).setCellValue(item.getOrDefault("salesAmount", "").toString());
            row.createCell(5).setCellValue(item.getOrDefault("costPrice", "").toString());
            row.createCell(6).setCellValue(item.getOrDefault("costAmount", "").toString());
            row.createCell(7).setCellValue(item.getOrDefault("profitUnit", "").toString());
            row.createCell(8).setCellValue(item.getOrDefault("profitAmount", "").toString());
            row.createCell(9).setCellValue(item.getOrDefault("profitRate", "").toString());
        }
        for (int i = 0; i < headers.length; i++) sheet.autoSizeColumn(i);
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=검색결과.xlsx");
        workbook.write(response.getOutputStream());
        workbook.close();
    }
}