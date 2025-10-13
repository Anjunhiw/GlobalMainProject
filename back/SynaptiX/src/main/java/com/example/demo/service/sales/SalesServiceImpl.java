package com.example.demo.service.sales;

import com.example.demo.mapper.sales.SalesMapper;
import com.example.demo.model.Sales;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class SalesServiceImpl implements SalesService {
    @Autowired
    private SalesMapper salesMapper;

    @Override
    public List<Sales> getAllSales() {
        return salesMapper.selectAllSales();
    }

    @Override
    public List<Sales> searchSales(String code, String name, String outDate) {
        return salesMapper.selectSalesByCondition(code, name, outDate);
    }
}