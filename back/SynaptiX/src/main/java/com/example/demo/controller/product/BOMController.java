package com.example.demo.controller.product;

import com.example.demo.model.BOMDTO;
import com.example.demo.model.ProductDTO;
import com.example.demo.model.MaterialDTO;
import com.example.demo.service.product.BOMService;
import com.example.demo.service.stock.StockService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@Controller
@RequestMapping("/bom")
public class BOMController {
    @Autowired
    private BOMService bomService;

    @Autowired
    private StockService stockService;

    @GetMapping("")
    public String showBOM(@RequestParam(value = "category", required = false) String category,
                         @RequestParam(value = "name", required = false) String name,
                         @RequestParam(value = "id", required = false) String id,
                         Model model) {
        List<BOMDTO> bomList;
        if ((category != null && !category.isEmpty()) || (id != null && !id.isEmpty())) {
            bomList = bomService.getFilteredBOMWithNames(category, id);
        } else {
            bomList = bomService.getAllBOMWithNames();
        }
        List<ProductDTO> productList = stockService.getAllProducts();
        List<MaterialDTO> materialList = stockService.getAllMaterials();
        model.addAttribute("bomList", bomList);
        model.addAttribute("productList", productList);
        model.addAttribute("materialList", materialList);
        return "product/bom";
    }

    @PostMapping
    public void addBOM(@RequestBody BOMDTO bomDTO) {
        bomService.addBOM(bomDTO);
    }

    @PutMapping("")
    @ResponseBody
    public java.util.Map<String, Object> updateBOM(@RequestBody BOMDTO bomDTO) {
        bomService.updateBOM(bomDTO);
        java.util.Map<String, Object> result = new java.util.HashMap<>();
        result.put("success", true);
        return result;
    }

    @PostMapping("/search")
    public String searchBOM(@RequestBody java.util.Map<String, String> params, Model model) {
        String code = params.getOrDefault("code", null);
        String name = params.getOrDefault("name", null);
        // 카테고리는 입력만 받고 실제 검색 조건에는 반영하지 않음
        String modelCode = params.getOrDefault("model", null);
        String materialName = params.getOrDefault("materialName", null);
        List<BOMDTO> bomList = bomService.searchBOM(code, name, null, modelCode, materialName);
        List<ProductDTO> productList = stockService.getAllProducts();
        List<MaterialDTO> materialList = stockService.getAllMaterials();
        model.addAttribute("bomList", bomList);
        model.addAttribute("productList", productList);
        model.addAttribute("materialList", materialList);
        return "fragments/bom_search_result";
    }

    @PostMapping("/register")
    @ResponseBody
    public java.util.Map<String, Object> registerBOM(@RequestBody BOMDTO bomDTO) {
        bomService.addBOM(bomDTO);
        java.util.Map<String, Object> result = new java.util.HashMap<>();
        result.put("success", true);
        return result;
    }
}