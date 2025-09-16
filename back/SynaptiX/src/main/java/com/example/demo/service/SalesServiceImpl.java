package com.example.demo.service;

import com.example.demo.mapper.SalesMapper;
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
}
