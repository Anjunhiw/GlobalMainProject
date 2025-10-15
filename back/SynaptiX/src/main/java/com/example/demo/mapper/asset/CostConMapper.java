package com.example.demo.mapper.asset;

import com.example.demo.model.PurchaseDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface CostConMapper {
    List<PurchaseDTO> selectCostConList(
        @Param("startDate") String startDate,
        @Param("endDate") String endDate,
        @Param("mtrName") String mtrName
    );

    List<PurchaseDTO> searchCostConList(java.util.Map<String, Object> params);
}