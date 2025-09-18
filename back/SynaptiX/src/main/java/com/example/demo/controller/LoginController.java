package com.example.demo.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMethod;

import com.example.demo.mapper.*;
import com.example.demo.model.*;
import com.example.demo.service.*;

import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import java.util.Collections;



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
	public String login(@ModelAttribute LoginDTO loginDTO, Model model, HttpServletRequest request, HttpServletResponse response) {
		System.out.println("로그인 시도: id=" + loginDTO.getId() + ", pw=" + loginDTO.getPw());
		String token = loginService.authenticateAndGetToken(loginDTO.getId(), loginDTO.getPw());
		LoginDTO userInfo = loginService.getUserInfo(loginDTO.getId());
		if (token != null) {
			// JWT 토큰을 쿠키에 저장
			Cookie jwtCookie = new Cookie("jwtToken", token);
			jwtCookie.setHttpOnly(true);
			jwtCookie.setPath("/");
			jwtCookie.setMaxAge(60 * 60); // 1시간
			response.addCookie(jwtCookie);
			// 세션 ID 재발급
			HttpSession session = request.getSession(false);
			if (session != null) session.invalidate();
			HttpSession newSession = request.getSession(true);
			newSession.setAttribute("user", userInfo);
			model.addAttribute("user", userInfo);
			model.addAttribute("id", userInfo.getId());
			model.addAttribute("name", userInfo.getName());

            // Spring Security 인증 객체 생성 및 등록
            UsernamePasswordAuthenticationToken authentication =
                new UsernamePasswordAuthenticationToken(
                    userInfo.getId(), // principal (userId)
                    null, // credentials
                    Collections.singletonList(new SimpleGrantedAuthority("ROLE_USER")) // 권한
                );
            SecurityContextHolder.getContext().setAuthentication(authentication);

			return "redirect:/home";
		} else {
			model.addAttribute("error", "아이디 또는 비밀번호가 올바르지 않습니다.");
			return "Login";
		}
	}
	
	@RequestMapping(value = "/logout", method = RequestMethod.GET)
	public String logout(HttpSession session, Model model, HttpServletResponse response, HttpServletRequest request) {
		// 세션 무효화
		session.invalidate();
		model.addAttribute("user", null);
		// JWT 토큰 쿠키 삭제
		Cookie jwtCookie = new Cookie("jwtToken", "");
		jwtCookie.setPath("/");
		jwtCookie.setMaxAge(0); // 즉시 만료
		jwtCookie.setHttpOnly(true);
		response.addCookie(jwtCookie);

		// JSESSIONID 쿠키 삭제 (브라우저에 남아있을 수 있으므로 명시적으로 삭제)
		Cookie jsessionCookie = new Cookie("JSESSIONID", "");
		jsessionCookie.setPath("/");
		jsessionCookie.setMaxAge(0);
		response.addCookie(jsessionCookie);

		// 세션이 새로 생성되지 않도록 리다이렉트 사용
		return "redirect:/home";
	}
}