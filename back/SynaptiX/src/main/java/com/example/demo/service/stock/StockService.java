package com.example.demo.service.stock;

import com.example.demo.model.MaterialDTO;
import com.example.demo.model.ProductDTO;
import com.example.demo.mapper.stock.StockMapper;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class StockService {
    private final StockMapper mapper;

    public StockService(StockMapper mapper) {
        this.mapper = mapper;
    }

    public List<MaterialDTO> getAllMaterials() {
        return mapper.selectAllMaterials();
    }

    public List<ProductDTO> getAllProducts() {
        return mapper.selectAllProducts();
    }

    public List<MaterialDTO> searchMaterialsByName(String name) {
        return mapper.selectMaterialsByName(name);
    }

    public List<ProductDTO> searchProductsByName(String name) {
        return mapper.selectProductsByName(name);
    }

    public List<MaterialDTO> searchMaterials(String code, String name, String model, String category) {
        return mapper.selectMaterialsByCondition(code, name, model, category);
    }
    public List<ProductDTO> searchProducts(String code, String name, String model, String category) {
        return mapper.selectProductsByCondition(code, name, model, category);
    }

    public Object getStockByPk(int pk) {
        MaterialDTO material = mapper.selectMaterialByPk(pk);
        if (material != null) return material;
        ProductDTO product = mapper.selectProductByPk(pk);
        return product;
    }
    public MaterialDTO getMaterialByPk(int pk) {
        return mapper.selectMaterialByPk(pk);
    }
    public ProductDTO getProductByPk(int pk) {
        return mapper.selectProductByPk(pk);
    }
    public void updateMaterial(MaterialDTO material) {
        mapper.updateMaterial(material);
    }
    public void updateProduct(ProductDTO product) {
        mapper.updateProduct(product);
    }
    public void deleteStock(int pk) {
        if (mapper.selectMaterialByPk(pk) != null) {
            mapper.deleteMaterial(pk);
        } else {
            mapper.deleteProduct(pk);
        }
    }
    public void deleteMaterial(int pk) {
        mapper.deleteMaterial(pk);
    }
    public void deleteProduct(int pk) {
        mapper.deleteProduct(pk);
    }
    public void insertMaterial(MaterialDTO dto) {
        mapper.insertMaterial(dto);
    }
    public void insertProduct(ProductDTO dto) {
        mapper.insertProduct(dto);
    }
}