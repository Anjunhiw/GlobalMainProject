package com.example.demo.controller.product;

import com.example.demo.model.QCDTO;
import com.example.demo.service.product.QCService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.access.prepost.PreAuthorize;

@PreAuthorize("hasAuthority('DEPT_PRODUCTION') or hasAuthority('ROLE_ADMIN')")
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

    @PostMapping("/search")
    @ResponseBody
    public java.util.List<QCDTO> searchQC(@RequestBody java.util.Map<String, String> params) {
        String dateFrom = params.get("dateFrom");
        String dateTo = params.get("dateTo");
        String prodName = params.get("prodName");
        String category = params.get("category");
        return qcService.searchQC(dateFrom, dateTo, prodName, category);
    }

    @PostMapping("")
    @ResponseBody
    public java.util.Map<String, Object> addQC(@RequestBody QCDTO qcDTO) {
        System.out.println("QC 등록 요청: mpsId=" + qcDTO.getMpsId() + ", passed=" + qcDTO.isPassed());
        java.util.Map<String, Object> result = new java.util.HashMap<>();
        try {
            qcService.addQC(qcDTO);
            result.put("success", true);
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", e.getMessage());
        }
        return result;
    }
}