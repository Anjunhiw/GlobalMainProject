package com.example.demo.controller;

import com.example.demo.DartApiService;
import com.example.demo.DartResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class DartFinanceTestController {
    private final DartApiService dartApiService;

    @Autowired
    public DartFinanceTestController(DartApiService dartApiService) {
        this.dartApiService = dartApiService;
    }

    @RequestMapping("/dartFinanceTest.do")
    public String showFinanceTest(@RequestParam(defaultValue = "2023") String year, Model model) {
        DartResponse response = dartApiService.getFinancialData(year);
        model.addAttribute("year", year);
        model.addAttribute("response", response);
        return "dartFinanceTest";
    }
}