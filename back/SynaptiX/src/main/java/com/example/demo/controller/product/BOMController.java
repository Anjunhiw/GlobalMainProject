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
}