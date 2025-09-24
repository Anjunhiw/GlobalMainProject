package com.example.demo.controller.personal;

import com.example.demo.model.UserDTO;
import com.example.demo.service.user.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("")
public class HrmController {
    @Autowired
    private UserService userService;

    @GetMapping("/hrm")
    public String getHrmPage(Model model) {
        java.util.List<UserDTO> employees = userService.getAllUsers();
        model.addAttribute("employees", employees);
        return "personal/hrm";
    }
}
