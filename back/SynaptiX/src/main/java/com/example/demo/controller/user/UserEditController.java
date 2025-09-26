package com.example.demo.controller.user;

import java.security.Principal;

import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;



//public class UserEditController {
//@GetMapping("/edit")
//public String mypage(Model model, Principal principal){
//    // memberService에서 로그인 사용자 정보 로드
//    model.addAttribute("member", memberService.getByUsername(principal.getName()));
//    return "member/MyPage";
//}

//@PostMapping("/mypage/save")
//public String mypageSave(@ModelAttribute MemberUpdateReq req,
//                         @RequestParam(required=false) MultipartFile avatar){
//    memberService.updateMyPage(req, avatar);
//    return "redirect:/mypage";
//}
}