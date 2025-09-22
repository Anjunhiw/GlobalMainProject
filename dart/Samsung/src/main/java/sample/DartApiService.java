package sample;

import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.client.RestClientException;
import java.util.ArrayList;
import java.util.List;

@Service
public class DartApiService {
    @Value("${dart.api.base-url}")
    private String dartApiBaseUrl;

    private final RestTemplate restTemplate = new RestTemplate();

    // 기존 단일 연도 호출 메서드 (필요시 유지)
    public DartResponse getFinancialData(String year) {
        String url = dartApiBaseUrl + "&bsns_year=" + year;
        try {
            return restTemplate.getForObject(url, DartResponse.class);
        } catch (RestClientException e) {
            return null;
        }
    }

    // 여러 연도 반복 호출 메서드
    public List<DartResponse> getFinancialDataByYears(List<String> years) {
        List<DartResponse> results = new ArrayList<>();
        for (String year : years) {
            DartResponse response = getFinancialData(year);
            if (response != null) {
                results.add(response);
            }
        }
        return results;
    }
}