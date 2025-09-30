package com.example.demo.controller.personal;

import com.example.demo.model.UserDTO;
import com.example.demo.service.user.UserService;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@PreAuthorize("hasAuthority('DEPT_HR') or hasAuthority('ROLE_ADMIN')")
@Controller
@RequestMapping("")
public class HrmController {
    @Autowired
    private UserService userService;

    @GetMapping("/hrm")
    public String getHrmPage(Model model) {
        java.util.List<UserDTO> employees = userService.getAllUsers();
        model.addAttribute("employees", employees);
        return "personal/hrm";
    }

    @GetMapping("/hr/search")
    public String searchEmployees(@RequestParam(required = false) String dept,
                                 @RequestParam(required = false) String position,
                                 @RequestParam(required = false) String empName,
                                 Model model) {
        java.util.Map<String, Object> params = new java.util.HashMap<>();
        params.put("dept", dept);
        params.put("position", position);
        params.put("empName", empName);
        java.util.List<com.example.demo.model.UserDTO> employees = userService.searchUsers(params);
        model.addAttribute("employees", employees);
        return "personal/HrmModalResult";
    }

    @GetMapping("/hrm/excel")
    public void downloadHrmExcel(HttpServletResponse response) throws IOException {
        java.util.List<UserDTO> employees = userService.getAllUsers();
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("인사내역");
        int rowIdx = 0;
        Row header = sheet.createRow(rowIdx++);
        String[] headers = {"사번", "이름", "생년월일", "이메일", "부서명", "직급", "근속년수", "급여"};
        for (int i = 0; i < headers.length; i++) header.createCell(i).setCellValue(headers[i]);
        for (UserDTO emp : employees) {
            Row row = sheet.createRow(rowIdx++);
            row.createCell(0).setCellValue(emp.getUserId());
            row.createCell(1).setCellValue(emp.getName());
            row.createCell(2).setCellValue(emp.getBirth() != null ? emp.getBirth().toString() : "");
            row.createCell(3).setCellValue(emp.getEmail());
            row.createCell(4).setCellValue(emp.getDept());
            row.createCell(5).setCellValue(emp.getRank());
            row.createCell(6).setCellValue(emp.getYears());
            row.createCell(7).setCellValue(emp.getSalary());
        }
        for (int i = 0; i < headers.length; i++) sheet.autoSizeColumn(i);
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=인사내역.xlsx");
        workbook.write(response.getOutputStream());
        workbook.close();
    }

    @GetMapping("/hrm/excel-modal")
    public void downloadHrmExcelModal(@RequestParam(required = false) String dept,
                                      @RequestParam(required = false) String position,
                                      @RequestParam(required = false) String empName,
                                      HttpServletResponse response) throws IOException {
        java.util.Map<String, Object> params = new java.util.HashMap<>();
        params.put("dept", dept);
        params.put("position", position);
        params.put("empName", empName);
        java.util.List<UserDTO> employees = userService.searchUsers(params);
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("검색결과_인사내역");
        int rowIdx = 0;
        Row header = sheet.createRow(rowIdx++);
        String[] headers = {"사번", "이름", "생년월일", "이메일", "부서명", "직급", "근속년수", "급여"};
        for (int i = 0; i < headers.length; i++) header.createCell(i).setCellValue(headers[i]);
        for (UserDTO emp : employees) {
            Row row = sheet.createRow(rowIdx++);
            row.createCell(0).setCellValue(emp.getUserId());
            row.createCell(1).setCellValue(emp.getName());
            row.createCell(2).setCellValue(emp.getBirth() != null ? emp.getBirth().toString() : "");
            row.createCell(3).setCellValue(emp.getEmail());
            row.createCell(4).setCellValue(emp.getDept());
            row.createCell(5).setCellValue(emp.getRank());
            row.createCell(6).setCellValue(emp.getYears());
            row.createCell(7).setCellValue(emp.getSalary());
        }
        for (int i = 0; i < headers.length; i++) sheet.autoSizeColumn(i);
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=검색결과_인사내역.xlsx");
        workbook.write(response.getOutputStream());
        workbook.close();
    }
}