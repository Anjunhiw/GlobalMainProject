package sample;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;

@RestController
public class AddressExternalController {
    private final AddressApiService addressApiService;

    public AddressExternalController(AddressApiService addressApiService) {
        this.addressApiService = addressApiService;
    }

    @GetMapping("/address/external")
    public List<Address> getExternalAddresses() {
        return addressApiService.fetchAddresses();
    }
}
