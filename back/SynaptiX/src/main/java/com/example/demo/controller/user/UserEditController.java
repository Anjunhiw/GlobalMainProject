package com.example.demo.controller.user;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;



@Controller
public class UserEditController {
    @GetMapping("/useredit")
    public String userEditPage() {
        return "user/UserEdit";
    }
}