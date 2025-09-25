package com.example.demo.mapper.sales;

import com.example.demo.model.Sales;
import java.util.List;

public interface SalesMapper {
    List<Sales> selectAllSales();
    List<Sales> selectSalesByCondition(String code, String name, String outDate, String category);
}