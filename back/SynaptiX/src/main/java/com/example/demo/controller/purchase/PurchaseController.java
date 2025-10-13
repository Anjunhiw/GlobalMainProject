package com.example.demo.controller.purchase;

import com.example.demo.model.PurchaseDTO;
import com.example.demo.service.purchase.PurchaseService;
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

@Controller
public class PurchaseController {
    @Autowired
    private PurchaseService purchaseService;

    @GetMapping("/purchase")
    public String purchaseList(Model model) {
        List<PurchaseDTO> purchaseList = purchaseService.getAllPurchases();
        model.addAttribute("purchaseList", purchaseList);
        return "purchase/Purchase";
    }

    @GetMapping("/purchase/in/search")
    public String searchPurchases(@RequestParam(required = false) String prodCode,
                                  @RequestParam(required = false) String prodName,
                                  @RequestParam(required = false) String inDate,
                                  @RequestParam(required = false) String mrpStatus,
                                  Model model) {
        java.util.Map<String, Object> params = new java.util.HashMap<>();
        params.put("prodCode", prodCode);
        params.put("prodName", prodName);
        params.put("inDate", inDate);
        params.put("mrpStatus", mrpStatus);
        java.util.List<com.example.demo.model.PurchaseDTO> purchaseList = purchaseService.searchPurchases(params);
        model.addAttribute("purchaseList", purchaseList);
        return "purchase/PurchaseModalResult";
    }

    @GetMapping("/purchase/excel")
    public void downloadPurchaseExcel(HttpServletResponse response) throws IOException {
        List<PurchaseDTO> purchaseList = purchaseService.getAllPurchases();
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("구매입고내역");
        int rowIdx = 0;
        Row header = sheet.createRow(rowIdx++);
        String[] headers = {"구매번호", "원자재명", "단가", "구매량", "구매금액", "입고일", "재고량", "재고금액"};
        for (int i = 0; i < headers.length; i++) header.createCell(i).setCellValue(headers[i]);
        for (PurchaseDTO p : purchaseList) {
            Row row = sheet.createRow(rowIdx++);
            row.createCell(0).setCellValue(p.getPk());
            row.createCell(1).setCellValue(p.getMaterialName());
            row.createCell(2).setCellValue(p.getPrice());
            row.createCell(3).setCellValue(p.getPurchase());
            row.createCell(4).setCellValue(p.getCost());
            row.createCell(5).setCellValue(p.getDate() != null ? p.getDate().toString() : "");
            row.createCell(6).setCellValue(p.getStock());
            row.createCell(7).setCellValue(p.getAmount());
        }
        for (int i = 0; i < headers.length; i++) sheet.autoSizeColumn(i);
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=구매입고내역.xlsx");
        workbook.write(response.getOutputStream());
        workbook.close();
    }

    @GetMapping("/purchase/excel-modal")
    public void downloadPurchaseExcelModal(@RequestParam(required = false) String prodCode,
                                           @RequestParam(required = false) String prodName,
                                           @RequestParam(required = false) String inDate,
                                           @RequestParam(required = false) String mrpStatus,
                                           HttpServletResponse response) throws IOException {
        java.util.Map<String, Object> params = new java.util.HashMap<>();
        params.put("prodCode", prodCode);
        params.put("prodName", prodName);
        params.put("inDate", inDate);
        params.put("mrpStatus", mrpStatus);
        List<PurchaseDTO> purchaseList = purchaseService.searchPurchases(params);
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("검색결과_구매입고내역");
        int rowIdx = 0;
        Row header = sheet.createRow(rowIdx++);
        String[] headers = {"구매번호", "원자재명", "단가", "구매량", "구매금액", "입고일", "재고량", "재고금액"};
        for (int i = 0; i < headers.length; i++) header.createCell(i).setCellValue(headers[i]);
        for (PurchaseDTO p : purchaseList) {
            Row row = sheet.createRow(rowIdx++);
            row.createCell(0).setCellValue(p.getPk());
            row.createCell(1).setCellValue(p.getMaterialName());
            row.createCell(2).setCellValue(p.getPrice());
            row.createCell(3).setCellValue(p.getPurchase());
            row.createCell(4).setCellValue(p.getCost());
            row.createCell(5).setCellValue(p.getDate() != null ? p.getDate().toString() : "");
            row.createCell(6).setCellValue(p.getStock());
            row.createCell(7).setCellValue(p.getAmount());
        }
        for (int i = 0; i < headers.length; i++) sheet.autoSizeColumn(i);
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=검색결과_구매입고내역.xlsx");
        workbook.write(response.getOutputStream());
        workbook.close();
    }
}