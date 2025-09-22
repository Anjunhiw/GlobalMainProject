package com.example.demo.mapper;

import com.example.demo.model.BOMDTO;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface BOMMapper {
    List<BOMDTO> selectAllBOM();
    void insertBOM(BOMDTO bomDTO);
    List<BOMDTO> selectFilteredBOM(@org.apache.ibatis.annotations.Param("category") String category,
                                   @org.apache.ibatis.annotations.Param("id") String id);
}