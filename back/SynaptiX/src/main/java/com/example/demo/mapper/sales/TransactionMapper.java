package com.example.demo.mapper.sales;

import org.apache.ibatis.annotations.Mapper;
import java.util.List;
import java.util.Map;
import com.example.demo.model.TransactionDTO;

@Mapper
public interface TransactionMapper {
    List<TransactionDTO> selectAllTransactions();
    List<TransactionDTO> selectTransactionsByCondition(Map<String, Object> param);
}