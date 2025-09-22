package com.example.demo.service.user;

import com.example.demo.model.LoginDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.core.userdetails.User;
import org.springframework.stereotype.Service;

import java.util.Collections;

@Service
public class CustomUserDetailsService implements UserDetailsService {
    @Autowired
    private LoginService loginService;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        LoginDTO user = loginService.getUserInfo(username);
        if (user == null) {
            throw new UsernameNotFoundException("User not found");
        }
        // 권한(roles)은 USER로 고정, 필요시 user.getRole() 등으로 확장 가능
        return User.builder()
                .username(user.getId())
                .password(user.getPw())
                .roles("USER")
                .build();
    }
    
    
//    public class CustomUserDetails implements UserDetails {
//        private final User user;
//
//        public CustomUserDetails(User user) {
//            this.user = user;
//        }
//
//        public String getName() {   
//            return user.getName();
//        }
//
//    
//    }
}
