package com.example.demo.service;

import com.example.demo.model.BOMDTO;
import com.example.demo.mapper.BOMMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class BOMService {
    @Autowired
    private BOMMapper bomMapper;

    public List<BOMDTO> getAllBOM() {
        return bomMapper.selectAllBOM();
    }

    public void addBOM(BOMDTO bomDTO) {
        bomMapper.insertBOM(bomDTO);
    }
}