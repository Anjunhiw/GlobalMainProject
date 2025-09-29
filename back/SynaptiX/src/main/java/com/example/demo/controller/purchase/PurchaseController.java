package com.example.demo.controller.purchase;

import com.example.demo.model.PurchaseDTO;
import com.example.demo.service.purchase.PurchaseService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Controller
public class PurchaseController {
    @Autowired
    private PurchaseService purchaseService;

    @GetMapping("/purchase")
    public String purchaseList(Model model) {
        List<PurchaseDTO> purchaseList = purchaseService.getAllPurchases();
        model.addAttribute("purchaseList", purchaseList);
        return "purchase/Purchase";
    }

    @GetMapping("/purchase/in/search")
    public String searchPurchases(@RequestParam(required = false) String prodCode,
                                  @RequestParam(required = false) String prodName,
                                  @RequestParam(required = false) String inDate,
                                  @RequestParam(required = false) String mrpStatus,
                                  Model model) {
        java.util.Map<String, Object> params = new java.util.HashMap<>();
        params.put("prodCode", prodCode);
        params.put("prodName", prodName);
        params.put("inDate", inDate);
        params.put("mrpStatus", mrpStatus);
        java.util.List<com.example.demo.model.PurchaseDTO> purchaseList = purchaseService.searchPurchases(params);
        model.addAttribute("purchaseList", purchaseList);
        return "purchase/PurchaseModalResult";
    }
}