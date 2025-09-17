package com.example.demo.controller;

import com.example.demo.mapper.MRPMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
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
        return "mrp";
    }
}
