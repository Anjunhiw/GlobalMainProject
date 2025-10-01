package com.example.demo;

import java.util.List;

public class DartResponse {
    private String status;
    private String message;
    private List<DartAccount> list;

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public List<DartAccount> getList() { return list; }
    public void setList(List<DartAccount> list) { this.list = list; }
}