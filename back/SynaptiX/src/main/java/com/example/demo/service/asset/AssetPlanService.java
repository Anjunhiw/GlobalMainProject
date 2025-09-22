package com.example.demo.service.asset;

import com.example.demo.model.AssetPlanDTO;
import com.example.demo.mapper.asset.AssetPlanMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class AssetPlanService {
    @Autowired
    private AssetPlanMapper assetPlanMapper;

    public List<AssetPlanDTO> getAssetPlans() {
        return assetPlanMapper.selectAssetPlans();
    }
}
