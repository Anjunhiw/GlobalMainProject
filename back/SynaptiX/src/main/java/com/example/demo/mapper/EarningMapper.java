package com.example.demo.mapper;

import org.apache.ibatis.annotations.Mapper;
import java.util.List;
import java.util.Map;

@Mapper
public interface EarningMapper {
    List<Map<String, Object>> selectAllEarnings();
}
