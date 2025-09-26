package com.example.demo.mapper.purchase;

import org.apache.ibatis.annotations.Mapper;
import java.util.List;
import java.util.Map;

@Mapper
public interface MRPMapper {
    List<Map<String, Object>> selectAllMRP();
    List<Map<String, Object>> searchMRP(Map<String, Object> params);
}