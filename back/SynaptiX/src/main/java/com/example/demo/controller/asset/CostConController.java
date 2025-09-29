package com.example.demo.controller.asset;

import com.example.demo.model.PurchaseDTO;
import com.example.demo.service.asset.CostConService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Controller
public class CostConController {
    @Autowired
    private CostConService costConService;

    @GetMapping("/costcon")
    public String showCostConPage(
            @RequestParam(value = "startDate", required = false) String startDate,
            @RequestParam(value = "endDate", required = false) String endDate,
            @RequestParam(value = "mtrName", required = false) String materialName,
            Model model) {
        List<PurchaseDTO> costList = costConService.getCostConList(startDate, endDate, materialName);
        model.addAttribute("costList", costList);
        model.addAttribute("startDate", startDate);
        model.addAttribute("endDate", endDate);
        model.addAttribute("mtrName", materialName);
        return "asset/costcon";
    }

    @GetMapping("/fund/cost/search")
    public String searchCostConList(@RequestParam(required = false) String startDate,
                                    @RequestParam(required = false) String endDate,
                                    @RequestParam(required = false) String mtrName,
                                    Model model) {
        java.util.Map<String, Object> params = new java.util.HashMap<>();
        params.put("startDate", startDate);
        params.put("endDate", endDate);
        params.put("mtrName", mtrName);
        java.util.List<com.example.demo.model.PurchaseDTO> costList = costConService.searchCostConList(params);
        model.addAttribute("costList", costList);
        return "asset/CostConModalResult";
    }
}