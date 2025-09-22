<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
request.setAttribute("pageTitle", "이익 관리");
request.setAttribute("active_product", "active");
request.setAttribute("active_profit", "active");
%>
<%@ include file="../common/header.jsp" %>

<!-- 검색 폼 시작 -->
<form method="get" action="/profit" style="margin-bottom:20px;">
    <label for="item_code">품목코드:</label>
    <input type="text" id="item_code" name="item_code" value="${param.item_code}" />
    &nbsp;
    <label for="item_name">품목명:</label>
    <input type="text" id="item_name" name="item_name" value="${param.item_name}" />
    &nbsp;
    <label for="category">카테고리:</label>
    <select type="text" id="category" name="category" value="${param.category}" />
		<option value="제품">제품</option>
	</select>
    &nbsp;
    <button type="submit">조회</button>
</form>
<!-- 검색 폼 끝 -->

<table border="1">
    <thead>
        <tr>
            <th rowspan="2">품목코드</th>
            <th rowspan="2">품목명</th>
            <th colspan="3">판매</th>
            <th colspan="2">원가</th>
            <th colspan="2">이익</th>
            <th rowspan="2">이익률</th>
        </tr>
        <tr>
            <th>수량</th>
            <th>단가</th>
            <th>금액</th>
            <th>단가</th>
            <th>금액</th>
            <th>단가</th>
            <th>금액</th>
        </tr>
    </thead>
    <tbody>
        <c:forEach var="row" items="${profitList}">
            <tr>
                <td>${row.item_code}</td>
                <td>${row.item_name}</td>
                <td><fmt:formatNumber value="${row.sales_qty}" type="number"/></td>
                <td><fmt:formatNumber value="${row.sales_unit_price}" type="number"/></td>
                <td><fmt:formatNumber value="${row.sales_amount}" type="number"/></td>
                <td><fmt:formatNumber value="${row.cost_unit_price}" type="number"/></td>
                <td><fmt:formatNumber value="${row.cost_amount}" type="number"/></td>
                <td><fmt:formatNumber value="${row.profit_unit_price}" type="number"/></td>
                <td><fmt:formatNumber value="${row.profit_amount}" type="number"/></td>
                <td>${row.profit_rate}</td>
            </tr>
        </c:forEach>
    </tbody>
</table>
<%@ include file="../common/footer.jsp" %>