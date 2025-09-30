package com.example.demo.controller.product;

import com.example.demo.model.MPSDTO;
import com.example.demo.service.product.MPSService;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@Controller
@RequestMapping("/mps")
public class MPSController {
    @Autowired
    private MPSService mpsService;

    @GetMapping("")
    public String showMPS(Model model) {
        model.addAttribute("list", mpsService.getAllMPS());
        return "product/mps";
    }

    @PostMapping("")
    @ResponseBody
    public java.util.Map<String, Object> addMPS(MPSDTO mpsDTO) {
        java.util.Map<String, Object> result = new java.util.HashMap<>();
        try {
            mpsService.addMPS(mpsDTO);
            result.put("success", true);
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", e.getMessage());
        }
        return result;
    }

    @PostMapping("/edit")
    @ResponseBody
    public java.util.Map<String, Object> editMPS(MPSDTO mpsDTO) {
        java.util.Map<String, Object> result = new java.util.HashMap<>();
        try {
            mpsService.updateMPS(mpsDTO);
            result.put("success", true);
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", e.getMessage());
        }
        return result;
    }

    @GetMapping("/search")
    public String searchMPS(@RequestParam(required = false) String prodCode,
                           @RequestParam(required = false) String prodName,
                           Model model) {
        java.util.List<MPSDTO> result = mpsService.searchMPS(prodCode, prodName);
        model.addAttribute("list", result);
        return "product/MpsSearchResult";
    }

    @PostMapping("/excel-modal")
    public void downloadExcelFromModal(@RequestParam(value = "prodCode", required = false) String prodCode,
                                       @RequestParam(value = "prodName", required = false) String prodName,
                                       HttpServletResponse response) throws IOException {
        java.util.List<MPSDTO> list = mpsService.searchMPS(prodCode, prodName);
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("MPS검색결과");
        int rowIdx = 0;
        Row header = sheet.createRow(rowIdx++);
        String[] headers = {"제품코드", "제품명", "생산량", "기간(종료날짜)", "생산금액"};
        for (int i = 0; i < headers.length; i++) header.createCell(i).setCellValue(headers[i]);
        for (com.example.demo.model.MPSDTO m : list) {
            Row row = sheet.createRow(rowIdx++);
            row.createCell(0).setCellValue("prod2025" + (m.getProductId() < 10 ? "0" + m.getProductId() : m.getProductId()));
            row.createCell(1).setCellValue(m.getProductName());
            row.createCell(2).setCellValue(m.getVolume());
            row.createCell(3).setCellValue(m.getPeriod());
            row.createCell(4).setCellValue(m.getPrice() * m.getVolume());
        }
        for (int i = 0; i < headers.length; i++) sheet.autoSizeColumn(i);
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=MPS_검색결과.xlsx");
        workbook.write(response.getOutputStream());
        workbook.close();
    }

    @GetMapping("/excel")
    public void downloadExcel(HttpServletResponse response) throws IOException {
        java.util.List<MPSDTO> list = mpsService.getAllMPS();
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("MPS전체리스트");
        int rowIdx = 0;
        Row header = sheet.createRow(rowIdx++);
        String[] headers = {"제품코드", "제품명", "생산량", "기간(종료날짜)", "생산금액"};
        for (int i = 0; i < headers.length; i++) header.createCell(i).setCellValue(headers[i]);
        for (com.example.demo.model.MPSDTO m : list) {
            Row row = sheet.createRow(rowIdx++);
            row.createCell(0).setCellValue("prod2025" + (m.getProductId() < 10 ? "0" + m.getProductId() : m.getProductId()));
            row.createCell(1).setCellValue(m.getProductName());
            row.createCell(2).setCellValue(m.getVolume());
            row.createCell(3).setCellValue(m.getPeriod());
            row.createCell(4).setCellValue(m.getPrice() * m.getVolume());
        }
        for (int i = 0; i < headers.length; i++) sheet.autoSizeColumn(i);
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=MPS_전체리스트.xlsx");
        workbook.write(response.getOutputStream());
        workbook.close();
    }
}