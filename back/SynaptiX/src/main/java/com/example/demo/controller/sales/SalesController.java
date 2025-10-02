package com.example.demo.controller.sales;

import com.example.demo.model.Sales;
import com.example.demo.service.sales.SalesService;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@Controller
public class SalesController {
    @Autowired
    private SalesService salesService;

    @GetMapping("/sales")
    public String salesList(Model model) {
        List<Sales> salesList = salesService.getAllSales();
        model.addAttribute("salesList", salesList);
        return "sales/Sales";
    }

    @GetMapping("/sales/outbound")
    public String searchSales(
            @RequestParam(required = false) String code,
            @RequestParam(required = false) String name,
            @RequestParam(required = false) String outDate,
            @RequestParam(required = false) String category,
            Model model,
            HttpServletRequest request
    ) {
        List<Sales> salesList = salesService.searchSales(code, name, outDate, category);
        model.addAttribute("salesList", salesList);
        // AJAX 요청이면 fragment만 반환
        if ("XMLHttpRequest".equals(request.getHeader("X-Requested-With"))) {
            return "sales/SalesModalResult";
        }
        // 일반 요청이면 전체 페이지 반환(예외적 상황)
        return "sales/Sales";
    }

    @GetMapping("/sales/excel")
    public void downloadSalesExcel(HttpServletResponse response) throws IOException {
        List<Sales> salesList = salesService.getAllSales();
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("판매출고");
        int rowIdx = 0;
        Row header = sheet.createRow(rowIdx++);
        String[] headers = {"출고번호", "출고일", "제품코드", "제품명", "수량", "단가", "금액", "출고상태"};
        for (int i = 0; i < headers.length; i++) header.createCell(i).setCellValue(headers[i]);
        for (Sales row : salesList) {
            Row r = sheet.createRow(rowIdx++);
            r.createCell(0).setCellValue(row.getPk());
            r.createCell(1).setCellValue(row.getSaleDate() != null ? new java.text.SimpleDateFormat("yyyy-MM-dd").format(row.getSaleDate()) : "");
            r.createCell(2).setCellValue(row.getProductId() != null ? "prod2025" + (isNumeric(row.getProductId()) && Integer.parseInt(row.getProductId()) < 10 ? "0" + row.getProductId() : row.getProductId()) : "");
            r.createCell(3).setCellValue(row.getProductName() != null ? row.getProductName() : "");
            r.createCell(4).setCellValue(row.getQuantity());
            r.createCell(5).setCellValue(row.getPrice());
            r.createCell(6).setCellValue(row.getEarning());
            r.createCell(7).setCellValue(row.getSaleDate() != null && row.getSaleDate().before(new java.util.Date()) ? "출고완료" : "출고준비");
        }
        for (int i = 0; i < headers.length; i++) sheet.autoSizeColumn(i);
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=판매출고_전체리스트.xlsx");
        workbook.write(response.getOutputStream());
        workbook.close();
    }

    @GetMapping("/sales/excel-modal")
    public void downloadSalesExcelModal(
            @RequestParam(required = false) String code,
            @RequestParam(required = false) String name,
            @RequestParam(required = false) String outDate,
            @RequestParam(required = false) String category,
            HttpServletResponse response
    ) throws IOException {
        System.out.println("[DEBUG] SalesController /sales/excel-modal 진입");
        org.springframework.security.core.Authentication auth = org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
        System.out.println("[DEBUG] 인증 객체: " + auth);
        if (auth != null) {
            System.out.println("[DEBUG] 권한 목록: " + auth.getAuthorities());
        }
        List<Sales> salesList = salesService.searchSales(code, name, outDate, category);
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("판매출고검색결과");
        int rowIdx = 0;
        Row header = sheet.createRow(rowIdx++);
        String[] headers = {"출고번호", "출고일", "제품코드", "제품명", "수량", "단가", "금액", "출고상태"};
        for (int i = 0; i < headers.length; i++) header.createCell(i).setCellValue(headers[i]);
        for (Sales row : salesList) {
            Row r = sheet.createRow(rowIdx++);
            r.createCell(0).setCellValue(row.getPk());
            r.createCell(1).setCellValue(row.getSaleDate() != null ? new java.text.SimpleDateFormat("yyyy-MM-dd").format(row.getSaleDate()) : "");
            r.createCell(2).setCellValue(row.getProductId() != null ? "prod2025" + (isNumeric(row.getProductId()) && Integer.parseInt(row.getProductId()) < 10 ? "0" + row.getProductId() : row.getProductId()) : "");
            r.createCell(3).setCellValue(row.getProductName() != null ? row.getProductName() : "");
            r.createCell(4).setCellValue(row.getQuantity());
            r.createCell(5).setCellValue(row.getPrice());
            r.createCell(6).setCellValue(row.getEarning());
            r.createCell(7).setCellValue(row.getSaleDate() != null && row.getSaleDate().before(new java.util.Date()) ? "출고완료" : "출고준비");
        }
        for (int i = 0; i < headers.length; i++) sheet.autoSizeColumn(i);
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=판매출고_검색결과.xlsx");
        workbook.write(response.getOutputStream());
        workbook.close();
    }

    // 숫자 여부 체크 유틸
    private boolean isNumeric(String str) {
        if (str == null) return false;
        try {
            Integer.parseInt(str);
            return true;
        } catch (NumberFormatException e) {
            return false;
        }
    }
}