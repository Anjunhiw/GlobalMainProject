package com.example.demo.controller.user;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;



@Controller
public class UserEditController {
    @PreAuthorize("hasAuthority('RANK_WRITE') or hasAuthority('ROLE_ADMIN')")
    @GetMapping("/useredit")
    public String userEditPage() {
        return "user/UserEdit";
    }
}