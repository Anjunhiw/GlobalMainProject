package sample;

public class Address {
    private String zipcode;
    private String address;
    private String detail;

    public Address() {}

    public Address(String zipcode, String address, String detail) {
        this.zipcode = zipcode;
        this.address = address;
        this.detail = detail;
    }

    public String getZipcode() {
        return zipcode;
    }

    public void setZipcode(String zipcode) {
        this.zipcode = zipcode;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getDetail() {
        return detail;
    }

    public void setDetail(String detail) {
        this.detail = detail;
    }
}
