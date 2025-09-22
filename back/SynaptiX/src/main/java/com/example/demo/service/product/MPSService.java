package com.example.demo.service.product;

import com.example.demo.model.MPSDTO;
import com.example.demo.mapper.product.MPSMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class MPSService {
    @Autowired
    private MPSMapper mpsMapper;

    public List<MPSDTO> getAllMPS() {
        return mpsMapper.selectAllMPS();
    }

    public void addMPS(MPSDTO mpsDTO) {
        mpsMapper.insertMPS(mpsDTO);
    }
}