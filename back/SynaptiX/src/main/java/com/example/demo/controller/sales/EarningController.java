package com.example.demo.controller.sales;

import com.example.demo.mapper.sales.EarningMapper;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@Controller
public class EarningController {
    @Autowired
    private EarningMapper earningMapper;

    @GetMapping("/earning")
    public String earningList(Model model) {
        List<Map<String, Object>> earningList = earningMapper.selectAllEarnings();
        model.addAttribute("earningList", earningList);
        return "sales/earning";
    }

    @GetMapping("/sales/earning/search")
    public String searchEarnings(@RequestParam(required = false) String prodCode,
                                 @RequestParam(required = false) String prodName,
                                 @RequestParam(required = false) String qc,
                                 @RequestParam(required = false) String startDate,
                                 @RequestParam(required = false) String endDate,
                                 Model model) {
        java.util.Map<String, Object> params = new java.util.HashMap<>();
        params.put("prodCode", prodCode);
        params.put("prodName", prodName);
        params.put("qc", qc);
        params.put("startDate", startDate);
        params.put("endDate", endDate);
        List<Map<String, Object>> earningList = earningMapper.searchEarnings(params);
        model.addAttribute("earningList", earningList);
        return "sales/EarningModalResult";
    }

    @GetMapping("/sales/earning/excel")
    public void downloadEarningExcel(HttpServletResponse response) throws IOException {
        List<Map<String, Object>> earningList = earningMapper.selectAllEarnings();
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("매출");
        int rowIdx = 0;
        Row header = sheet.createRow(rowIdx++);
        String[] headers = {"제품코드", "판매일자", "제품명", "판매수량", "판매금액", "원가", "순이익", "재고량"};
        for (int i = 0; i < headers.length; i++) header.createCell(i).setCellValue(headers[i]);
        for (Map<String, Object> s : earningList) {
            Row r = sheet.createRow(rowIdx++);
            r.createCell(0).setCellValue(s.get("ProductId") != null ? s.get("ProductId").toString() : "");
            r.createCell(1).setCellValue(s.get("Date") != null ? s.get("Date").toString() : "");
            r.createCell(2).setCellValue(s.get("ProductName") != null ? s.get("ProductName").toString() : "");
            r.createCell(3).setCellValue(s.get("Amount") != null ? Double.parseDouble(s.get("Amount").toString()) : 0);
            r.createCell(4).setCellValue(s.get("Price") != null ? Double.parseDouble(s.get("Price").toString()) : 0);
            r.createCell(5).setCellValue(s.get("Total") != null ? Double.parseDouble(s.get("Total").toString()) : 0);
            r.createCell(6).setCellValue(s.get("Earning") != null ? Double.parseDouble(s.get("Earning").toString()) : 0);
            r.createCell(7).setCellValue(s.get("Stock") != null ? Double.parseDouble(s.get("Stock").toString()) : 0);
        }
        for (int i = 0; i < headers.length; i++) sheet.autoSizeColumn(i);
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setCharacterEncoding("UTF-8");
        String fileName = "매출_전체리스트.xlsx";
        String encodedFileName = java.net.URLEncoder.encode(fileName, java.nio.charset.StandardCharsets.UTF_8).replaceAll("\\+", "%20");
        response.setHeader("Content-Disposition", "attachment; filename*=UTF-8''" + encodedFileName);
        workbook.write(response.getOutputStream());
        workbook.close();
    }

    @PostMapping("/sales/earning/excel-modal")
    public void downloadEarningExcelModal(
            @RequestParam(required = false) String prodCode,
            @RequestParam(required = false) String prodName,
            @RequestParam(required = false) String qc,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate,
            HttpServletResponse response
    ) throws IOException {
        java.util.Map<String, Object> params = new java.util.HashMap<>();
        params.put("prodCode", prodCode);
        params.put("prodName", prodName);
        params.put("qc", qc);
        params.put("startDate", startDate);
        params.put("endDate", endDate);
        List<Map<String, Object>> earningList = earningMapper.searchEarnings(params);
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("매출_검색결과");
        int rowIdx = 0;
        Row header = sheet.createRow(rowIdx++);
        String[] headers = {"제품코드", "판매일자", "제품명", "판매수량", "판매금액", "원가", "순이익", "재고량"};
        for (int i = 0; i < headers.length; i++) header.createCell(i).setCellValue(headers[i]);
        for (Map<String, Object> s : earningList) {
            Row r = sheet.createRow(rowIdx++);
            r.createCell(0).setCellValue(s.get("ProductId") != null ? s.get("ProductId").toString() : "");
            r.createCell(1).setCellValue(s.get("Date") != null ? s.get("Date").toString() : "");
            r.createCell(2).setCellValue(s.get("ProductName") != null ? s.get("ProductName").toString() : "");
            r.createCell(3).setCellValue(s.get("Amount") != null ? Double.parseDouble(s.get("Amount").toString()) : 0);
            r.createCell(4).setCellValue(s.get("Price") != null ? Double.parseDouble(s.get("Price").toString()) : 0);
            r.createCell(5).setCellValue(s.get("Total") != null ? Double.parseDouble(s.get("Total").toString()) : 0);
            r.createCell(6).setCellValue(s.get("Earning") != null ? Double.parseDouble(s.get("Earning").toString()) : 0);
            r.createCell(7).setCellValue(s.get("Stock") != null ? Double.parseDouble(s.get("Stock").toString()) : 0);
        }
        for (int i = 0; i < headers.length; i++) sheet.autoSizeColumn(i);
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setCharacterEncoding("UTF-8");
        String fileName = "매출_검색결과.xlsx";
        String encodedFileName = java.net.URLEncoder.encode(fileName, java.nio.charset.StandardCharsets.UTF_8).replaceAll("\\+", "%20");
        response.setHeader("Content-Disposition", "attachment; filename*=UTF-8''" + encodedFileName);
        workbook.write(response.getOutputStream());
        workbook.close();
    }
}