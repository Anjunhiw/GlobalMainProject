<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
request.setAttribute("pageTitle", "자금계획");
request.setAttribute("active_asset", "active");
request.setAttribute("active_asp", "active");
%>
<%@ include file="../common/header.jsp" %>
<link rel="stylesheet" href="<c:url value='/css/stock.css?v=1'/>">
<link rel="stylesheet" href="<c:url value='/css/bom.css?v=1'/>">

<body>
  <h2>자금계획</h2>

  <!-- 검색 영역 -->
  <div class="filter-smallq">
    <div class="field">
      <label>예상기간</label>
      <input type="date" id="planDate" name="planDate" value="${param.planDate}">
    </div>
    <div class="field">
      <label>제품명</label>
      <input type="text" id="productName" name="productName" value="${param.productName}">
    </div>
    <div class="field">
      <label>판매량</label>
      <input type="number" id="salesQty" name="salesQty" value="${param.salesQty}">
    </div>
    <div class="btn-group">
      <button type="button" id="btnSearch" class="btn btn-primary">조회</button>
    </div>
  </div>

  <!-- 자금계획 내역 -->
  <h3>자금계획내역</h3>
  <table class="table">
    <thead>
      <tr>
        <th>예정일</th>
        <th>제품명</th>
        <th>단가</th>
        <th>예상판매량</th>
        <th>예상수익</th>
      </tr>
    </thead>
    <tbody>
      <c:forEach var="plan" items="${planList}">
        <tr>
          <td>${plan.planDate}</td>
          <td>${plan.productName}</td>
          <td class="text-right"><fmt:formatNumber value="${plan.unitPrice}" type="number"/></td>
          <td class="text-right"><fmt:formatNumber value="${plan.salesQty}" type="number"/></td>
          <td class="text-right"><fmt:formatNumber value="${plan.expectedProfit}" type="number"/></td>
        </tr>
      </c:forEach>
      <c:if test="${empty assetPlans}">
        <tr><td colspan="5" style="text-align:center;">자금계획 데이터가 없습니다.</td></tr>
      </c:if>
    </tbody>
  </table>

  <script>
    document.getElementById('btnSearch')?.addEventListener('click', () => {
      const params = new URLSearchParams({
        planDate: document.getElementById('planDate').value || '',
        productName: document.getElementById('productName').value || '',
        salesQty: document.getElementById('salesQty').value || ''
      });
      location.href = '/fund/plan?' + params.toString(); // 컨트롤러 매핑에 맞게 수정
    });
  </script>
</body>
</html>
<%@ include file="../common/footer.jsp" %>