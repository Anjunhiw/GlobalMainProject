package com.example.demo.service.asset;

import com.example.demo.model.AssetDTO;
import com.example.demo.mapper.asset.AssetMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
public class AssetService {
    @Autowired
    private AssetMapper assetMapper;

    public AssetDTO getAsset() {
        return assetMapper.selectAsset();
    }

    public AssetDTO searchAsset(Map<String, Object> params) {
        return assetMapper.searchAsset(params);
    }
}