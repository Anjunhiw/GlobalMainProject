<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<table class="table">
  <thead>
    <tr>
      <th>주문번호</th>
      <th>주문일자</th>
      <th>제품코드</th>
      <th>제품명</th>
      <th>수량</th>
      <th>단가</th>
      <th>금액</th>
      <th>주문상태</th>
    </tr>
  </thead>
  <tbody>
    <c:forEach var="o" items="${orderList}">
      <tr>
        <td>${o.orderNo}</td>
        <td><fmt:formatDate value="${o.orderDate}" pattern="yyyy-MM-dd"/></td>
        <td>prod2025<c:choose><c:when test="${o.prodCode lt 10}">0${o.prodCode}</c:when><c:otherwise>${o.prodCode}</c:otherwise></c:choose></td>
        <td>${o.prodName}</td>
        <td class="text-right"><fmt:formatNumber value="${o.qty}" type="number" maxFractionDigits="0" groupingUsed="true"/></td>
        <td class="text-right"><fmt:formatNumber value="${o.unitPrice}" type="number" groupingUsed="true"/></td>
        <td class="text-right"><fmt:formatNumber value="${o.amount}" type="number" groupingUsed="true"/></td>
        <td>${o.status}</td>
      </tr>
    </c:forEach>
    <c:if test="${empty orderList}">
      <tr>
        <td colspan="8" style="text-align:center;">검색 결과가 없습니다.</td>
      </tr>
    </c:if>
  </tbody>
</table>
