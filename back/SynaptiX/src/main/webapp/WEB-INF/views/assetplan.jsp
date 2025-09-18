<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
request.setAttribute("pageTitle", "자금계획");
request.setAttribute("subNavPage", "common/subnav_managereport.jsp");
%>
<%@ include file="header.jsp" %>
<div class="container">
    <h2>자금 계획</h2>
    <table border="1" style="width:70%; text-align:center;">
        <tr>
            <th>예정일</th>
            <th>제품명</th>
            <th>단가</th>
            <th>예상판매량</th>
            <th>예상수익</th>
        </tr>
        <c:forEach var="plan" items="${assetPlans}">
            <tr>
                <td>${plan.date}</td>
                <td>${plan.productName}</td>
                <td>${plan.price}</td>
                <td>${plan.amount}</td>
                <td>${plan.price * plan.amount}</td>
            </tr>
        </c:forEach>
    </table>
</div>
<%@ include file="footer.jsp" %>