package com.example.demo.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.web.access.AccessDeniedHandler;
import com.example.demo.service.user.CustomUserDetailsService;
import org.springframework.http.HttpMethod;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true)
public class SecurityConfig {
    @Autowired
    private CustomUserDetailsService customUserDetailsService;

    @Bean
    public AccessDeniedHandler accessDeniedHandler() {
        return new CustomAccessDeniedHandler();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .authorizeRequests()
                // 공개 페이지 모두 허용
                .antMatchers("/login", "/register", "/findId", "/findPassword", "/useredit", "/home", "/home/**", "/mypage", "/mypage/**", "/css/**", "/js/**", "/images/**").permitAll()
                // GET 요청은 모두 인증된 사용자에게 허용
                .antMatchers(HttpMethod.GET, "/**").authenticated()
                // POST 요청은 부서/직급별로 제한
                .antMatchers(HttpMethod.POST, "/api/asset/**").hasAuthority("DEPT_STOCK")
                .antMatchers(HttpMethod.POST, "/api/production/**").hasAuthority("DEPT_PRODUCTION")
                .antMatchers(HttpMethod.POST, "/api/sales/**").hasAuthority("DEPT_SALES")
                .antMatchers(HttpMethod.POST, "/api/accounting/**").hasAuthority("DEPT_ACCOUNTING")
                .antMatchers(HttpMethod.POST, "/api/audit/**").hasAuthority("DEPT_AUDIT")
                .antMatchers(HttpMethod.POST, "/api/hr/**").hasAuthority("DEPT_HR")
//                .antMatchers(HttpMethod.POST, "/api/main/**").hasAuthority("DEPT_MAIN")
                // 직급별 POST 권한 (예시: RANK_WRITE, ROLE_ADMIN)
                .antMatchers(HttpMethod.POST, "/api/**").hasAnyAuthority("RANK_WRITE", "ROLE_ADMIN")
                // 관리자 전체 허용
                .antMatchers("/**").hasAuthority("ROLE_ADMIN")
                .anyRequest().authenticated()
            .and()
            .formLogin().disable() // 커스텀 로그인 컨트롤러 사용을 위해 formLogin 비활성화
            .logout()
                .logoutUrl("/logout")
                .logoutSuccessUrl("/login?logout")
                .permitAll()
            .and()
            .exceptionHandling()
                .authenticationEntryPoint((request, response, authException) -> {
                    response.sendRedirect("/login");
                })
                .accessDeniedHandler(accessDeniedHandler())
            .and()
            .csrf(); // CSRF 기본 활성화
        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public UserDetailsService userDetailsService() {
        return customUserDetailsService;
    }
}