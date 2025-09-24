<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
request.setAttribute("pageTitle", "주문관리");
request.setAttribute("active_sales", "active");
request.setAttribute("active_order", "active");
%>
<%@ include file="../common/header.jsp" %>

<link rel="stylesheet" href="<c:url value='/css/stock.css?v=1'/>">
<link rel="stylesheet" href="<c:url value='/css/bom.css?v=1'/>">

<body>

  <h2>주문관리</h2>

  <!-- 상단 검색 필터 -->
  <div class="filter-small">
    <div class="field">
      <label>제품코드</label>
      <input type="text" id="prodCode" name="prodCode" placeholder="예: P-1001" value="${param.prodCode}">
    </div>

    <div class="field">
      <label>제품명</label>
      <input type="text" id="prodName" name="prodName" placeholder="예: 전동드릴" value="${param.prodName}">
    </div>

    <div class="field">
      <label>주문일자</label>
      <input type="date" id="orderDate" name="orderDate" value="${param.orderDate}">
    </div>

    <div class="field">
      <label>주문상태</label>
      <div class="select-wrap">
        <select id="status" name="status">
          <option value=""  ${empty param.status ? 'selected' : ''}>전체</option>
          <option value="REQUESTED" ${param.status == 'REQUESTED' ? 'selected' : ''}>접수</option>
          <option value="CONFIRMED" ${param.status == 'CONFIRMED' ? 'selected' : ''}>확정</option>
          <option value="SHIPPED"   ${param.status == 'SHIPPED'   ? 'selected' : ''}>출고</option>
          <option value="CANCELLED" ${param.status == 'CANCELLED' ? 'selected' : ''}>취소</option>
        </select>
      </div>
    </div>

    <div class="btn-group">
      <button type="button" class="btn btn-primary" id="btnSearch">조회</button>
    </div>
  </div>

  <h2>주문현황</h2>

  <table class="table">
    <thead>
      <tr>
        <th>주문번호</th>
        <th>주문일자</th>
        <th>제품코드</th>
        <th>제품명</th>
        <th>수량</th>
        <th>단가</th>
        <th>금액</th>
        <th>주문상태</th>
      </tr>
    </thead>
    <tbody>
      <!-- 컨트롤러: model.addAttribute("orders", list); -->
      <c:forEach var="o" items="${orderList}">
        <tr>
          <td>${o.orderNo}</td>
          <td><fmt:formatDate value="${o.orderDate}" pattern="yyyy-MM-dd"/></td>
          <td>prod2025<c:choose><c:when test="${o.prodCode lt 10}">0${o.prodCode}</c:when><c:otherwise>${o.prodCode}</c:otherwise></c:choose></td>
          <td>${o.prodName}</td>
          <td class="text-right"><fmt:formatNumber value="${o.qty}" type="number" maxFractionDigits="0" groupingUsed="true"/></td>
          <td class="text-right"><fmt:formatNumber value="${o.unitPrice}" type="number" groupingUsed="true"/></td>
          <td class="text-right"><fmt:formatNumber value="${o.amount}" type="number" groupingUsed="true"/></td>
          <td>${o.status}</td>
        </tr>
      </c:forEach>

      <c:if test="${empty orderList}">
        <tr><td colspan="8" style="text-align:center;">주문 데이터가 없습니다.</td></tr>
      </c:if>
    </tbody>
  </table>

  <!-- 조회 버튼: GET 파라미터로 재조회 -->
  <script>
    document.getElementById('btnSearch')?.addEventListener('click', function () {
      const p = new URLSearchParams({
        prodCode : document.getElementById('prodCode').value || '',
        prodName : document.getElementById('prodName').value || '',
        orderDate: document.getElementById('orderDate').value || '',
        status   : document.getElementById('status').value || ''
      });
      // 컨트롤러 매핑에 맞게 수정하세요 (예: GET /sales/orders)
      location.href = '/sales/orders?' + p.toString();
    });
  </script>

</body>
</html>
<%@ include file="../common/footer.jsp" %>