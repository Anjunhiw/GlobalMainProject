package com.example.demo.controller.product;

import com.example.demo.model.QCDTO;
import com.example.demo.service.product.QCService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/qc")
public class QCController {
    @Autowired
    private QCService qcService;

    @GetMapping("")
    public String showQC(Model model) {
        model.addAttribute("list", qcService.getAllQC());
        return "product/qc";
    }

    @PostMapping
    public void addQC(@RequestBody QCDTO qcDTO) {
        qcService.addQC(qcDTO);
    }
}
