package sample;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.ui.Model;
import org.springframework.stereotype.Controller;

@RestController
public class DartApiController {
    private final DartApiService dartApiService;

    public DartApiController(DartApiService dartApiService) {
        this.dartApiService = dartApiService;
    }

    @GetMapping("/dart/finance")
    public DartResponse getFinance(@RequestParam(defaultValue = "2023") String year) {
        return dartApiService.getFinancialData(year);
    }

    @Controller
    public static class DartPageController {
        private final DartApiService dartApiService;
        public DartPageController(DartApiService dartApiService) {
            this.dartApiService = dartApiService;
        }
        @GetMapping("/dart/finance/page")
        public String getFinancePage(@RequestParam(defaultValue = "2023") String year, Model model) {
            DartResponse response = dartApiService.getFinancialData(year);
            model.addAttribute("response", response);
            model.addAttribute("year", Integer.parseInt(year)); // year를 Integer로 추가
            return "dartFinance";
        }
    }
}