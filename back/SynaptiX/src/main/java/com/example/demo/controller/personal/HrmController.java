package com.example.demo.controller.personal;

import com.example.demo.model.UserDTO;
import com.example.demo.service.user.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

@PreAuthorize("hasAuthority('DEPT_HR') or hasAuthority('ROLE_ADMIN')")
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

    @GetMapping("/hr/search")
    public String searchEmployees(@RequestParam(required = false) String dept,
                                 @RequestParam(required = false) String position,
                                 @RequestParam(required = false) String empName,
                                 Model model) {
        java.util.Map<String, Object> params = new java.util.HashMap<>();
        params.put("dept", dept);
        params.put("position", position);
        params.put("empName", empName);
        java.util.List<com.example.demo.model.UserDTO> employees = userService.searchUsers(params);
        model.addAttribute("employees", employees);
        return "personal/HrmModalResult";
    }
}