package com.example.demo.controller.main;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.example.demo.service.home.*;

import javax.servlet.http.HttpSession;

@Controller
@RequestMapping("/home")
public class HomeController {
    @Autowired
    private HomeService homeService;

    // 공통 렌더링
    @GetMapping("")
    public String homeList(Model model, HttpSession session) {
        Object user = session.getAttribute("user");
        if (user == null) return "redirect:/login";

        model.addAttribute("homeList", homeService.getHomeList());
        model.addAttribute("active_main", "sales"); // ✅ 기본 탭 활성화
        return "main/Home";
    }


    @GetMapping("/costs")
    public String costs(Model model, HttpSession session){
        model.addAttribute("active_main", "costs"); // ✅ 비용 탭 활성화
        return "main/Home";
    }
   
}