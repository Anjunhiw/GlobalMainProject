package com.example.demo.controller.sales;

import com.example.demo.model.TransactionDTO;
import com.example.demo.mapper.sales.TransactionMapper;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
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
public class TransactionController {
    @Autowired
    private TransactionMapper transactionMapper;

    @GetMapping("/transaction")
    public String transactionList(Model model) {
        List<TransactionDTO> transactionList = transactionMapper.selectAllTransactions();
        model.addAttribute("transactionList", transactionList);
        return "sales/transaction";
    }

    @GetMapping("/transaction/search")
    public String searchTransactions(
            @RequestParam(value = "prodCode", required = false) String prodCode,
            @RequestParam(value = "prodName", required = false) String prodName,
            @RequestParam(value = "date", required = false) String date,
            @RequestParam(value = "stmtNo", required = false) String stmtNo,
            Model model) {
        Map<String, Object> param = new java.util.HashMap<>();
        if (prodCode != null && !prodCode.isEmpty()) param.put("prodCode", prodCode);
        if (prodName != null && !prodName.isEmpty()) param.put("prodName", prodName);
        if (date != null && !date.isEmpty()) param.put("date", date);
        if (stmtNo != null && !stmtNo.isEmpty()) param.put("stmtNo", stmtNo);
        List<TransactionDTO> transactionList = transactionMapper.selectTransactionsByCondition(param);
        model.addAttribute("transactionList", transactionList);
        return "sales/transaction_tbody";
    }

    @GetMapping("/transaction/excel")
    public void downloadTransactionExcel(HttpServletResponse response) throws IOException {
        List<TransactionDTO> transactionList = transactionMapper.selectAllTransactions();
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("거래명세서");
        int rowIdx = 0;
        Row header = sheet.createRow(rowIdx++);
        String[] headers = {"거래명세서번호", "거래일자", "제품코드", "제품명", "수량", "단가", "금액", "판매수익"};
        for (int i = 0; i < headers.length; i++) header.createCell(i).setCellValue(headers[i]);
        for (TransactionDTO row : transactionList) {
            Row r = sheet.createRow(rowIdx++);
            r.createCell(0).setCellValue(row.getDate() != null ? new java.text.SimpleDateFormat("yyyyMM").format(row.getDate()) + "-" + row.getPk() : "-" + row.getPk());
            r.createCell(1).setCellValue(row.getDate() != null ? new java.text.SimpleDateFormat("yyyy-MM-dd").format(row.getDate()) : "");
            r.createCell(2).setCellValue("prod2025" + (row.getProductId() < 10 ? "0" + row.getProductId() : row.getProductId()));
            r.createCell(3).setCellValue(row.getProdName() != null ? row.getProdName() : "");
            r.createCell(4).setCellValue(row.getSales() != null ? row.getSales() : 0);
            r.createCell(5).setCellValue(row.getUnitPrice() != null ? row.getUnitPrice() : 0);
            r.createCell(6).setCellValue(row.getAmount() != null ? row.getAmount() : 0);
            r.createCell(7).setCellValue(row.getEarning() != null ? row.getEarning() : 0);
        }
        for (int i = 0; i < headers.length; i++) sheet.autoSizeColumn(i);
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=거래명세서_전체리스트.xlsx");
        workbook.write(response.getOutputStream());
        workbook.close();
    }

    @PostMapping("/transaction/excel-modal")
    public void downloadTransactionExcelModal(
            @RequestParam(required = false) String prodCode,
            @RequestParam(required = false) String prodName,
            @RequestParam(required = false) String date,
            @RequestParam(required = false) String stmtNo,
            HttpServletResponse response
    ) throws IOException {
        java.util.Map<String, Object> param = new java.util.HashMap<>();
        if (prodCode != null && !prodCode.isEmpty()) param.put("prodCode", prodCode);
        if (prodName != null && !prodName.isEmpty()) param.put("prodName", prodName);
        if (date != null && !date.isEmpty()) param.put("date", date);
        if (stmtNo != null && !stmtNo.isEmpty()) param.put("stmtNo", stmtNo);
        List<TransactionDTO> transactionList = transactionMapper.selectTransactionsByCondition(param);
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("거래명세서검색결과");
        int rowIdx = 0;
        Row header = sheet.createRow(rowIdx++);
        String[] headers = {"거래명세서번호", "거래일자", "제품코드", "제품명", "수량", "단가", "금액", "판매수익"};
        for (int i = 0; i < headers.length; i++) header.createCell(i).setCellValue(headers[i]);
        for (TransactionDTO row : transactionList) {
            Row r = sheet.createRow(rowIdx++);
            r.createCell(0).setCellValue(row.getDate() != null ? new java.text.SimpleDateFormat("yyyyMM").format(row.getDate()) + "-" + row.getPk() : "-" + row.getPk());
            r.createCell(1).setCellValue(row.getDate() != null ? new java.text.SimpleDateFormat("yyyy-MM-dd").format(row.getDate()) : "");
            r.createCell(2).setCellValue("prod2025" + (row.getProductId() < 10 ? "0" + row.getProductId() : row.getProductId()));
            r.createCell(3).setCellValue(row.getProdName() != null ? row.getProdName() : "");
            r.createCell(4).setCellValue(row.getSales() != null ? row.getSales() : 0);
            r.createCell(5).setCellValue(row.getUnitPrice() != null ? row.getUnitPrice() : 0);
            r.createCell(6).setCellValue(row.getAmount() != null ? row.getAmount() : 0);
            r.createCell(7).setCellValue(row.getEarning() != null ? row.getEarning() : 0);
        }
        for (int i = 0; i < headers.length; i++) sheet.autoSizeColumn(i);
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=거래명세서_검색결과.xlsx");
        workbook.write(response.getOutputStream());
        workbook.close();
    }
}