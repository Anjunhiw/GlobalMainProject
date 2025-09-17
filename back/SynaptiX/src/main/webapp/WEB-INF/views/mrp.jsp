<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
request.setAttribute("pageTitle", "MRP");
%>
<%
request.setAttribute("subNav", "<a href='/sales'>판매출고</a> <a href='/purchase'>구매입고</a><a href='/order'>주문관리</a> <a href='/transaction'>거래명세서</a> <a href='/earning'>매출</a> <a href='/mrp'>MRP</a>");
%>
<%@ include file="header.jsp" %>
<div class="container">
    <h2>MRP 내역</h2>
    <table border="1" style="width:100%; text-align:center;">
        <thead>
            <tr>
                <th>번호</th>
                <th>제품명</th>
                <th>필요 원자재</th>
				<th>재고량</th>
				<th>필요량</th>
                <th>계획일자</th>
                <th>상태</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="mrp" items="${mrpList}">
                <tr>
                    <td>${mrp.pk}</td>
                    <td>${mrp.ProductName}</td>
                    <td>${mrp.MaterialName}</td>
                    <td>${mrp.StockQuantity}</td>
                    <td>${mrp.RequiredQuantity}</td>
                    <td>${mrp.ProductionPlan}</td>
                    <td>${mrp.MRPStatus}</td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
<%@ include file="footer.jsp" %>