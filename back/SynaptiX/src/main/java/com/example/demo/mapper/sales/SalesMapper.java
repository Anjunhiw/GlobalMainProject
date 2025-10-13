package com.example.demo.mapper.sales;

import com.example.demo.model.Sales;
import java.util.List;
import org.apache.ibatis.annotations.Param;

public interface SalesMapper {
    List<Sales> selectAllSales();
    List<Sales> selectSalesByCondition(
        @Param("code") String code,
        @Param("name") String name,
        @Param("outDate") String outDate
    );
}