// StockController.java
package com.example.demo.controller.stock;

import com.example.demo.model.MaterialDTO;
import com.example.demo.model.ProductDTO;
import com.example.demo.service.stock.StockService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;


@Controller
@RequiredArgsConstructor
public class StockController {
    private final StockService service;
//    public StockController(StockService service) {
//		this.service = service;
//	}
	 
  
    @GetMapping("/stock")
    public String showStockList(
            @RequestParam(value = "code", required = false) String code,
            @RequestParam(value = "name", required = false) String name,
            @RequestParam(value = "model", required = false) String model,
            @RequestParam(value = "category", required = false) String category,
            Model mv
    ) {
        // category 값: "", null, "materials", "product" 를 모두 허용
        List<MaterialDTO> materials;
        List<ProductDTO> products;

        boolean filtered = (code != null && !code.isBlank())
                || (name != null && !name.isBlank())
                || (model != null && !model.isBlank())
                || (category != null && !category.isBlank());

        if (!filtered) {
            // 전체 조회
            materials = service.getAllMaterials();
            products  = service.getAllProducts();
        } else {
            // 필터 조회 (서비스에 메서드 없다면 간단히 name만으로도 먼저 구현)
            if ("materials".equalsIgnoreCase(category)) {
                materials = service.searchMaterialsByName(name == null ? "" : name);
                products  = List.of();
            } else if ("product".equalsIgnoreCase(category)) {
                products  = service.searchProductsByName(name == null ? "" : name);
                materials = List.of();
            } else {
                // 카테고리 전체, 이름 필터만 적용
                materials = service.searchMaterialsByName(name == null ? "" : name);
                products  = service.searchProductsByName(name == null ? "" : name);
            }
        }

        mv.addAttribute("materials", materials);
        mv.addAttribute("products", products);

        // 폼 값 유지 (검색 후에도 입력값 남도록)
        mv.addAttribute("q_code", code);
        mv.addAttribute("q_name", name);
        mv.addAttribute("q_model", model);
        mv.addAttribute("q_category", category);
        mv.addAttribute("active_stock", "active");

        return "stock/StockList";
    }

    // 수정 폼 이동
    @GetMapping("/stock/edit")
    public String showEditForm(@RequestParam("pk") int pk,
                               @RequestParam("category") String cat,
                               Model mv) {
        if ("material".equals(cat)) {
            mv.addAttribute("material", service.getMaterialByPk(pk));
            mv.addAttribute("product", null);
        } else if ("product".equals(cat)) {
            mv.addAttribute("product", service.getProductByPk(pk));
            mv.addAttribute("material", null);
        } else {
            mv.addAttribute("material", null);
            mv.addAttribute("product", null);
        }
        return "stock/StockEdit";
    }

    @PostMapping("/stock/editMaterial")
    public String editMaterial(@ModelAttribute MaterialDTO material) {
        service.updateMaterial(material);
        return "redirect:/stock";
    }

    @PostMapping("/stock/editProduct")
    public String editProduct(@ModelAttribute ProductDTO product) {
        service.updateProduct(product);
        return "redirect:/stock";
    }

    @PostMapping("/stock/delete")
    public String deleteStock(@RequestParam("pk") int pk,
                              @RequestParam("category") String cat) {
        if ("material".equals(cat)) service.deleteMaterial(pk);
        else if ("product".equals(cat)) service.deleteProduct(pk);
        return "redirect:/stock";
    }

    @PostMapping("/stock/search")
    public String searchStock(
        @RequestParam(value = "code", required = false) String code,
        @RequestParam(value = "name", required = false) String name,
        @RequestParam(value = "model", required = false) String model,
        @RequestParam(value = "category", required = false) String category,
        @RequestParam(value = "searchName", required = false) String searchName,
        Model mv
    ) {
        // 입력된 값만 넘기기 위해 null/빈값은 null로 전달
        code = (code != null && !code.isBlank()) ? code : null;
        String searchKey = (searchName != null && !searchName.isBlank()) ? searchName : (name != null && !name.isBlank() ? name : null);
        model = (model != null && !model.isBlank()) ? model : null;
        category = (category != null && !category.isBlank() && !"전체".equals(category)) ? category : null;
        // category 값 변환: material → 원자재, product → 제품, 전체/빈값/null → null
        if ("material".equals(category)) {
            category = "원자재";
        } else if ("product".equals(category)) {
            category = "제품";
        } else {
            category = null;
        }
        List<MaterialDTO> materials = service.searchMaterials(code, searchKey, model, category);
        List<ProductDTO> products = service.searchProducts(code, searchKey, model, category);
        mv.addAttribute("materials", materials);
        mv.addAttribute("products", products);
        return "stock/StockSearchResult";
    }

    @PostMapping("/stock/register")
    @ResponseBody
    public java.util.Map<String, Object> registerStock(
        @RequestParam("category") String category,
        @RequestParam("name") String name,
        @RequestParam(value = "model", required = false) String model,
        @RequestParam(value = "specification", required = false) String specification,
        @RequestParam(value = "unit", required = false) String unit,
        @RequestParam("price") int price,
        @RequestParam("stock") float stock,
        @RequestParam("amount") float amount
    ) {
        java.util.Map<String, Object> result = new java.util.HashMap<>();
        try {
            if ("material".equals(category)) {
                com.example.demo.model.MaterialDTO dto = new com.example.demo.model.MaterialDTO();
                dto.setCategory("원자재");
                dto.setName(name);
                dto.setSpecification(specification);
                dto.setUnit(unit);
                dto.setPrice(price);
                dto.setStock(stock);
                dto.setAmount(amount);
                service.insertMaterial(dto);
            } else if ("product".equals(category)) {
                com.example.demo.model.ProductDTO dto = new com.example.demo.model.ProductDTO();
                dto.setCategory("제품");
                dto.setName(name);
                dto.setModel(model);
                dto.setSpecification(specification);
                dto.setPrice(price);
                dto.setStock(stock);
                dto.setAmount(amount);
                service.insertProduct(dto);
            } else {
                throw new IllegalArgumentException("카테고리 오류");
            }
            result.put("success", true);
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", e.getMessage());
        }
        return result;
    }

    @PostMapping("/stock/edit")
    public String editStock(
        @RequestParam("category") String category,
        @ModelAttribute MaterialDTO material,
        @ModelAttribute ProductDTO product
    ) {
        if ("material".equals(category)) {
            service.updateMaterial(material);
        } else if ("product".equals(category)) {
            service.updateProduct(product);
        }
        return "redirect:/stock";
    }
}