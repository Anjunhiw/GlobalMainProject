<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<table class="table">
  <thead>
    <tr>
      <th>예정일</th>
      <th>제품명</th>
      <th>단가</th>
      <th>예상판매량</th>
      <th>예상수익</th>
    </tr>
  </thead>
  <tbody>
    <c:forEach var="plan" items="${assetPlans}">
      <tr>
        <td>${plan.date}</td>
        <td>${plan.productName}</td>
        <td class="text-right"><fmt:formatNumber value="${plan.price}" type="number"/></td>
        <td class="text-right"><fmt:formatNumber value="${plan.amount}" type="number"/></td>
        <td class="text-right"><fmt:formatNumber value="1" type="number"/></td>
      </tr>
    </c:forEach>
    <c:if test="${empty assetPlans}">
      <tr><td colspan="5" style="text-align:center;">검색 결과가 없습니다.</td></tr>
    </c:if>
  </tbody>
</table>
