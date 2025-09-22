package com.example.demo.controller.sales;

import com.example.demo.model.Sales;
import com.example.demo.service.sales.SalesService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
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
}