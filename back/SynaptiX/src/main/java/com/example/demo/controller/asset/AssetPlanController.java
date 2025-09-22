package com.example.demo.controller.asset;

import com.example.demo.service.asset.AssetPlanService;
import com.example.demo.model.AssetPlanDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
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
}
