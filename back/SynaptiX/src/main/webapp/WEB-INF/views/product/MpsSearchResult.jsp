<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:if test="${not empty list}">
  <table class="table">
    <thead>
      <tr>
        <th>제품코드</th>
        <th>제품명</th>
        <th>생산량</th>
        <th>기간(종료날짜)</th>
        <th>생산금액</th>
      </tr>
    </thead>
    <tbody>
      <c:forEach var="plan" items="${list}">
        <tr>
          <td>prod2025<c:choose><c:when test="${plan.productId lt 10}">0${plan.productId}</c:when><c:otherwise>${plan.productId}</c:otherwise></c:choose></td>
          <td>${plan.productName}</td>
          <td><fmt:formatNumber value="${plan.volume}" type="number" maxFractionDigits="0"/></td>
          <td>${plan.period}</td>
          <td><fmt:formatNumber value="${plan.price * plan.volume}" type="number" groupingUsed="true"/></td>
        </tr>
      </c:forEach>
    </tbody>
  </table>
</c:if>
<c:if test="${empty list}">
  <div style="text-align:center; padding:30px;">검색 결과가 없습니다.</div>
</c:if>
