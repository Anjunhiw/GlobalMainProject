<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
request.setAttribute("pageTitle", "경영보고서");
request.setAttribute("active_asset", "active");
request.setAttribute("active_control", "active");
%>
<%@ include file="../common/header.jsp" %>
<link rel="stylesheet" href="<c:url value='/css/stock.css?v=1'/>">
<link rel="stylesheet" href="<c:url value='/css/bom.css?v=1'/>">

<body>
  <h2>비용/지출통제</h2>

  <!-- 검색 영역 -->
  <div class="filter-smally">
    <div class="field">
      <label>시작일자</label>
      <input type="date" id="startDate" name="startDate" value="${param.startDate}">
    </div>
    <div class="field">
      <label>종료일자</label>
      <input type="date" id="endDate" name="endDate" value="${param.endDate}">
    </div>
	<div class="field">
      <label>원자재명</label>
      <input type="text" id="mtrName" name="mtrName" value="${param.mtrName}">
	</div>
    <div class="btn-group">
      <button type="button" id="btnSearch" class="btn btn-primary">조회</button>
    </div>
  </div>

  <!-- 비용 통제 내역 -->
  <h3>지출내역</h3>
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
          <td><fmt:formatDate value="${cost.date}"/></td>
          <td>${cost.materialName}</td>
          <td><fmt:formatNumber value="${cost.purchase}"/></td>
          <td><fmt:formatNumber value="${cost.price}"/></td>
          <td><fmt:formatNumber value="${cost.cost}"/></td>
        </tr>
      </c:forEach>
      <c:if test="${empty costList}">
        <tr><td colspan="5" style="text-align:center;">비용 데이터가 없습니다.</td></tr>
      </c:if>
    </tbody>
  </table>
<%@ include file="../common/footer.jsp" %>