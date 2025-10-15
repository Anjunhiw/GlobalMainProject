package com.example.demo.controller.asset;

import com.example.demo.model.PurchaseDTO;
import com.example.demo.service.asset.CostConService;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import javax.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.io.IOException;
import java.util.List;

@Controller
public class CostConController {
    @Autowired
    private CostConService costConService;

    @GetMapping("/costcon")
    public String showCostConPage(
            @RequestParam(value = "startDate", required = false) String startDate,
            @RequestParam(value = "endDate", required = false) String endDate,
            @RequestParam(value = "mtrName", required = false) String materialName,
            Model model) {
        List<PurchaseDTO> costList = costConService.getCostConList(startDate, endDate, materialName);
        model.addAttribute("costList", costList);
        model.addAttribute("startDate", startDate);
        model.addAttribute("endDate", endDate);
        model.addAttribute("mtrName", materialName);
        return "asset/costcon";
    }

    @GetMapping("/fund/cost/search")
    public String searchCostConList(@RequestParam(required = false) String startDate,
                                    @RequestParam(required = false) String endDate,
                                    @RequestParam(required = false) String mtrName,
                                    Model model) {
        java.util.Map<String, Object> params = new java.util.HashMap<>();
        params.put("startDate", startDate);
        params.put("endDate", endDate);
        params.put("mtrName", mtrName);
        java.util.List<com.example.demo.model.PurchaseDTO> costList = costConService.searchCostConList(params);
        model.addAttribute("costList", costList);
        return "asset/CostConModalResult";
    }

    @GetMapping("/fund/cost/excel")
    public void downloadCostExcel(@RequestParam(value = "startDate", required = false) String startDate,
                                  @RequestParam(value = "endDate", required = false) String endDate,
                                  @RequestParam(value = "mtrName", required = false) String mtrName,
                                  HttpServletResponse response) throws IOException {
        // 전체 데이터 다운로드: 파라미터를 빈 값으로 설정
        startDate = "";
        endDate = "";
        mtrName = "";
        List<PurchaseDTO> costList = costConService.getCostConList(startDate, endDate, mtrName);
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("비용지출내역");
        int rowIdx = 0;
        Row header = sheet.createRow(rowIdx++);
        String[] headers = {"구매일자", "원자재명", "구매량", "단가", "구매금액"};
        for (int i = 0; i < headers.length; i++) header.createCell(i).setCellValue(headers[i]);
        for (PurchaseDTO dto : costList) {
            Row row = sheet.createRow(rowIdx++);
            row.createCell(0).setCellValue(dto.getDate() != null ? dto.getDate().toString() : "");
            row.createCell(1).setCellValue(dto.getMaterialName());
            row.createCell(2).setCellValue(dto.getPurchase());
            row.createCell(3).setCellValue(dto.getPrice());
            row.createCell(4).setCellValue(dto.getCost());
        }
        for (int i = 0; i < headers.length; i++) sheet.autoSizeColumn(i);
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=비용지출내역.xlsx");
        workbook.write(response.getOutputStream());
        workbook.close();
    }

    @GetMapping("/fund/cost/excel-modal")
    public void downloadCostExcelModal(@RequestParam(value = "startDate", required = false) String startDate,
                                       @RequestParam(value = "endDate", required = false) String endDate,
                                       @RequestParam(value = "mtrName", required = false) String mtrName,
                                       HttpServletResponse response) throws IOException {
        List<PurchaseDTO> costList = costConService.searchCostConList(java.util.Map.of(
            "startDate", startDate,
            "endDate", endDate,
            "mtrName", mtrName
        ));
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("검색결과_비용지출내역");
        int rowIdx = 0;
        Row header = sheet.createRow(rowIdx++);
        String[] headers = {"구매일자", "원자재명", "구매량", "단가", "구매금액"};
        for (int i = 0; i < headers.length; i++) header.createCell(i).setCellValue(headers[i]);
        for (PurchaseDTO dto : costList) {
            Row row = sheet.createRow(rowIdx++);
            row.createCell(0).setCellValue(dto.getDate() != null ? dto.getDate().toString() : "");
            row.createCell(1).setCellValue(dto.getMaterialName());
            row.createCell(2).setCellValue(dto.getPurchase());
            row.createCell(3).setCellValue(dto.getPrice());
            row.createCell(4).setCellValue(dto.getCost());
        }
        for (int i = 0; i < headers.length; i++) sheet.autoSizeColumn(i);
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=검색결과_비용지출내역.xlsx");
        workbook.write(response.getOutputStream());
        workbook.close();
    }
}