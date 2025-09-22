package com.example.demo.service.product;

import com.example.demo.model.QCDTO;
import com.example.demo.mapper.product.QCMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class QCService {
    @Autowired
    private QCMapper qcMapper;

    public List<QCDTO> getAllQC() {
        return qcMapper.selectAllQC();
    }

    public void addQC(QCDTO qcDTO) {
        qcMapper.insertQC(qcDTO);
    }
}