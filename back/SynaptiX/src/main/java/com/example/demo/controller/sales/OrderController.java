package com.example.demo.controller.sales;

import com.example.demo.model.OrderDTO;
import com.example.demo.service.sales.OrderService;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
public class OrderController {
    @Autowired
    private OrderService orderService;

    @GetMapping("/order")
    public String orderList(Model model) {
        List<OrderDTO> orderList = orderService.getAllOrders();
        model.addAttribute("orderList", orderList);
        return "sales/order";
    }

    // 주문 검색 AJAX (모달)
    @GetMapping("/sales/orders/search")
    public String searchOrders(@RequestParam(required = false) String prodCode,
                               @RequestParam(required = false) String prodName,
                               @RequestParam(required = false) String orderDate,
                               @RequestParam(required = false) String status,
                               Model model) {
        Map<String, Object> params = new HashMap<>();
        params.put("prodCode", prodCode);
        params.put("prodName", prodName);
        params.put("orderDate", orderDate);
        params.put("status", status);
        List<OrderDTO> orderList = orderService.searchOrders(params);
        model.addAttribute("orderList", orderList);
        return "sales/OrderModalResult";
    }

    @GetMapping("/sales/orders/excel")
    public void downloadOrderExcel(HttpServletResponse response) throws IOException {
        List<OrderDTO> orderList = orderService.getAllOrders();
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("주문관리");
        int rowIdx = 0;
        Row header = sheet.createRow(rowIdx++);
        String[] headers = {"주문번호", "주문일자", "제품코드", "제품명", "수량", "단가", "금액", "주문상태"};
        for (int i = 0; i < headers.length; i++) header.createCell(i).setCellValue(headers[i]);
        for (OrderDTO order : orderList) {
            Row r = sheet.createRow(rowIdx++);
            r.createCell(0).setCellValue(order.getOrderNo());
            r.createCell(1).setCellValue(order.getOrderDate() != null ? new java.text.SimpleDateFormat("yyyy-MM-dd").format(order.getOrderDate()) : "");
            r.createCell(2).setCellValue("prod2025" + (order.getProdCode() < 10 ? "0" + order.getProdCode() : order.getProdCode()));
            r.createCell(3).setCellValue(order.getProdName() != null ? order.getProdName() : "");
            r.createCell(4).setCellValue(order.getQty());
            r.createCell(5).setCellValue(order.getUnitPrice());
            r.createCell(6).setCellValue(order.getAmount());
            r.createCell(7).setCellValue(order.getStatus() != null ? order.getStatus() : "");
        }
        for (int i = 0; i < headers.length; i++) sheet.autoSizeColumn(i);
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=주문관리_전체리스트.xlsx");
        workbook.write(response.getOutputStream());
        workbook.close();
    }

    @GetMapping("/sales/orders/excel-modal")
    public void downloadOrderExcelModal(
            @RequestParam(required = false) String prodCode,
            @RequestParam(required = false) String prodName,
            @RequestParam(required = false) String orderDate,
            @RequestParam(required = false) String status,
            HttpServletResponse response
    ) throws IOException {
        Map<String, Object> params = new HashMap<>();
        params.put("prodCode", prodCode);
        params.put("prodName", prodName);
        params.put("orderDate", orderDate);
        params.put("status", status);
        List<OrderDTO> orderList = orderService.searchOrders(params);
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("주문관리검색결과");
        int rowIdx = 0;
        Row header = sheet.createRow(rowIdx++);
        String[] headers = {"주문번호", "주문일자", "제품코드", "제품명", "수량", "단가", "금액", "주문상태"};
        for (int i = 0; i < headers.length; i++) header.createCell(i).setCellValue(headers[i]);
        for (OrderDTO order : orderList) {
            Row r = sheet.createRow(rowIdx++);
            r.createCell(0).setCellValue(order.getOrderNo());
            r.createCell(1).setCellValue(order.getOrderDate() != null ? new java.text.SimpleDateFormat("yyyy-MM-dd").format(order.getOrderDate()) : "");
            r.createCell(2).setCellValue("prod2025" + (order.getProdCode() < 10 ? "0" + order.getProdCode() : order.getProdCode()));
            r.createCell(3).setCellValue(order.getProdName() != null ? order.getProdName() : "");
            r.createCell(4).setCellValue(order.getQty());
            r.createCell(5).setCellValue(order.getUnitPrice());
            r.createCell(6).setCellValue(order.getAmount());
            r.createCell(7).setCellValue(order.getStatus() != null ? order.getStatus() : "");
        }
        for (int i = 0; i < headers.length; i++) sheet.autoSizeColumn(i);
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=주문관리_검색결과.xlsx");
        workbook.write(response.getOutputStream());
        workbook.close();
    }
}