package com.example.demo.service;

import com.example.demo.model.UserDTO;
import com.example.demo.mapper.UserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class UserService {
    @Autowired
    private UserMapper userMapper;

    private BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    public boolean registerUser(UserDTO userDto) {
        // 비밀번호 해시 처리
        String encodedPassword = passwordEncoder.encode(userDto.getPassword());
        System.out.println("서비스");
        userDto.setPassword(encodedPassword);
        // DB 저장
        int result = userMapper.insertUser(userDto);
        return result > 0;
    }

    public String findUserIdByEmailAndName(String email, String name) {
        return userMapper.findUserIdByEmailAndName(email, name);
    }

    public boolean verifyUserForPasswordReset(String userId, String email) {
        return userMapper.verifyUserForPasswordReset(userId, email) > 0;
    }

    public java.util.List<UserDTO> getAllUsers() {
        return userMapper.selectAllUsers();
    }

    public boolean isUserIdDuplicate(String userId) {
        return userMapper.findByUserId(userId) != null;
    }
}