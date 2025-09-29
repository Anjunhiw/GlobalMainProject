package com.example.demo.controller.sales;

import com.example.demo.model.Sales;
import com.example.demo.service.sales.SalesService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;
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

    @GetMapping("/sales/outbound")
    public String searchSales(
            @RequestParam(required = false) String code,
            @RequestParam(required = false) String name,
            @RequestParam(required = false) String outDate,
            @RequestParam(required = false) String category,
            Model model,
            HttpServletRequest request
    ) {
        List<Sales> salesList = salesService.searchSales(code, name, outDate, category);
        model.addAttribute("salesList", salesList);
        // AJAX 요청이면 fragment만 반환
        if ("XMLHttpRequest".equals(request.getHeader("X-Requested-With"))) {
            return "sales/SalesModalResult";
        }
        // 일반 요청이면 전체 페이지 반환(예외적 상황)
        return "sales/Sales";
    }
}