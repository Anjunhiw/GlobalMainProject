<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
request.setAttribute("pageTitle", "구매입고");
request.setAttribute("active_purchase", "active");
request.setAttribute("active_pch", "active");
%>
<%@ include file="../common/header.jsp" %>
<link rel="stylesheet" href="<c:url value='/css/stock.css?v=1'/>">
<link rel="stylesheet" href="<c:url value='/css/bom.css?v=1'/>">
<body>
  <h2>구매/입고</h2>

  <!-- 검색 영역 -->
  <div class="filter-small">
    <div class="field">
      <label>제품코드</label>
      <input type="text" id="prodCode" name="prodCode" placeholder="예: M-1001" value="${param.prodCode}">
    </div>

    <div class="field">
      <label>제품명</label>
      <input type="text" id="prodName" name="prodName" placeholder="예: 원자재A" value="${param.prodName}">
    </div>

    <div class="field">
      <label>입고일자</label>
      <input type="date" id="inDate" name="inDate" value="${param.inDate}">
    </div>

    <div class="field">
      <label>MRP상태</label>
      <div class="select-wrap">
        <select id="mrpStatus" name="mrpStatus">
          <option value="" ${empty param.mrpStatus ? 'selected' : ''}>전체</option>
          <option value="WAIT" ${param.mrpStatus == 'WAIT' ? 'selected' : ''}>계획</option>
          <option value="DONE" ${param.mrpStatus == 'DONE' ? 'selected' : ''}>미계획</option>
        </select>
      </div>
    </div>

    <div class="btn-group">
      <button type="button" id="btnSearch" class="btn btn-primary">조회</button>
    </div>
  </div>

  <!-- 테이블 -->
  <h2>입고현황</h2>
  <table class="table">
    <thead>
      <tr>
        <th>구매번호</th>
        <th>원자재명</th>
        <th>단가</th>
        <th>구매량</th>
        <th>구매금액</th>
        <th>입고일</th>
        <th>재고량</th>
		<th>재고금액</th>
      </tr>
    </thead>
    <tbody>
      <c:forEach var="p" items="${purchaseList}">
        <tr>
          <td>${p.pk}</td>
          <td>${p.materialName}</td>
          <td><fmt:formatNumber value="${p.price}"/></td>
          <td class="text-right"><fmt:formatNumber value="${p.purchase}" type="number" groupingUsed="true"/></td>
          <td class="text-right"><fmt:formatNumber value="${p.cost}" type="number" groupingUsed="true"/></td>
		  <td><fmt:formatDate value="${p.date}" pattern="yyyy-MM-dd"/></td>
		  <td><fmt:formatNumber value="${p.stock}" type="number" groupingUsed="true"/></td>
		  <td><fmt:formatNumber value="${p.amount}" type="number" groupingUsed="true"/></td>
        </tr>
      </c:forEach>

      <c:if test="${empty purchaseList}">
        <tr><td colspan="7" style="text-align:center;">입고 데이터가 없습니다.</td></tr>
      </c:if>
    </tbody>
  </table>

  <script>
    // 조회 버튼 클릭 시 GET 파라미터 전달
    document.getElementById('btnSearch')?.addEventListener('click', function () {
      const p = new URLSearchParams({
        prodCode  : document.getElementById('prodCode').value || '',
        prodName  : document.getElementById('prodName').value || '',
        inDate    : document.getElementById('inDate').value || '',
        mrpStatus : document.getElementById('mrpStatus').value || ''
      });
      location.href = '/purchase/in?' + p.toString();
    });
  </script>
</body>
</html>

<%@ include file="../common/footer.jsp" %>