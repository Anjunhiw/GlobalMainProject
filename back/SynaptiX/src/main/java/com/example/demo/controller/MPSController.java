package com.example.demo.controller;

import com.example.demo.model.MPSDTO;
import com.example.demo.service.MPSService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@Controller
@RequestMapping("/mps")
public class MPSController {
    @Autowired
    private MPSService mpsService;

    @GetMapping("")
    public String showMPS(Model model) {
        model.addAttribute("list", mpsService.getAllMPS());
        return "mps";
    }

    @PostMapping
    public void addMPS(@RequestBody MPSDTO mpsDTO) {
        mpsService.addMPS(mpsDTO);
    }
}