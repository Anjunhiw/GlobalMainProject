package sample;

public class DartAccount {
    private String rcept_no;
    private String corp_code;
    private String bsns_year;
    private String reprt_code;
    private String account_nm;
    private String thstrm_amount;
    // 필요시 추가 필드 선언

    public String getRcept_no() { return rcept_no; }
    public void setRcept_no(String rcept_no) { this.rcept_no = rcept_no; }
    public String getCorp_code() { return corp_code; }
    public void setCorp_code(String corp_code) { this.corp_code = corp_code; }
    public String getBsns_year() { return bsns_year; }
    public void setBsns_year(String bsns_year) { this.bsns_year = bsns_year; }
    public String getReprt_code() { return reprt_code; }
    public void setReprt_code(String reprt_code) { this.reprt_code = reprt_code; }
    public String getAccount_nm() { return account_nm; }
    public void setAccount_nm(String account_nm) { this.account_nm = account_nm; }
    public String getThstrm_amount() { return thstrm_amount; }
    public void setThstrm_amount(String thstrm_amount) { this.thstrm_amount = thstrm_amount; }
}
