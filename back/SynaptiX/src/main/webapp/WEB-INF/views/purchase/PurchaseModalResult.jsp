<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<table class="table">
  <thead>
    <tr>
      <th>구매번호</th>
      <th>원자재명</th>
      <th>단가</th>
      <th>구매량</th>
      <th>구매금액</th>
      <th>입고일</th>
      <th>재고량</th>
      <th>재고금액</th>
    </tr>
  </thead>
  <tbody>
    <c:forEach var="p" items="${purchaseList}">
      <tr>
        <td>${p.pk}</td>
        <td>${p.materialName}</td>
        <td><fmt:formatNumber value="${p.price}"/></td>
        <td class="text-right"><fmt:formatNumber value="${p.purchase}" type="number" groupingUsed="true"/></td>
        <td class="text-right"><fmt:formatNumber value="${p.cost}" type="number" groupingUsed="true"/></td>
        <td><fmt:formatDate value="${p.date}" pattern="yyyy-MM-dd"/></td>
        <td><fmt:formatNumber value="${p.stock}" type="number" groupingUsed="true"/></td>
        <td><fmt:formatNumber value="${p.amount}" type="number" groupingUsed="true"/></td>
      </tr>
    </c:forEach>
    <c:if test="${empty purchaseList}">
      <tr><td colspan="8" style="text-align:center;">검색 결과가 없습니다.</td></tr>
    </c:if>
  </tbody>
</table>
