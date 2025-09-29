package com.example.demo.controller.asset;

import com.example.demo.model.AssetDTO;
import com.example.demo.service.asset.AssetService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class AssetController {
    @Autowired
    private AssetService assetService;

    @GetMapping("/managereport")
    public String getManageReport(Model model) {
        AssetDTO asset = assetService.getAsset();
        model.addAttribute("asset", asset);
        return "asset/managereport";
    }

    @GetMapping("/fund/report/search")
    public String searchAsset(@RequestParam(required = false) String startDate,
                             @RequestParam(required = false) String endDate,
                             Model model) {
        java.util.Map<String, Object> params = new java.util.HashMap<>();
        params.put("startDate", startDate);
        params.put("endDate", endDate);
        com.example.demo.model.AssetDTO asset = assetService.searchAsset(params);
        model.addAttribute("asset", asset);
        return "asset/ManageReportModalResult";
    }
}