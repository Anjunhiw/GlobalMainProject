package com.example.demo.controller;

import com.example.demo.model.BOMDTO;
import com.example.demo.model.ProductDTO;
import com.example.demo.model.MaterialDTO;
import com.example.demo.service.BOMService;
import com.example.demo.service.StockService;
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
    public String showBOM(Model model) {
        List<BOMDTO> bomList = bomService.getAllBOM();
        List<ProductDTO> productList = stockService.getAllProducts();
        List<MaterialDTO> materialList = stockService.getAllMaterials();
        model.addAttribute("bomList", bomList);
        model.addAttribute("productList", productList);
        model.addAttribute("materialList", materialList);
        return "bom";
    }

    @PostMapping
    public void addBOM(@RequestBody BOMDTO bomDTO) {
        bomService.addBOM(bomDTO);
    }
}