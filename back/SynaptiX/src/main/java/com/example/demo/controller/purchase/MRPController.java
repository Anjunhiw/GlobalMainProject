package com.example.demo.controller.purchase;

import com.example.demo.mapper.purchase.MRPMapper;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@Controller
public class MRPController {
    @Autowired
    private MRPMapper mrpMapper;

    @GetMapping("/mrp")
    public String mrpList(Model model) {
        List<Map<String, Object>> mrpList = mrpMapper.selectAllMRP();
        model.addAttribute("mrpList", mrpList);
        return "purchase/mrp";
    }

    @GetMapping("/mrp/search")
    public String searchMrp(@RequestParam(required = false) String prodCode,
                           @RequestParam(required = false) String prodName,
                           @RequestParam(required = false) String inDate,
                           @RequestParam(required = false) String mrpStatus,
                           Model model) {
        java.util.Map<String, Object> params = new java.util.HashMap<>();
        params.put("prodCode", prodCode);
        params.put("prodName", prodName);
        params.put("inDate", inDate);
        params.put("mrpStatus", mrpStatus);
        java.util.List<java.util.Map<String, Object>> mrpList = mrpMapper.searchMRP(params);
        model.addAttribute("mrpList", mrpList);
        return "purchase/MrpModalResult";
    }

    @GetMapping("/mrp/excel")
    public void downloadMrpExcel(HttpServletResponse response) throws IOException {
        List<Map<String, Object>> mrpList = mrpMapper.selectAllMRP();
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("MRP현황");
        int rowIdx = 0;
        Row header = sheet.createRow(rowIdx++);
        String[] headers = {"제품명", "필요 원자재", "필요량", "현재재고", "추가재고필요량", "계획일자"};
        for (int i = 0; i < headers.length; i++) header.createCell(i).setCellValue(headers[i]);
        for (Map<String, Object> m : mrpList) {
            Row row = sheet.createRow(rowIdx++);
            row.createCell(0).setCellValue(m.getOrDefault("ProductName", "").toString());
            row.createCell(1).setCellValue(m.getOrDefault("MaterialName", "").toString());
            row.createCell(2).setCellValue(Double.parseDouble(m.getOrDefault("RequiredQuantity", 0).toString()));
            row.createCell(3).setCellValue(Double.parseDouble(m.getOrDefault("StockQuantity", 0).toString()));
            row.createCell(4).setCellValue(Double.parseDouble(m.getOrDefault("Shortage", 0).toString()));
            row.createCell(5).setCellValue(m.getOrDefault("ProductionPlan", "").toString());
        }
        for (int i = 0; i < headers.length; i++) sheet.autoSizeColumn(i);
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=MRP현황.xlsx");
        workbook.write(response.getOutputStream());
        workbook.close();
    }

    @GetMapping("/mrp/excel-modal")
    public void downloadMrpExcelModal(@RequestParam(required = false) String prodCode,
                                      @RequestParam(required = false) String prodName,
                                      @RequestParam(required = false) String inDate,
                                      @RequestParam(required = false) String mrpStatus,
                                      HttpServletResponse response) throws IOException {
        java.util.Map<String, Object> params = new java.util.HashMap<>();
        params.put("prodCode", prodCode);
        params.put("prodName", prodName);
        params.put("inDate", inDate);
        params.put("mrpStatus", mrpStatus);
        List<Map<String, Object>> mrpList = mrpMapper.searchMRP(params);
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("검색결과_MRP현황");
        int rowIdx = 0;
        Row header = sheet.createRow(rowIdx++);
        String[] headers = {"제품명", "필요 원자재", "필요량", "현재재고", "추가재고필요량", "계획일자"};
        for (int i = 0; i < headers.length; i++) header.createCell(i).setCellValue(headers[i]);
        for (Map<String, Object> m : mrpList) {
            Row row = sheet.createRow(rowIdx++);
            row.createCell(0).setCellValue(m.getOrDefault("ProductName", "").toString());
            row.createCell(1).setCellValue(m.getOrDefault("MaterialName", "").toString());
            row.createCell(2).setCellValue(Double.parseDouble(m.getOrDefault("RequiredQuantity", 0).toString()));
            row.createCell(3).setCellValue(Double.parseDouble(m.getOrDefault("StockQuantity", 0).toString()));
            row.createCell(4).setCellValue(Double.parseDouble(m.getOrDefault("Shortage", 0).toString()));
            row.createCell(5).setCellValue(m.getOrDefault("ProductionPlan", "").toString());
        }
        for (int i = 0; i < headers.length; i++) sheet.autoSizeColumn(i);
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=검색결과_MRP현황.xlsx");
        workbook.write(response.getOutputStream());
        workbook.close();
    }
}