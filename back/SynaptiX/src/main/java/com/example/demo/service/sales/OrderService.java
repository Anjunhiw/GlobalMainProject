package com.example.demo.service.sales;

import com.example.demo.mapper.sales.OrderMapper;
import com.example.demo.model.OrderDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public class OrderService {
    @Autowired
    private OrderMapper orderMapper;

    public List<OrderDTO> getAllOrders() {
        return orderMapper.selectAllOrders();
    }

    public List<OrderDTO> searchOrders(Map<String, Object> params) {
        return orderMapper.searchOrders(params);
    }
}