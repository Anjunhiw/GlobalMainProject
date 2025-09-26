<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<table class="table">
  <thead>
    <tr>
      <th>구매일자</th>
      <th>원자재명</th>
      <th>구매량</th>
      <th>단가</th>
      <th>구매금액</th>
    </tr>
  </thead>
  <tbody>
    <c:forEach var="cost" items="${costList}">
      <tr>
        <td><fmt:formatDate value="${cost.date}" pattern="yyyy-MM-dd"/></td>
        <td>${cost.materialName}</td>
        <td><fmt:formatNumber value="${cost.purchase}"/></td>
        <td><fmt:formatNumber value="${cost.price}"/></td>
        <td><fmt:formatNumber value="${cost.cost}"/></td>
      </tr>
    </c:forEach>
    <c:if test="${empty costList}">
      <tr><td colspan="5" style="text-align:center;">검색 결과가 없습니다.</td></tr>
    </c:if>
  </tbody>
</table>
