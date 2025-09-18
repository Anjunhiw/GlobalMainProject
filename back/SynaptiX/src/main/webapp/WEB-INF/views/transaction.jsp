<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
request.setAttribute("pageTitle", "거래명세서");
request.setAttribute("subNavPage", "common/subnav_sales.jsp");
%>
<%@ include file="header.jsp" %>
<div class="container">
    <h2>거래명세서 내역</h2>
    <table border="1" style="width:100%; text-align:center;">
        <thead>
            <tr>
                <th>거래명세서번호</th>
                <th>거래일자</th>
                <th>제품아이디</th>
                <th>제품명</th>
                <th>수량</th>
                <th>단가</th>
                <th>총액</th>
				<th>판매수익</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="transaction" items="${transactionList}">
                <tr>
                    <td>${transaction.pk}</td>
                    <td>${transaction.Date}</td>
                    <td>${transaction.ProductId}</td>
                    <td>${transaction.ProductName}</td>
                    <td>${transaction.Amount}</td>
                    <td>${transaction.Price}</td>
                    <td>${transaction.Total}</td>
                    <td>${transaction.Earning}</td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
<%@ include file="footer.jsp" %>