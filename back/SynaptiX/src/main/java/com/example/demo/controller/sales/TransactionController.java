package com.example.demo.controller.sales;

import com.example.demo.mapper.sales.TransactionMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import java.util.List;
import java.util.Map;

@Controller
public class TransactionController {
    @Autowired
    private TransactionMapper transactionMapper;

    @GetMapping("/transaction")
    public String transactionList(Model model) {
        List<Map<String, Object>> transactionList = transactionMapper.selectAllTransactions();
        model.addAttribute("transactionList", transactionList);
        return "sales/transaction";
    }
}