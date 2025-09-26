package com.example.demo.controller.stock;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import com.example.demo.mapper.stock.ProfitMapper;
import java.util.List;
import java.util.Map;

@Controller
public class ProfitController {
    @Autowired
    private ProfitMapper profitMapper;

    @PreAuthorize("hasAuthority('DEPT_PRODUCTION') or hasAuthority('ROLE_ADMIN')")
    @GetMapping("/profit")
    public String profitPage(
        @RequestParam(value = "item_code", required = false) String itemCode,
        @RequestParam(value = "item_name", required = false) String itemName,
        @RequestParam(value = "category", required = false) String category,
        Model model) {
        List<Map<String, Object>> profitList = profitMapper.selectProfitList(itemCode, itemName, category);
        model.addAttribute("profitList", profitList);
        return "stock/profit";
    }
}