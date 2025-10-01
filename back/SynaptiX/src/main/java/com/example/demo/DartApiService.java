package com.example.demo;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

@Service
public class DartApiService {
    @Value("${dart.api.key}")
    private String apiKey;
    @Value("${dart.api.corp-code}")
    private String corpCode;
    @Value("${dart.api.base-url}")
    private String dartApiBaseUrl;

    private final RestTemplate restTemplate = new RestTemplate();

    public DartResponse getFinancialData(String year) {
        String url = "https://opendart.fss.or.kr/api/fnlttSinglAcnt.json?crtfc_key=" + apiKey
            + "&corp_code=" + corpCode
            + "&bsns_year=" + year
            + "&reprt_code=11011";
        try {
            return restTemplate.getForObject(url, DartResponse.class);
        } catch (RestClientException e) {
            DartResponse errorResponse = new DartResponse();
            errorResponse.setStatus("error");
            errorResponse.setMessage("DART API 호출 실패: " + e.getMessage());
            errorResponse.setList(null);
            return errorResponse;
        }
    }
}