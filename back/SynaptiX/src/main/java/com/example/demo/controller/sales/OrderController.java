package com.example.demo.controller.sales;

import com.example.demo.mapper.sales.OrderMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import java.util.List;
import java.util.Map;

@Controller
public class OrderController {
    @Autowired
    private OrderMapper orderMapper;

    @GetMapping("/order")
    public String orderList(Model model) {
        List<Map<String, Object>> orderList = orderMapper.selectAllOrders();
        model.addAttribute("orderList", orderList);
        return "sales/order";
    }
}