package com.example.demo.mapper;

import com.example.demo.model.MPSDTO;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface MPSMapper {
    List<MPSDTO> selectAllMPS();
    void insertMPS(MPSDTO mpsDTO);
}
