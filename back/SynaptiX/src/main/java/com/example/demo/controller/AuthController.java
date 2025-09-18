package com.example.demo.controller;

import com.example.demo.model.UserDTO;
import com.example.demo.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
@RequestMapping("")
public class AuthController {
    @Autowired
    private UserService userService;

    @GetMapping("/register")
    public String showRegisterForm() {
        return "Register";
    }

    @PostMapping("/register")
    public String register(@ModelAttribute UserDTO userDto, Model model) {
        if (userService.isUserIdDuplicate(userDto.getUserId())) {
            model.addAttribute("check_id", "이미 사용 중인 아이디입니다.");
            return "Register";
        }
        boolean success = userService.registerUser(userDto);
        if (success) {
            model.addAttribute("message", "회원가입이 완료되었습니다.");
            return "Login";
        } else {
            model.addAttribute("message", "회원가입에 실패했습니다.");
            return "Register";
        }
    }

    @GetMapping("/findId")
    public String showFindIdForm() {
        return "FindId";
    }
    
    @PostMapping("/findId")
    public String findIdSubmit(@RequestParam String email,
                               @RequestParam String birthYear,
                               @RequestParam String birthMonth,
                               @RequestParam String birthDay,
                               Model model) {

        String y = birthYear.trim();
        String m = birthMonth.length()==1 ? "0"+birthMonth : birthMonth;
        String d = birthDay.length()==1 ? "0"+birthDay : birthDay;
        String birthYmd = y + m + d; // 19980209

        String userId = userService.findUserIdByEmailAndBirth(email, birthYmd);

        if (userId != null) model.addAttribute("result", userId);
        else model.addAttribute("error", "일치하는 정보가 없습니다.");

        return "FindId";
    }


    @GetMapping("/findPassword")
    public String showFindPasswordForm() {
        return "FindPassword";
    }
    
    @PostMapping("/findPassword")
    public String findPasswordSubmit(@RequestParam String userId,
                                     @RequestParam String email,
                                     @RequestParam String birthYear,
                                     @RequestParam String birthMonth,
                                     @RequestParam String birthDay,
                                     Model model) {

        String y = birthYear.trim();
        String m = birthMonth.length()==1 ? "0"+birthMonth : birthMonth;
        String d = birthDay.length()==1 ? "0"+birthDay : birthDay;
        String birthYmd = y + m + d; // 19980209

        boolean success = userService.verifyUserForPasswordReset(userId, email, birthYmd);

        if (success) {
            // 랜덤 4자리 문자열 생성
            String chars = "abcdefghijklmnopqrstuvwxyz0123456789";
            StringBuilder sb = new StringBuilder(4);
            java.security.SecureRandom random = new java.security.SecureRandom();
            for (int i = 0; i < 4; i++) {
                sb.append(chars.charAt(random.nextInt(chars.length())));
            }
            String password = sb.toString();
            boolean update = userService.updatePassword(userId, password);
            if (update) {
                model.addAttribute("result", password);
            } else {
                model.addAttribute("error", "비밀번호 변경에 실패했습니다. 관리자에게 문의하세요.");
            }
        } else {
            model.addAttribute("error", "일치하는 정보가 없습니다.");
        }
        return "FindPassword";
    }
    
    
}