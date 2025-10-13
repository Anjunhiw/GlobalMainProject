package com.example.demo.controller.user;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.ui.Model;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.ModelAttribute;
import javax.servlet.http.HttpServletRequest;
import com.example.demo.model.UserDTO;
import com.example.demo.service.user.UserEditService;

@Controller
public class UserEditController {
    @Autowired
    private UserEditService userEditService;

    @PreAuthorize("hasAuthority('RANK_WRITE') or hasAuthority('ROLE_ADMIN')")
    @GetMapping("/useredit")
    public String userEditPage(Model model) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String userId = auth.getName();
        UserDTO user = userEditService.getUserById(userId);
        model.addAttribute("user", user);
        return "user/UserEdit";
    }

    @PostMapping("/useredit")
    public String userEdit(@ModelAttribute UserDTO user,
                          HttpServletRequest request,
                          Model model) {
        // 기존 사용자 정보 조회
        UserDTO existingUser = userEditService.getUserById(user.getUserId());

        // 부분 업데이트: 폼에서 전달된 값만 덮어쓰기
        if (user.getName() != null) existingUser.setName(user.getName());
        if (user.getEmail() != null) existingUser.setEmail(user.getEmail());
        if (user.getDept() != null) existingUser.setDept(user.getDept());
        if (user.getRank() != null) existingUser.setRank(user.getRank());
        // 필요시 다른 필드도 추가

        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String newPasswordConfirm = request.getParameter("newPasswordConfirm");
        // 비밀번호 변경 요청이 있을 경우 처리
        if (newPassword != null && !newPassword.isEmpty()) {
            String result = userEditService.changePassword(existingUser.getUserId(), currentPassword, newPassword, newPasswordConfirm);
            if (result != null) {
                model.addAttribute("error", result);
                model.addAttribute("user", existingUser);
                return "user/UserEdit";
            } else {
                model.addAttribute("message", "비밀번호가 성공적으로 변경되었습니다.");
            }
        }
        userEditService.updateUser(existingUser);
        return "redirect:/home";
    }
}