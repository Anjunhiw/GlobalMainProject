package com.example.demo.controller;

import com.example.demo.model.QCDTO;
import com.example.demo.service.QCService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@Controller
@RequestMapping("/qc")
public class QCController {
    @Autowired
    private QCService qcService;

    @GetMapping("")
    public String showQC(Model model) {
        model.addAttribute("list", qcService.getAllQC());
        return "qc";
    }

    @PostMapping
    public void addQC(@RequestBody QCDTO qcDTO) {
        qcService.addQC(qcDTO);
    }
}