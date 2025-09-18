<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
request.setAttribute("pageTitle", "구매입고");
request.setAttribute("subNavPage", "common/subnav_sales.jsp");
%>
<%@ include file="header.jsp" %>

<div class="container">
    <h2>구매입고 내역</h2>
    <table border="1" style="width:100%; text-align:center;">
        <thead>
            <tr>
                <th>구매일</th>
                <th>제품아이디</th>
                <th>제품명</th>
                <th>구매량</th>
                <th>구매액</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="purchase" items="${purchaseList}">
                <tr>
                    <td>${purchase.date}</td>
                    <td>${purchase.materialId}</td>
                    <td>${purchase.materialName}</td>
                    <td>${purchase.purchase}</td>
                    <td>${purchase.cost}</td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</div>

<%@ include file="footer.jsp" %>