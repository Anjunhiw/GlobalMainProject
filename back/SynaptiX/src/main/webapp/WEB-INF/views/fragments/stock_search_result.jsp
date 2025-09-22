<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"  %>

<h4>원자재 검색 결과</h4>
<table class="tbl">
  <thead>
    <tr>
      <th>PK</th><th>카테고리</th><th>원자재명</th><th>규격</th><th>단위</th>
      <th>가격</th><th>재고량</th><th>입고금액</th><th>품목수정</th><th>품목삭제</th>
    </tr>
  </thead>
  <tbody>
    <c:forEach var="m" items="${materials}">
      <tr>
        <td>${m.pk}</td>
        <td>${m.category}</td>
        <td>${m.name}</td>
        <td>${m.specification}</td>
        <td>${m.unit}</td>
        <td><fmt:formatNumber value="${m.price}" type="number" groupingUsed="true"/></td>
        <td><fmt:formatNumber value="${m.stock}" type="number" maxFractionDigits="0" groupingUsed="true"/></td>
        <td><fmt:formatNumber value="${m.amount}" type="number" maxFractionDigits="0" groupingUsed="true"/></td>

        <td>
          <form action="<c:url value='/stock/edit'/>" method="get">
            <input type="hidden" name="pk" value="${m.pk}">
            <input type="hidden" name="category" value="materials">
            <button type="submit" class="btn btn-sm btn-warning">수정</button>
          </form>
        </td>
        <td>
          <form action="<c:url value='/stock/delete'/>" method="post"
                onsubmit="return confirm('삭제하시겠습니까?');">
            <input type="hidden" name="pk" value="${m.pk}">
            <input type="hidden" name="category" value="materials">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
            <button type="submit" class="btn btn-sm btn-danger">삭제</button>
          </form>
        </td>
      </tr>
    </c:forEach>
    <c:if test="${empty materials}">
      <tr><td colspan="10" class="empty">원자재 데이터가 없습니다.</td></tr>
    </c:if>
  </tbody>
</table>

<h4>제품 검색 결과</h4>
<table class="tbl">
  <thead>
    <tr>
      <th>PK</th><th>카테고리</th><th>제품명</th><th>모델명</th><th>규격</th>
      <th>단가</th><th>재고량</th><th>재고금액</th><th>품목수정</th><th>품목삭제</th>
    </tr>
  </thead>
  <tbody>
    <c:forEach var="p" items="${products}">
      <tr>
        <td>${p.pk}</td>
        <td>${p.category}</td>
        <td>${p.name}</td>
        <td>${p.model}</td>
        <td>${p.specification}</td>
        <td><fmt:formatNumber value="${p.price}" type="number" groupingUsed="true"/></td>
        <td><fmt:formatNumber value="${p.stock}" type="number" maxFractionDigits="0" groupingUsed="true"/></td>
        <td><fmt:formatNumber value="${p.amount}" type="number" maxFractionDigits="0" groupingUsed="true"/></td>

        <td>
          <form action="<c:url value='/stock/edit'/>" method="get">
            <input type="hidden" name="pk" value="${p.pk}">
            <input type="hidden" name="category" value="product">
            <button type="submit" class="btn btn-sm btn-warning">수정</button>
          </form>
        </td>
        <td>
          <form action="<c:url value='/stock/delete'/>" method="post"
                onsubmit="return confirm('삭제하시겠습니까?');">
            <input type="hidden" name="pk" value="${p.pk}">
            <input type="hidden" name="category" value="product">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
            <button type="submit" class="btn btn-sm btn-danger">삭제</button>
          </form>
        </td>
      </tr>
    </c:forEach>
    <c:if test="${empty products}">
      <tr><td colspan="10" class="empty">제품 데이터가 없습니다.</td></tr>
    </c:if>
  </tbody>
</table>
