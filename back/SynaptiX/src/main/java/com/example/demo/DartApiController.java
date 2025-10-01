package com.example.demo;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class DartApiController {
    private final DartApiService dartApiService;

    @Autowired
    public DartApiController(DartApiService dartApiService) {
        this.dartApiService = dartApiService;
    }

    @GetMapping("/api/dart/finance")
    public DartResponse getFinance(@RequestParam(defaultValue = "2023") String year) {
        return dartApiService.getFinancialData(year);
    }
}