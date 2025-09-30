package com.example.demo.mapper.sales;

import com.example.demo.model.OrderDTO;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;
import java.util.Map;

@Mapper
public interface OrderMapper {
    List<OrderDTO> selectAllOrders();
    List<OrderDTO> searchOrders(Map<String, Object> params);
}