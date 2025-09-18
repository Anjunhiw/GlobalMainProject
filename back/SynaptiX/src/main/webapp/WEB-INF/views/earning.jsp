<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
request.setAttribute("pageTitle", "매출");
request.setAttribute("subNavPage", "common/subnav_sales.jsp");
%>
<%@ include file="header.jsp" %>
<div class="container">
    <h2>매출 내역</h2>
    <table border="1" style="width:100%; text-align:center;">
        <thead>
            <tr>
                <th>제품아이디</th>
                <th>판매일자</th> 
                <th>제품명</th>
                <th>판매수량</th>
                <th>원가</th>
                <th>총액</th>
                <th>순이익</th>
                <th>재고량</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="earning" items="${earningList}">
                <tr>
                    <td>${earning.ProductId}</td>
                    <td>${earning.Date}</td>
                    <td>${earning.ProductName}</td>
                    <td>${earning.Amount}</td>
                    <td>${earning.Price}</td>
                    <td>${earning.Total}</td>
                    <td>${earning.Earning}</td>
                    <td>${earning.Stock}</td>
                </tr>
            </c:forEach>
        </tbody>
		</table>
<%@ include file="footer.jsp" %>