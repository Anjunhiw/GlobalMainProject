package com.example.demo.controller.common;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.ui.Model;

@Controller
public class ErrorController {
    @GetMapping("/access-denied")
    public String accessDenied(Model model) {
        model.addAttribute("message", "권한이 없습니다. 관리자에게 문의하세요.");
        return "error/accessDenied";
    }
}
