<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<table class="table">
  <thead>
    <tr>
      <th>출고번호</th>
      <th>출고일</th>
      <th>제품코드</th>
      <th>제품명</th>
      <th>수량</th>
      <th>단가</th>
      <th>금액</th>
      <th>출고상태</th>
    </tr>
  </thead>
  <tbody>
    <c:forEach var="row" items="${salesList}">
      <fmt:formatDate value="${row.saleDate}" pattern="yyyy-MM-dd" var="saleDateStr"/>
      <tr>
        <td>${row.pk}</td>
        <td><fmt:formatDate value="${row.saleDate}" pattern="yyyy-MM-dd"/></td>
        <td>prod2025<c:choose><c:when test="${row.productId lt 10}">0${row.productId}</c:when><c:otherwise>${row.productId}</c:otherwise></c:choose></td>
        <td>${row.productName}</td>
        <td class="text-right">
          <fmt:formatNumber value="${row.quantity}" type="number" groupingUsed="true"/>
        </td>
        <td><fmt:formatNumber value="${row.price}" type="number" groupingUsed="true"/></td>
        <td class="text-right">
          <fmt:formatNumber value="${row.earning}" type="number" groupingUsed="true"/>
        </td>
        <td>
          <c:choose>
            <c:when test="${saleDateStr lt today}">출고완료</c:when>
            <c:otherwise>출고준비</c:otherwise>
          </c:choose>
        </td>
      </tr>
    </c:forEach>
    <c:if test="${empty salesList}">
      <tr>
        <td colspan="8" style="text-align:center;">검색 결과가 없습니다.</td>
      </tr>
    </c:if>
  </tbody>
</table>