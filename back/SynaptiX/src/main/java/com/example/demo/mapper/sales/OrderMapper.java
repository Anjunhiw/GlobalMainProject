package com.example.demo.mapper.sales;

import org.apache.ibatis.annotations.Mapper;
import java.util.List;
import java.util.Map;

@Mapper
public interface OrderMapper {
    List<Map<String, Object>> selectAllOrders();
    List<Map<String, Object>> searchOrders(Map<String, Object> params);
}