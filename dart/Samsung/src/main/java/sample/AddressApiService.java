package sample;

import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.client.RestClientException;

import java.util.Arrays;
import java.util.List;

@Service
public class AddressApiService {
    @Value("${sample.api.address-url:http://localhost:8080/api/address}")
    private String addressApiUrl;

    private final RestTemplate restTemplate = new RestTemplate();

    public List<Address> fetchAddresses() {
        try {
            Address[] addresses = restTemplate.getForObject(addressApiUrl, Address[].class);
            return Arrays.asList(addresses);
        } catch (RestClientException e) {
            // 예외 발생 시 빈 리스트 반환 또는 필요시 커스텀 예외 처리 가능
            return List.of();
        }
    }
}