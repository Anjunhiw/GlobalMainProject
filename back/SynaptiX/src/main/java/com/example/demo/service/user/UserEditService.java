package com.example.demo.service.user;

import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Autowired;
import com.example.demo.mapper.user.UserMapper;
import com.example.demo.model.UserDTO;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

@Service
public class UserEditService {
    @Autowired
    private UserMapper userMapper;

    private BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    public UserDTO getUserById(String userId) {
        return userMapper.findByUserId(userId);
    }

    public int updateUser(UserDTO user) {
        // UserMapper에 updateUser 메서드가 없으면 추가 필요
        return userMapper.updateUser(user);
    }

    public int updatePassword(String userId, String encodedPassword) {
        return userMapper.updatePassword(userId, encodedPassword);
    }

    /**
     * 비밀번호 변경 로직: 현재 비밀번호 검증, 새 비밀번호 정책 체크, 암호화 후 저장
     * 성공 시 null, 실패 시 에러 메시지 반환
     */
    public String changePassword(String userId, String currentPassword, String newPassword, String confirmPassword) {
        UserDTO user = getUserById(userId);
        if (user == null) return "사용자를 찾을 수 없습니다.";
        if (currentPassword == null || !passwordEncoder.matches(currentPassword, user.getPassword())) {
            return "현재 비밀번호가 일치하지 않습니다.";
        }
        if (newPassword == null || newPassword.length() < 8) {
            return "새 비밀번호는 8자 이상이어야 합니다.";
        }
        if (!newPassword.equals(confirmPassword)) {
            return "새 비밀번호와 확인이 일치하지 않습니다.";
        }
        // 추가 정책: 특수문자, 숫자 포함 등 필요시 추가
        String encodedPassword = passwordEncoder.encode(newPassword);
        int result = updatePassword(userId, encodedPassword);
        if (result <= 0) return "비밀번호 변경에 실패했습니다.";
        return null; // 성공
    }
}