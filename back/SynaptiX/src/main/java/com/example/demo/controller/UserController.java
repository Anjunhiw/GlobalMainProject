package com.example.demo.controller;

import com.example.demo.dto.UserDTO;
import com.example.demo.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/user")
public class UserController {
    @Autowired
    private UserService userService;

    @GetMapping("/register")
    public String showRegisterForm() {
        return "Register"; // Register.jsp로 이동
    }

    @PostMapping("/register")
    public String register(UserDTO userDto, Model model) {
        boolean success = userService.registerUser(userDto);
        if (success) {
            model.addAttribute("message", "회원가입이 완료되었습니다.");
            return "Login"; // 회원가입 성공 시 로그인 페이지로 이동
        } else {
            model.addAttribute("message", "회원가입에 실패했습니다.");
            return "Register";
        }
    }
}