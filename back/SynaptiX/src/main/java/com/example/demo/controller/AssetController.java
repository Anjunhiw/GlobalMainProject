package com.example.demo.controller;

import com.example.demo.model.AssetDTO;
import com.example.demo.service.AssetService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class AssetController {
    @Autowired
    private AssetService assetService;

    @GetMapping("/managereport")
    public String getManageReport(Model model) {
        AssetDTO asset = assetService.getAsset();
        model.addAttribute("asset", asset);
        return "managereport";
    }
}
