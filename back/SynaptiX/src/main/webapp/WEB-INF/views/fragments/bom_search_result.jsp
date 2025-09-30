<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<table border="1">
  <tr>
    <th>제품코드</th>
    <th>생산제품명</th>
    <th>소요원자재명</th>
    <th>소요원자재량</th>
    <th>소요금액</th>
    <th>수정</th>
  </tr>
  <c:forEach var="bom" items="${bomList}">
    <c:set var="price" value="0"/>
    <c:forEach var="mat" items="${materialList}">
      <c:if test="${mat.pk == bom.materialId}">
        <c:set var="price" value="${mat.price}"/>
      </c:if>
    </c:forEach>
    <tr>
      <td>prod2025<c:choose><c:when test="${bom.productId lt 10}">0${bom.productId}</c:when><c:otherwise>${bom.productId}</c:otherwise></c:choose></td>
      <td>${bom.productName}</td>
      <td>${bom.materialName}</td>
      <td><fmt:formatNumber value="${bom.materialAmount}" type="number" maxFractionDigits="2"/></td>
      <td><fmt:formatNumber value="${bom.materialAmount * price}" type="number" maxFractionDigits="0"/></td>
      <td>
        <button type="button" class="btn btn-edit"
          onclick="openBomEditModal('${bom.productId}', '${bom.materialId}', '${bom.materialAmount != null ? bom.materialAmount : ''}')"
        >수정</button>
      </td>
    </tr>
  </c:forEach>
  <c:if test="${empty bomList}">
    <tr><td colspan="6">데이터가 없습니다.</td></tr>
  </c:if>
</table>
