package com.example.demo.controller.product;

import com.example.demo.model.MPSDTO;
import com.example.demo.service.product.MPSService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
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

    @PostMapping("")
    @ResponseBody
    public java.util.Map<String, Object> addMPS(MPSDTO mpsDTO) {
        java.util.Map<String, Object> result = new java.util.HashMap<>();
        try {
            mpsService.addMPS(mpsDTO);
            result.put("success", true);
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", e.getMessage());
        }
        return result;
    }

    @PostMapping("/edit")
    @ResponseBody
    public java.util.Map<String, Object> editMPS(MPSDTO mpsDTO) {
        java.util.Map<String, Object> result = new java.util.HashMap<>();
        try {
            mpsService.updateMPS(mpsDTO);
            result.put("success", true);
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", e.getMessage());
        }
        return result;
    }

    @GetMapping("/search")
    @ResponseBody
    public java.util.List<MPSDTO> searchMPS(@RequestParam(required = false) String prodCode,
                                            @RequestParam(required = false) String prodName) {
        return mpsService.searchMPS(prodCode, prodName);
    }
}