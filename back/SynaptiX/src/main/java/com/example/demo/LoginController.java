package com.example.demo;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ModelAttribute;

import com.example.demo.mapper.*;
import com.example.demo.model.*;
import com.example.demo.service.*;



@Controller
@RequestMapping("/login")
public class LoginController {

	@Autowired
	private LoginService loginService;
	
	@GetMapping("")
	public String loginForm(Model model) {
		return "Login";
	}
	
	@PostMapping("")
	public String login(@ModelAttribute LoginDTO loginDTO, Model model) {
		System.out.println("로그인 시도: id=" + loginDTO.getId() + ", pw=" + loginDTO.getPw());
		LoginDTO user = loginService.authenticate(loginDTO.getId(), loginDTO.getPw());
		System.out.println("DB 조회 결과: " + user);
		if (user != null) {
			model.addAttribute("user", user);
			model.addAttribute("id", user.getId());
			model.addAttribute("name", user.getName());
			return "Home";
		} else {
			model.addAttribute("error", "아이디 또는 비밀번호가 올바르지 않습니다.");
			return "Login";
		}
	}
}