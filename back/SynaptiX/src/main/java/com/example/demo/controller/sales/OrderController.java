package com.example.demo.controller.sales;

import com.example.demo.service.sales.OrderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
public class OrderController {
    @Autowired
    private OrderService orderService;

    @GetMapping("/order")
    public String orderList(Model model) {
        List<Map<String, Object>> orderList = orderService.getAllOrders();
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
        List<Map<String, Object>> orderList = orderService.searchOrders(params);
        model.addAttribute("orderList", orderList);
        return "sales/OrderModalResult";
    }
}