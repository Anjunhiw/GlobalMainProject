package com.example.demo.service.user;

import com.example.demo.model.UserDTO;
import com.example.demo.mapper.user.UserMapper;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.stereotype.Service;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;

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

    public String findUserIdByEmailAndBirth(String email, String birthYmd) {
        return userMapper.findUserIdByEmailAndBirth(email, birthYmd);
    }

    public boolean verifyUserForPasswordReset(String userId, String email, String birthYmd) {
        return userMapper.verifyUserForPasswordReset(userId, email, birthYmd) > 0;
    }

    public java.util.List<UserDTO> getAllUsers() {
        return userMapper.selectAllUsers();
    }

    public boolean isUserIdDuplicate(String userId) {
        return userMapper.findByUserId(userId) != null;
    }
    
    public boolean updatePassword(String userId, String newPassword) {
        String encodedPassword = passwordEncoder.encode(newPassword);
        return userMapper.updatePassword(userId, encodedPassword) > 0;
    }
    
    public java.util.List<UserDTO> searchUsers(java.util.Map<String, Object> params) {
        return userMapper.searchUsers(params);
    }
    
    @Controller
    public class ProfileController {

        @Autowired
        private UserService userService;

        @GetMapping("/profile")
        public String showProfile(HttpSession session, Model model) {
            UserDTO user = (UserDTO) session.getAttribute("user");
            if (user == null) return "redirect:/login";
            model.addAttribute("user", user);
            return "profile"; // profile.jsp
        }

//        @PostMapping("/profile/update")
//        public String updateProfile(@ModelAttribute UserDTO userDto, HttpSession session, Model model) {
//            UserDTO sessionUser = (UserDTO) session.getAttribute("user");
//            if (sessionUser == null) return "redirect:/login";
//
//            userDto.setUserId(sessionUser.getUserId()); // 아이디는 고정
//            boolean success = userService.updateUser(userDto);
//
//            if (success) {
//                session.setAttribute("user", userDto); // 세션 갱신
//                model.addAttribute("message", "회원정보가 수정되었습니다.");
//            } else {
//                model.addAttribute("message", "회원정보 수정 실패");
//            }
//
//            return "profile"; // 다시 profile.jsp 로 이동
//        }
    }

}