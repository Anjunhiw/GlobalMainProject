package com.example.demo.controller.product;

import com.example.demo.model.MPSDTO;
import com.example.demo.service.product.MPSService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/mps")
public class MPSController {
    @Autowired
    private MPSService mpsService;

    @GetMapping("")
    public String showMPS(Model model) {
        model.addAttribute("list", mpsService.getAllMPS());
        return "product/mps";
    }

    @PostMapping
    public void addMPS(@RequestBody MPSDTO mpsDTO) {
        mpsService.addMPS(mpsDTO);
    }
}
