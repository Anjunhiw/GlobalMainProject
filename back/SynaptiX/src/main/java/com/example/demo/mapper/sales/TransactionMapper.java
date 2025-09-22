package com.example.demo.mapper.sales;

import org.apache.ibatis.annotations.Mapper;
import java.util.List;
import java.util.Map;

@Mapper
public interface TransactionMapper {
    List<Map<String, Object>> selectAllTransactions();
}
