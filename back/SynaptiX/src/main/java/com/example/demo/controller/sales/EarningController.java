package com.example.demo.controller.sales;

import com.example.demo.mapper.sales.EarningMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;
import java.util.Map;

@Controller
public class EarningController {
    @Autowired
    private EarningMapper earningMapper;

    @GetMapping("/earning")
    public String earningList(Model model) {
        List<Map<String, Object>> earningList = earningMapper.selectAllEarnings();
        model.addAttribute("earningList", earningList);
        return "sales/earning";
    }

    @GetMapping("/sales/earning/search")
    public String searchEarnings(@RequestParam(required = false) String prodCode,
                                 @RequestParam(required = false) String prodName,
                                 @RequestParam(required = false) String qc,
                                 @RequestParam(required = false) String startDate,
                                 @RequestParam(required = false) String endDate,
                                 Model model) {
        java.util.Map<String, Object> params = new java.util.HashMap<>();
        params.put("prodCode", prodCode);
        params.put("prodName", prodName);
        params.put("qc", qc);
        params.put("startDate", startDate);
        params.put("endDate", endDate);
        List<Map<String, Object>> earningList = earningMapper.searchEarnings(params);
        model.addAttribute("earningList", earningList);
        return "sales/EarningModalResult";
    }
}