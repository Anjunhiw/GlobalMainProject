package com.example.demo.controller;

import com.example.demo.model.MaterialDTO;
import com.example.demo.model.ProductDTO;
import com.example.demo.service.StockService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.List;

@Controller
public class StockController {
    private final StockService service;

    public StockController(StockService service) {
        this.service = service;
    }

    @GetMapping("/stock")
    public String showStockList(Model model) {
        List<MaterialDTO> materials = service.getAllMaterials();
        List<ProductDTO> products = service.getAllProducts();
        model.addAttribute("materials", materials);
        model.addAttribute("products", products);
        return "StockList";
    }

    @PostMapping("/searchStock")
    @ResponseBody
    public String searchStock(@RequestParam("category") String category,
                             @RequestParam("name") String name) {
        StringBuilder html = new StringBuilder();
        if ("material".equals(category)) {
            List<MaterialDTO> materials = service.searchMaterialsByName(name);
            html.append("<table><thead><tr><th>PK</th><th>카테고리</th><th>원자재명</th><th>규격</th><th>단위</th><th>가격</th><th>재고량</th><th>입고금액</th></tr></thead><tbody>");
            for (MaterialDTO material : materials) {
                html.append("<tr>")
                    .append("<td>").append(material.getPk()).append("</td>")
                    .append("<td>").append(material.getCategory()).append("</td>")
                    .append("<td>").append(material.getName()).append("</td>")
                    .append("<td>").append(material.getSpecification()).append("</td>")
                    .append("<td>").append(material.getUnit()).append("</td>")
                    .append("<td>").append(material.getPrice()).append("</td>")
                    .append("<td>").append(material.getStock()).append("</td>")
                    .append("<td>").append(material.getAmount()).append("</td>")
                    .append("</tr>");
            }
            html.append("</tbody></table>");
        } else if ("product".equals(category)) {
            List<ProductDTO> products = service.searchProductsByName(name);
            html.append("<table><thead><tr><th>PK</th><th>카테고리</th><th>제품명</th><th>모델명</th><th>규격</th><th>단가</th><th>재고량</th><th>재고금액</th></tr></thead><tbody>");
            for (ProductDTO product : products) {
                html.append("<tr>")
                    .append("<td>").append(product.getPk()).append("</td>")
                    .append("<td>").append(product.getCategory()).append("</td>")
                    .append("<td>").append(product.getName()).append("</td>")
                    .append("<td>").append(product.getModel()).append("</td>")
                    .append("<td>").append(product.getSpecification()).append("</td>")
                    .append("<td>").append(product.getPrice()).append("</td>")
                    .append("<td>").append(product.getStock()).append("</td>")
                    .append("<td>").append(product.getAmount()).append("</td>")
                    .append("</tr>");
            }
            html.append("</tbody></table>");
        }
        return html.toString();
    }

    @GetMapping("/stock/edit")
    public String showEditForm(@RequestParam("pk") int pk, @RequestParam("category") String category, Model model) {
        if ("material".equals(category)) {
            MaterialDTO material = service.getMaterialByPk(pk);
            model.addAttribute("material", material);
            model.addAttribute("product", null); // 명시적으로 product를 null 처리
        } else if ("product".equals(category)) {
            ProductDTO product = service.getProductByPk(pk);
            model.addAttribute("product", product);
            model.addAttribute("material", null); // 명시적으로 material을 null 처리
        } else {
			model.addAttribute("material", null);
			model.addAttribute("product", null);
		}
        return "StockEdit";
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
    public String deleteStock(@RequestParam("pk") int pk, @RequestParam("category") String category) {
        if ("material".equals(category)) {
            service.deleteMaterial(pk);
        } else if ("product".equals(category)) {
            service.deleteProduct(pk);
        }
        return "redirect:/stock";
    }
}