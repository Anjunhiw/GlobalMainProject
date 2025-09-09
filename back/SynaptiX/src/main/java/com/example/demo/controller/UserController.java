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

    @GetMapping("/findId")
    public String showFindIdForm() {
        return "FindId"; // FindId.jsp로 이동
    }

    @PostMapping("/findId")
    public String findId(String email, String name, Model model) {
        String userId = userService.findUserIdByEmailAndName(email, name);
        if (userId != null) {
            model.addAttribute("message", "아이디는: " + userId + " 입니다.");
        } else {
            model.addAttribute("message", "일치하는 정보가 없습니다.");
        }
        return "FindId";
    }

    @GetMapping("/findPassword")
    public String showFindPasswordForm() {
        return "FindPassword"; // FindPassword.jsp로 이동
    }

    @PostMapping("/findPassword")
    public String findPassword(String userId, String email, Model model) {
        boolean success = userService.verifyUserForPasswordReset(userId, email);
        if (success) {
            // 실제 서비스에서는 임시 비밀번호 발급 또는 이메일 전송 등 추가 구현 필요
            model.addAttribute("message", "비밀번호 재설정이 가능합니다. 관리자에게 문의하세요.");
        } else {
            model.addAttribute("message", "일치하는 정보가 없습니다.");
        }
        return "FindPassword";
    }
}