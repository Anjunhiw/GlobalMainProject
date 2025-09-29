package com.example.demo.controller.sales;

import com.example.demo.model.TransactionDTO;
import com.example.demo.mapper.sales.TransactionMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;


import java.util.List;
import java.util.Map;

@Controller
public class TransactionController {
    @Autowired
    private TransactionMapper transactionMapper;

    @GetMapping("/transaction")
    public String transactionList(Model model) {
        List<TransactionDTO> transactionList = transactionMapper.selectAllTransactions();
        model.addAttribute("transactionList", transactionList);
        return "sales/transaction";
    }

    @GetMapping("/transaction/search")
    public String searchTransactions(
            @RequestParam(value = "prodCode", required = false) String prodCode,
            @RequestParam(value = "prodName", required = false) String prodName,
            @RequestParam(value = "date", required = false) String date,
            @RequestParam(value = "stmtNo", required = false) String stmtNo,
            Model model) {
        Map<String, Object> param = new java.util.HashMap<>();
        if (prodCode != null && !prodCode.isEmpty()) param.put("prodCode", prodCode);
        if (prodName != null && !prodName.isEmpty()) param.put("prodName", prodName);
        if (date != null && !date.isEmpty()) param.put("date", date);
        if (stmtNo != null && !stmtNo.isEmpty()) param.put("stmtNo", stmtNo);
        List<TransactionDTO> transactionList = transactionMapper.selectTransactionsByCondition(param);
        model.addAttribute("transactionList", transactionList);
        return "sales/transaction_tbody";
    }
}