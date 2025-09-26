package com.example.demo.mapper.asset;

import com.example.demo.model.AssetDTO;

public interface AssetMapper {
    AssetDTO selectAsset();
    AssetDTO searchAsset(java.util.Map<String, Object> params);
}