<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
request.setAttribute("pageTitle", "주문관리");
%>
<%
request.setAttribute("subNav", "<a href='/sales'>판매출고</a> <a href='/purchase'>구매입고</a><a href='/order'>주문관리</a> <a href='/transaction'>거래명세서</a> <a href='/earning'>매출</a> <a href='/mrp'>MRP</a>");
%>
<%@ include file="header.jsp" %>
<div class="container">
    <h2>주문관리 내역</h2>
    <table border="1" style="width:100%; text-align:center;">
        <thead>
            <tr>
                <th>주문번호</th>
                <th>주문일자</th>
                <th>제품아이디</th>
				<th>제품명</th>
                <th>수량</th>
                <th>단가</th>
				<th>총액</th>
				<th>주문상태</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="order" items="${orderList}" varStatus="status" >
                <tr>
					<td>${status.index}</td>
                    <td>${order.date}</td>
                    <td>${order.productId}</td>
                    <td>${order.productName}</td>
                    <td>${order.quantity}</td>
                    <td>${order.price}</td>
					<td>${order.total}</td>
					<td>${order.status}</td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
<%@ include file="footer.jsp" %>