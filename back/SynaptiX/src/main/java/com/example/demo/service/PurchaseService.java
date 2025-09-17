package com.example.demo.service;

import com.example.demo.model.PurchaseDTO;
import com.example.demo.mapper.PurchaseMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class PurchaseService {
    @Autowired
    private PurchaseMapper purchaseMapper;

    public List<PurchaseDTO> getAllPurchases() {
        return purchaseMapper.selectAllPurchases();
    }
}