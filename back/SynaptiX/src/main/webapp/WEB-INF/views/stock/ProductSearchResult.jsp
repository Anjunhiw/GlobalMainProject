<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"  %>
<table>
  <thead>
    <tr>
      <th>품목코드</th><th>제품명</th><th>모델명</th><th>규격</th>
      <th>단가</th><th>재고수량</th><th>재고금액</th><th>수정</th><th>삭제</th>
    </tr>
  </thead>
  <tbody>
    <c:forEach var="product" items="${products}">
      <tr>
        <td>prd2025<c:choose><c:when test="${product.pk lt 10}">0${product.pk}</c:when><c:otherwise>${product.pk}</c:otherwise></c:choose></td>
        <td>${product.name}</td>
        <td>${product.model}</td>
        <td>${product.specification}</td>
        <td><fmt:formatNumber value="${product.price}"  type="number" groupingUsed="true"/></td>
        <td><fmt:formatNumber value="${product.stock}"  type="number" maxFractionDigits="0" groupingUsed="true"/></td>
        <td><fmt:formatNumber value="${product.amount}" type="number" maxFractionDigits="0" groupingUsed="true"/></td>
        <td>
          <button type="button" class="btn btn-sm btn-warning" onclick="openEditModal('${product.pk}', this)">수정</button>
        </td>
        <td>
          <button type="button" class="btn btn-sm btn-danger btn-del" data-pk="${product.pk}">삭제</button>
        </td>
      </tr>
    </c:forEach>
    <c:if test="${empty products}">
      <tr>
        <td colspan="9" class="empty-msg">
          제품 데이터가 없습니다.
        </td>
      </tr>
    </c:if>
  </tbody>
</table>
