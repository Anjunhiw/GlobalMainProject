package com.example.demo.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.example.demo.model.UserDTO;
import com.example.demo.service.UserService;

@Controller
@RequestMapping("/register")
public class RegisterController {

  
    @Autowired
    private UserService userService;
	
    @GetMapping("")
    public String registerForm() {
        return "Register";
    }

    @PostMapping("")
    public String submit(@ModelAttribute UserDTO user, Model model) {
        boolean ok = userService.registerUser(user);
        if (ok) {
            model.addAttribute("message", "회원가입이 완료되었습니다. 로그인 해주세요.");
            return "redirect:/login";
        } else {
            model.addAttribute("message", "회원가입 중 오류가 발생했습니다.");
            return "Register";
        }
    }
  
}
