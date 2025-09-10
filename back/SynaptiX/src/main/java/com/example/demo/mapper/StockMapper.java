package com.example.demo.mapper;

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
    MaterialDTO selectMaterialByPk(int pk);
    ProductDTO selectProductByPk(int pk);
    void updateMaterial(MaterialDTO material);
    void updateProduct(ProductDTO product);
    void deleteMaterial(int pk);
    void deleteProduct(int pk);
}