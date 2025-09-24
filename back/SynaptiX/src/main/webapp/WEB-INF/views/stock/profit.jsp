<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>


<%
request.setAttribute("pageTitle", "이익 관리");
request.setAttribute("active_stock", "active");
request.setAttribute("active_profit", "active");
%>
<%@ include file="../common/header.jsp" %>
<link rel="stylesheet" href="<c:url value='/css/stock.css?v=1'/>">
<link rel="stylesheet" href="<c:url value='/css/bom.css?v=1'/>">

<body>

  <h2>이익관리</h2>

  <!-- 검색 폼 -->
  <form method="get" action="/profit">
    <div class="filter-smallq">
      <div class="field">
        <label for="code">품목코드</label>
        <input type="text" id="code" name="code" placeholder="예: A-1001">
      </div>
      <div class="field">
        <label for="name">품목명</label>
        <input type="text" id="name" name="name" placeholder="예: 모터">
      </div>
      <div class="field">
        <label for="category">카테고리</label>
		<div class="select-wrap">
        <select id="category" name="category">
          <option value="">전체</option>
          <option value="product">제품</option>
          <option value="material">원자재</option>
        </select>
      </div>
	  </div>
      <div class="btn-group">
        <button type="submit" class="btn btn-primary">조회</button>
      </div>
    </div>
  </form>

  <!-- 이익현황 -->
  <h2>품목별 이익현황</h2>
  <table class="profit-table">
    <thead>
      <tr>
        <th>품목코드</th>
        <th>품목명</th>
        <th colspan="3">판매</th>
        <th colspan="2">원가</th>
        <th colspan="2">이익</th>
        <th>이익률</th>
      </tr>
      <tr>
        <th></th>
        <th></th>
        <th>수량</th>
        <th>단가</th>
        <th>금액</th>
        <th>단가</th>
        <th>금액</th>
        <th>단가</th>
        <th>금액</th>
        <th></th>
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

</body>


<%@ include file="../common/footer.jsp" %>