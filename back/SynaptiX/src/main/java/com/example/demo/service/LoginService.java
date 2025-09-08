package com.example.demo.service;

import com.example.demo.model.LoginDTO;
import com.example.demo.mapper.LoginMapper;
import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Autowired;
import com.example.demo.util.JWTUtil;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

@Service
public class LoginService {
	@Autowired
	private LoginMapper loginMapper;
	
	private BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
	
	public LoginDTO getData() {
		return loginMapper.selectName();
	}
	
	public LoginDTO authenticate(String id, String pw) {
		return loginMapper.selectByIdAndPw(id, pw);
	}
	
	public LoginDTO getUserInfo(String id) {
		return loginMapper.selectById(id);
	}
	
	public String authenticateAndGetToken(String id, String pw) {
		LoginDTO user = authenticate(id, pw);
		if (user != null) {
			// id와 name을 JWTUtil.generateToken에 전달
			return JWTUtil.generateToken(user.getId(), user.getName());
		}
		return null;
	}
}