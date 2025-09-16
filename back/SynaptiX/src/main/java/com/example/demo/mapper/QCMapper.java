package com.example.demo.mapper;

import com.example.demo.model.QCDTO;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface QCMapper {
    List<QCDTO> selectAllQC();
    void insertQC(QCDTO qcDTO);
}
