package com.example.demo.mapper.product;

import org.apache.ibatis.annotations.Mapper;
import java.util.List;
import java.util.Map;

@Mapper
public interface ProfitMapper {
    List<Map<String, Object>> selectProfitList();
}