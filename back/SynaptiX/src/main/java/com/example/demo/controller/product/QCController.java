package com.example.demo.controller.product;

import com.example.demo.model.QCDTO;
import com.example.demo.service.product.QCService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.access.prepost.PreAuthorize;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@Controller
@RequestMapping("/qc")
public class QCController {
    @Autowired
    private QCService qcService;
    
    @GetMapping("")
    public String showQC(Model model) {
        model.addAttribute("list", qcService.getAllQC());
        return "product/qc";
    }

    @PostMapping("/search")
    @ResponseBody
    public java.util.List<QCDTO> searchQC(@RequestBody java.util.Map<String, String> params) {
        String dateFrom = params.get("dateFrom");
        String dateTo = params.get("dateTo");
        String prodName = params.get("prodName");
        String category = params.get("category");
        return qcService.searchQC(dateFrom, dateTo, prodName, category);
    }

    @PostMapping("")
    @ResponseBody
    public java.util.Map<String, Object> addQC(@RequestBody QCDTO qcDTO) {
        System.out.println("QC 등록 요청: mpsId=" + qcDTO.getMpsId() + ", passed=" + qcDTO.isPassed());
        java.util.Map<String, Object> result = new java.util.HashMap<>();
        try {
            qcService.addQC(qcDTO);
            result.put("success", true);
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", e.getMessage());
        }
        return result;
    }

    @GetMapping("/excel")
    public void downloadExcel(HttpServletResponse response) throws IOException {
        java.util.List<QCDTO> list = qcService.getAllQC();
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("QC전체리스트");
        int rowIdx = 0;
        Row header = sheet.createRow(rowIdx++);
        String[] headers = {"제품코드", "제품명", "모델명", "규격", "검사일자", "합격여부"};
        for (int i = 0; i < headers.length; i++) header.createCell(i).setCellValue(headers[i]);
        for (com.example.demo.model.QCDTO qc : list) {
            Row row = sheet.createRow(rowIdx++);
            row.createCell(0).setCellValue("prod2025" + (qc.getCode() < 10 ? "0" + qc.getCode() : qc.getCode()));
            row.createCell(1).setCellValue(qc.getName());
            row.createCell(2).setCellValue(qc.getModel());
            row.createCell(3).setCellValue(qc.getSpecification());
            row.createCell(4).setCellValue(qc.getPeriod() != null ? qc.getPeriod().toString().substring(0, 10) : "");
            row.createCell(5).setCellValue(qc.isPassed() ? "합격" : "불합격");
        }
        for (int i = 0; i < headers.length; i++) sheet.autoSizeColumn(i);
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=QC_전체리스트.xlsx");
        workbook.write(response.getOutputStream());
        workbook.close();
    }

    @GetMapping("/excel-modal")
    public void downloadExcelFromModal(@RequestParam(value = "dateFrom", required = false) String dateFrom,
                                       @RequestParam(value = "dateTo", required = false) String dateTo,
                                       @RequestParam(value = "prodName", required = false) String prodName,
                                       @RequestParam(value = "category", required = false) String category,
                                       HttpServletResponse response) throws IOException {
        java.util.List<QCDTO> list = qcService.searchQC(dateFrom, dateTo, prodName, category);
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("QC검색결과");
        int rowIdx = 0;
        Row header = sheet.createRow(rowIdx++);
        String[] headers = {"제품코드", "제품명", "모델명", "규격", "검사일자", "합격여부"};
        for (int i = 0; i < headers.length; i++) header.createCell(i).setCellValue(headers[i]);
        for (com.example.demo.model.QCDTO qc : list) {
            Row row = sheet.createRow(rowIdx++);
            row.createCell(0).setCellValue("prod2025" + (qc.getCode() < 10 ? "0" + qc.getCode() : qc.getCode()));
            row.createCell(1).setCellValue(qc.getName());
            row.createCell(2).setCellValue(qc.getModel());
            row.createCell(3).setCellValue(qc.getSpecification());
            row.createCell(4).setCellValue(qc.getPeriod() != null ? qc.getPeriod().toString().substring(0, 10) : "");
            row.createCell(5).setCellValue(qc.isPassed() ? "합격" : "불합격");
        }
        for (int i = 0; i < headers.length; i++) sheet.autoSizeColumn(i);
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=QC_검색결과.xlsx");
        workbook.write(response.getOutputStream());
        workbook.close();
    }
}