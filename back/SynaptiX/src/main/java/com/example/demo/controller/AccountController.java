package com.example.demo.controller;



import com.example.demo.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
public class AccountController {

    @Autowired
    private UserService userService;

    // 아이디 찾기 화면
    @GetMapping("/findId")
    public String findIdForm() {
        return "FindId"; // /WEB-INF/views/FindId.jsp
    }

    // 아이디 찾기 처리
    @PostMapping("/findId")
    public String findIdSubmit(@RequestParam String name,
                               @RequestParam String email,
                               Model model) {
        String userId = userService.findUserIdByEmailAndName(email, name);
        if (userId != null) {
            model.addAttribute("result", userId);
        } else {
            model.addAttribute("error", "일치하는 정보가 없습니다.");
        }
        return "FindId";
    }
    
    
    
}