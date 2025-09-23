package com.example.demo.controller.stock;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import com.example.demo.mapper.stock.ProfitMapper;
import java.util.List;
import java.util.Map;

@Controller
public class ProfitController {
    @Autowired
    private ProfitMapper profitMapper;

    @GetMapping("/profit")
    public String profitPage(Model model) {
        List<Map<String, Object>> profitList = profitMapper.selectProfitList();
        model.addAttribute("profitList", profitList);
        return "stock/profit";
    }
}
