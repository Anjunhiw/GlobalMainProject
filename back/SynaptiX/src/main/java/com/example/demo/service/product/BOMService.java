package com.example.demo.service.product;

import com.example.demo.model.BOMDTO;
import com.example.demo.mapper.product.BOMMapper;
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

    public List<BOMDTO> getFilteredBOM(String category, String id) {
        return bomMapper.selectFilteredBOM(category, id);
    }

    public List<BOMDTO> getAllBOMWithNames() {
        return bomMapper.selectAllBOMWithNames();
    }

    public List<BOMDTO> getFilteredBOMWithNames(String category, String id) {
        return bomMapper.selectFilteredBOMWithNames(category, id);
    }

    public void updateBOM(BOMDTO bomDTO) {
        bomMapper.updateBOM(bomDTO);
    }
}