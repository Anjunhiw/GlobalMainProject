package com.example.demo.controller.sales;

import com.example.demo.mapper.sales.EarningMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
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
}