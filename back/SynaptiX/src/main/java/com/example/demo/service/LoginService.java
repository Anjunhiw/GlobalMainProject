package com.example.demo.service;

import com.example.demo.model.LoginDTO;
import com.example.demo.mapper.LoginMapper;
import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Autowired;

@Service
public class LoginService {
	@Autowired
	private LoginMapper loginMapper;
	
	public LoginDTO getData() {
		return loginMapper.selectName();
	}
}
