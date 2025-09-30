<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<table class="profit-table">
  <thead>
    <tr>
      <th rowspan="2">품목코드</th>
      <th rowspan="2">품목명</th>
      <th colspan="3">판매</th>
      <th colspan="2">원가</th>
      <th colspan="2">이익</th>
      <th rowspan="2">이익률</th>
    </tr>
    <tr>
      <th>수량</th>
      <th>단가</th>
      <th>금액</th>
      <th>단가</th>
      <th>금액</th>
      <th>단가</th>
      <th>금액</th>
    </tr>
  </thead>
  <tbody>
    <c:forEach var="item" items="${profitList}">
      <tr>
        <td>${item.code}</td>
        <td>${item.name}</td>
        <td><fmt:formatNumber value="${item.salesQty}" /></td>
        <td><fmt:formatNumber value="${item.salesPrice}" /></td>
        <td><fmt:formatNumber value="${item.salesAmount}" /></td>
        <td><fmt:formatNumber value="${item.costPrice}" /></td>
        <td><fmt:formatNumber value="${item.costAmount}" /></td>
        <td><fmt:formatNumber value="${item.profitUnit}" /></td>
        <td><fmt:formatNumber value="${item.profitAmount}" /></td>
        <td><fmt:formatNumber value="${item.profitRate}" />%</td>
      </tr>
    </c:forEach>
    <c:if test="${empty profitList}">
      <tr>
        <td colspan="10">데이터가 없습니다.</td>
      </tr>
    </c:if>
  </tbody>
</table>