<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<table class="table">
  <thead>
    <tr>
      <th>제품명</th>
      <th>필요 원자재</th>
      <th>필요량</th>
      <th>현재재고</th>
      <th>추가재고필요량</th>
      <th>계획일자</th>
    </tr>
  </thead>
  <tbody>
    <c:forEach var="m" items="${mrpList}">
      <tr>
        <td>${m.ProductName}</td>
        <td>${m.MaterialName}</td>
        <td class="text-right"><fmt:formatNumber value="${m.RequiredQuantity}" type="number" maxFractionDigits="0"/></td>
        <td class="text-right"><fmt:formatNumber value="${m.StockQuantity}" type="number" maxFractionDigits="0"/></td>
        <td class="text-right">
          <fmt:formatNumber value="${m.Shortage}" type="number" maxFractionDigits="0"/>
        </td>
        <td><fmt:formatDate value="${m.ProductionPlan}" pattern="yyyy-MM-dd"/></td>
      </tr>
    </c:forEach>
    <c:if test="${empty mrpList}">
      <tr><td colspan="6" style="text-align:center;">검색 결과가 없습니다.</td></tr>
    </c:if>
  </tbody>
</table>
