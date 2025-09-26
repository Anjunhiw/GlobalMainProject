<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<table class="table">
  <thead>
    <tr>
      <th>제품코드</th>
      <th>판매일자</th>
      <th>제품명</th>
      <th>판매수량</th>
      <th>판매금액</th>
      <th>원가</th>
      <th>순이익</th>
      <th>재고량</th>
    </tr>
  </thead>
  <tbody>
    <c:forEach var="s" items="${earningList}">
      <tr>
        <td>${s.ProductId}</td>
        <td><fmt:formatDate value="${s.Date}" pattern="yyyy-MM-dd"/></td>
        <td>${s.ProductName}</td>
        <td class="text-right"><fmt:formatNumber value="${s.Amount}" type="number" maxFractionDigits="0" groupingUsed="true"/></td>
        <td class="text-right"><fmt:formatNumber value="${s.Price}" type="number" groupingUsed="true"/></td>
        <td class="text-right"><fmt:formatNumber value="${s.Total}"  type="number" groupingUsed="true"/></td>
        <td class="text-right">
          <fmt:formatNumber value="${s.Earning}" type="number" groupingUsed="true"/>
        </td>
        <td class="text-right"><fmt:formatNumber value="${s.Stock}" type="number" maxFractionDigits="0" groupingUsed="true"/></td>
      </tr>
    </c:forEach>
    <c:if test="${empty earningList}">
      <tr><td colspan="8" style="text-align:center;">검색 결과가 없습니다.</td></tr>
    </c:if>
  </tbody>
</table>
