package com.example.demo.mapper.stock;

import com.example.demo.model.MaterialDTO;
import com.example.demo.model.ProductDTO;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface StockMapper {
    List<MaterialDTO> selectAllMaterials();
    List<ProductDTO> selectAllProducts();
    List<MaterialDTO> selectMaterialsByName(String name);
    List<ProductDTO> selectProductsByName(String name);
    List<MaterialDTO> selectMaterialsByCondition(String code, String name, String model, String category);
    List<ProductDTO> selectProductsByCondition(String code, String name, String model, String category);
    MaterialDTO selectMaterialByPk(int pk);
    ProductDTO selectProductByPk(int pk);
    void updateMaterial(MaterialDTO material);
    void updateProduct(ProductDTO product);
    void deleteMaterial(int pk);
    void deleteProduct(int pk);
    void insertMaterial(com.example.demo.model.MaterialDTO dto);
    void insertProduct(com.example.demo.model.ProductDTO dto);
}