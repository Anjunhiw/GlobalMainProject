package com.example.demo.mapper.asset;

import com.example.demo.model.AssetPlanDTO;
import java.util.List;

public interface AssetPlanMapper {
    List<AssetPlanDTO> selectAssetPlans();
    List<AssetPlanDTO> searchAssetPlans(java.util.Map<String, Object> params);
}