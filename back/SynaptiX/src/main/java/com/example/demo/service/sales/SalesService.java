package com.example.demo.service.sales;

import com.example.demo.model.Sales;
import java.util.List;

public interface SalesService {
    List<Sales> getAllSales();
    List<Sales> searchSales(String code, String name, String outDate);
}