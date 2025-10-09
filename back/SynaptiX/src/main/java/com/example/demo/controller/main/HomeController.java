package com.example.demo.controller.main;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.client.RestTemplate;

import com.example.demo.service.home.*;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import javax.servlet.http.HttpSession;
import java.util.ArrayList;
import java.util.List;

@Controller
@RequestMapping("/home")
public class HomeController {
    @Autowired
    private HomeService homeService;

    @Value("${dart.api.base-url}")
    private String dartApiBaseUrl;

    // 공통 렌더링
    @GetMapping("")
    public String homeList(Model model, HttpSession session) {
        Object user = session.getAttribute("user");
        if (user == null) return "redirect:/login";

        model.addAttribute("homeList", homeService.getHomeList());
        model.addAttribute("active_main", "sales"); // ✅ 기본 탭 활성화
        return "main/Home";
    }


    @GetMapping("/costs")
    public String costs(Model model, HttpSession session){
        model.addAttribute("active_main", "costs"); // ✅ 비용 탭 활성화
        return "main/costs";
    }

    @GetMapping("/stock")
    public String stock(Model model, HttpSession session) {
        model.addAttribute("active_main", "stock");
        return "main/stock";
    }

    @GetMapping("/production")
    public String production(Model model, HttpSession session) {
        model.addAttribute("active_main", "production");
        return "main/production";
    }

    @GetMapping("/hr")
    public String hr(Model model, HttpSession session) {
        model.addAttribute("active_main", "hr");
        return "main/hr";
    }

    @GetMapping("/alert")
    public String alert(Model model, HttpSession session) {
        model.addAttribute("active_main", "alert");
        return "main/alert";
    }

    // 외부 DART API 호출 후 콘솔에 출력하는 테스트 엔드포인트
    @GetMapping("/dart/test")
    @ResponseBody
    public String dartApiTest() {
        // 예시 파라미터 (실제 값은 필요에 따라 변경)
        String corpCode = "00126380";
        String bsnsYear = "2023";
        String reprtCode = "11011";
        String fsDiv = "OFS";

        // 쿼리 파라미터 동적 추가
        String url = dartApiBaseUrl +
            "&corp_code=" + corpCode +
            "&bsns_year=" + bsnsYear +
            "&reprt_code=" + reprtCode +
            "&fs_div=" + fsDiv;

        RestTemplate restTemplate = new RestTemplate();
        String response = restTemplate.getForObject(url, String.class);
        System.out.println("[DART API 응답]: " + response); // 콘솔에 출력
        return "콘솔에 출력 완료";
    }

    // DART API 데이터를 JSON으로 반환하는 엔드포인트 (파라미터 변경 가능)
    @GetMapping("/dart/data")
    @ResponseBody
    public String dartApiData(
        @RequestParam(value = "bsnsYear", required = false, defaultValue = "2023") String bsnsYear,
        @RequestParam(value = "reprtCode", required = false, defaultValue = "11011") String reprtCode
    ) {
        String corpCode = "00126380";
        String fsDiv = "OFS";
        String url = dartApiBaseUrl +
            "&corp_code=" + corpCode +
            "&bsns_year=" + bsnsYear +
            "&reprt_code=" + reprtCode +
            "&fs_div=" + fsDiv;
        RestTemplate restTemplate = new RestTemplate();
        String response = restTemplate.getForObject(url, String.class);
        return response; // JSON 그대로 반환
    }
}