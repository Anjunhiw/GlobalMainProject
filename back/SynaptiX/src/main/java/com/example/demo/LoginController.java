package com.example.demo;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.beans.factory.annotation.Autowired;
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
	
	@PostMapping("")
	public String login(@ModelAttribute LoginDTO loginDTO, Model model) {
		model.addAttribute("login", loginService.getData());
		return "Home";
	}
}
