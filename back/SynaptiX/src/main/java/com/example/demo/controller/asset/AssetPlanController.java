package com.example.demo.controller.asset;

import com.example.demo.service.asset.AssetPlanService;
import com.example.demo.model.AssetPlanDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Controller
public class AssetPlanController {
    @Autowired
    private AssetPlanService assetPlanService;

    @GetMapping("/assetplan")
    public String getAssetPlanPage(Model model) {
        List<AssetPlanDTO> assetPlans = assetPlanService.getAssetPlans();
        model.addAttribute("assetPlans", assetPlans);
        return "asset/assetplan";
    }

    @GetMapping("/fund/plan/search")
    public String searchAssetPlans(@RequestParam(required = false) String planDate,
                                  @RequestParam(required = false) String productName,
                                  @RequestParam(required = false) String salesQty,
                                  Model model) {
        java.util.Map<String, Object> params = new java.util.HashMap<>();
        params.put("planDate", planDate);
        params.put("productName", productName);
        params.put("salesQty", salesQty);
        java.util.List<com.example.demo.model.AssetPlanDTO> assetPlans = assetPlanService.searchAssetPlans(params);
        model.addAttribute("assetPlans", assetPlans);
        return "asset/AssetPlanModalResult";
    }
}