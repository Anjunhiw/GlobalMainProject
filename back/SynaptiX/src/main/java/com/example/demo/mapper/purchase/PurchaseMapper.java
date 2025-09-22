package com.example.demo.mapper.purchase;

import com.example.demo.model.PurchaseDTO;
import java.util.List;

public interface PurchaseMapper {
    List<PurchaseDTO> selectAllPurchases();
}