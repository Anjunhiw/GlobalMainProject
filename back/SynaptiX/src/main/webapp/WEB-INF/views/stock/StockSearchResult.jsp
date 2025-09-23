<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!-- 원자재 검색 결과 테이블 -->
<c:if test="${not empty materials}">
  <h3>원자재 검색 결과</h3>
  <table>
    <thead>
      <tr>
        <th>품목코드</th><th>품목명</th><th>카테고리</th><th>규격</th><th>단위</th>
        <th>단가</th><th>재고수량</th><th>재고금액</th>
      </tr>
    </thead>
    <tbody>
      <c:forEach var="material" items="${materials}">
        <tr>
          <td>mtr2025<c:choose><c:when test="${material.pk lt 10}">0${material.pk}</c:when><c:otherwise>${material.pk}</c:otherwise></c:choose></td>
          <td>${material.name}</td>
          <td>${material.category}</td>
          <td>${material.specification}</td>
          <td>${material.unit}</td>
          <td><fmt:formatNumber value="${material.price}"  type="number" groupingUsed="true"/></td>
          <td><fmt:formatNumber value="${material.stock}"  type="number" maxFractionDigits="0" groupingUsed="true"/></td>
          <td><fmt:formatNumber value="${material.amount}" type="number" maxFractionDigits="0" groupingUsed="true"/></td>
        </tr>
      </c:forEach>
    </tbody>
  </table>
</c:if>
<br
<!-- 제품 검색 결과 테이블 -->
<c:if test="${not empty products}">
  <h3>제품 검색 결과</h3>
  <table>
    <thead>
      <tr>
        <th>품목코드</th><th>카테고리</th><th>제품명</th><th>모델명</th><th>규격</th>
        <th>단가</th><th>재고량</th><th>재고금액</th>
      </tr>
    </thead>
    <tbody>
      <c:forEach var="product" items="${products}">
        <tr>
          <td>prod2025<c:choose><c:when test="${product.pk lt 10}">0${product.pk}</c:when><c:otherwise>${product.pk}</c:otherwise></c:choose></td>
          <td>${product.category}</td>
          <td>${product.name}</td>
          <td>${product.model}</td>
          <td>${product.specification}</td>
          <td><fmt:formatNumber value="${product.price}"  type="number" groupingUsed="true"/></td>
          <td><fmt:formatNumber value="${product.stock}"  type="number" maxFractionDigits="0" groupingUsed="true"/></td>
          <td><fmt:formatNumber value="${product.amount}" type="number" maxFractionDigits="0" groupingUsed="true"/></td>
        </tr>
      </c:forEach>
    </tbody>
  </table>
</c:if>

<c:if test="${empty materials and empty products}">
  <div>검색 결과가 없습니다.</div>
</c:if>