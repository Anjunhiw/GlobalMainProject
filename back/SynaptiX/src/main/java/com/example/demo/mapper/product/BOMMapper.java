package com.example.demo.mapper.product;

import com.example.demo.model.BOMDTO;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface BOMMapper {
    List<BOMDTO> selectAllBOM();
    void insertBOM(BOMDTO bomDTO);
    void updateBOM(BOMDTO bomDTO);
    List<BOMDTO> selectFilteredBOM(@org.apache.ibatis.annotations.Param("category") String category,
                                   @org.apache.ibatis.annotations.Param("id") String id);
    List<BOMDTO> selectAllBOMWithNames();
    List<BOMDTO> selectFilteredBOMWithNames(@org.apache.ibatis.annotations.Param("category") String category,
                                            @org.apache.ibatis.annotations.Param("id") String id);
    List<BOMDTO> searchBOM(
            @org.apache.ibatis.annotations.Param("code") String code,
            @org.apache.ibatis.annotations.Param("name") String name,
            @org.apache.ibatis.annotations.Param("category") String category,
            @org.apache.ibatis.annotations.Param("model") String model,
            @org.apache.ibatis.annotations.Param("materialName") String materialName
        );
}