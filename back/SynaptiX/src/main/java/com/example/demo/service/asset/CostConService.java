package com.example.demo.service.asset;

import com.example.demo.model.PurchaseDTO;
import com.example.demo.mapper.asset.CostConMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public class CostConService {
    @Autowired
    private CostConMapper costConMapper;

    public List<PurchaseDTO> getCostConList(String startDate, String endDate, String materialName) {
        return costConMapper.selectCostConList(startDate, endDate, materialName);
    }

    public List<PurchaseDTO> searchCostConList(Map<String, Object> params) {
        return costConMapper.searchCostConList(params);
    }
}