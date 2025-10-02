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
    public DartResponse getFinance(@RequestParam(defaultValue = "2023") String year,
                                   @RequestParam(required = false) String reprt_code) {
        if (reprt_code != null && !reprt_code.isEmpty()) {
            return dartApiService.getFinancialData(year, reprt_code);
        } else {
            return dartApiService.getFinancialData(year);
        }
    }
}