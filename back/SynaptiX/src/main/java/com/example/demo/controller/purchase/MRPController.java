package com.example.demo.controller.purchase;

import com.example.demo.mapper.purchase.MRPMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;
import java.util.Map;

@Controller
public class MRPController {
    @Autowired
    private MRPMapper mrpMapper;

    @GetMapping("/mrp")
    public String mrpList(Model model) {
        List<Map<String, Object>> mrpList = mrpMapper.selectAllMRP();
        model.addAttribute("mrpList", mrpList);
        return "purchase/mrp";
    }

    @GetMapping("/mrp/search")
    public String searchMrp(@RequestParam(required = false) String prodCode,
                           @RequestParam(required = false) String prodName,
                           @RequestParam(required = false) String inDate,
                           @RequestParam(required = false) String mrpStatus,
                           Model model) {
        java.util.Map<String, Object> params = new java.util.HashMap<>();
        params.put("prodCode", prodCode);
        params.put("prodName", prodName);
        params.put("inDate", inDate);
        params.put("mrpStatus", mrpStatus);
        java.util.List<java.util.Map<String, Object>> mrpList = mrpMapper.searchMRP(params);
        model.addAttribute("mrpList", mrpList);
        return "purchase/MrpModalResult";
    }
}