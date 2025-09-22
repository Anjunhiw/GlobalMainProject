<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
request.setAttribute("pageTitle", "판매출고");
request.setAttribute("active_sales", "active");
request.setAttribute("active_sale", "active");
%>
<%@ include file="../common/header.jsp" %>
<div class="container">
    <h2>판매출고 내역</h2>
    <table border="1" style="width:100%; text-align:center;">
        <thead>
            <tr>
                <th>판매일</th>
                <th>제품아이디</th>
                <th>제품명</th>
                <th>판매량</th>
                <th>판매액</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="sale" items="${salesList}">
                <tr>
                    <td>${sale.saleDate}</td>
                    <td>${sale.productId}</td>
                    <td>${sale.productName}</td>
                    <td><fmt:formatNumber value="${sale.quantity}" type="number"/></td>
                    <td><fmt:formatNumber value="${sale.amount}" type="number"/></td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</div>

<%@ include file="../common/footer.jsp" %>