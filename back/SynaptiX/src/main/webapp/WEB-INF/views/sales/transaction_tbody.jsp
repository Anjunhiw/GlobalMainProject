<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<table class="table">
  <thead>
    <tr>
      <th>거래명세서번호</th>
      <th>거래일자</th>
      <th>제품코드</th>
      <th>제품명</th>
      <th>수량</th>
      <th>단가</th>
      <th>금액</th>
      <th>판매수익</th>
    </tr>
  </thead>
  <tbody>
    <c:forEach var="row" items="${transactionList}">
      <tr>
        <td><fmt:formatDate value="${row.date}" pattern="yyyyMM"/>-${row.pk}</td>
        <td><fmt:formatDate value="${row.date}" pattern="yyyy-MM-dd"/></td>
        <td>prod2025<c:choose><c:when test="${row.productId lt 10}">0${row.productId}</c:when><c:otherwise>${row.productId}</c:otherwise></c:choose></td>
        <td>${row.prodName}</td>
        <td class="text-right">
          <fmt:formatNumber value="${row.sales}" type="number" maxFractionDigits="0" groupingUsed="true"/>
        </td>
        <td class="text-right">
          <fmt:formatNumber value="${row.unitPrice}" type="number" groupingUsed="true"/>
        </td>
        <td class="text-right">
          <fmt:formatNumber value="${row.amount}" type="number" groupingUsed="true"/>
        </td>
        <td class="text-right">
          <fmt:formatNumber value="${row.earning}" type="number" groupingUsed="true"/>
        </td>
      </tr>
    </c:forEach>
    <c:if test="${empty transactionList}">
      <tr>
        <td colspan="8" style="text-align:center;">검색 결과가 없습니다.</td>
      </tr>
    </c:if>
  </tbody>
</table>