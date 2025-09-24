<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
request.setAttribute("pageTitle", "거래명세서");
request.setAttribute("active_sales", "active");
request.setAttribute("active_transaction", "active");
%>
<%@ include file="../common/header.jsp" %>
<link rel="stylesheet" href="<c:url value='/css/stock.css?v=1'/>">
<link rel="stylesheet" href="<c:url value='/css/bom.css?v=1'/>">
<body>

  <h2>거래명세서</h2>

  <!-- 상단 검색 필터 -->
  <div class="filter-smalli">
    <div class="field">
      <label>제품코드</label>
      <input type="text" id="prodCode" name="prodCode" placeholder="예: P-1001">
    </div>

    <div class="field">
      <label>제품명</label>
      <input type="text" id="prodName" name="prodName" placeholder="예: 전동드릴">
    </div>

    <div class="field">
      <label>거래업자</label>
      <input type="text" id="partner" name="partner" placeholder="예: ABC상사">
    </div>

    <div class="field">
      <label>거래명세서번호</label>
      <input type="text" id="stmtNo" name="stmtNo" placeholder="예: IV-2025-0001">
    </div>

    <div class="btn-group">
      <button type="button" class="btn btn-primary" id="btnSearch">조회</button>
    </div>
  </div>

  <h2>거래명세서 현황</h2>

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
      <!-- 컨트롤러에서 statements 리스트를 내려주세요 -->
      <c:forEach var="row" items="${transactionList}">
        <tr>
          <td><fmt:formatDate value="${row.Date}" pattern="yyyyMM"/>-${row.pk}</td>
          <td><fmt:formatDate value="${row.Date}" pattern="yyyy-MM-dd"/></td>
          <td>${row.productId}</td>
          <td>${row.prodName}</td>
          <td class="text-right">
            <fmt:formatNumber value="${row.qty}" type="number" maxFractionDigits="0" groupingUsed="true"/>
          </td>
          <td class="text-right">
            <fmt:formatNumber value="${row.unitPrice}" type="number" groupingUsed="true"/>
          </td>
          <td class="text-right">
            <fmt:formatNumber value="${row.amount}" type="number" groupingUsed="true"/>
          </td>
          <td class="text-right">
            <fmt:formatNumber value="${row.profit}" type="number" groupingUsed="true"/>
          </td>
        </tr>
      </c:forEach>

      <c:if test="${empty transactionList}">
        <tr>
          <td colspan="8" style="text-align:center;">거래명세서 데이터가 없습니다.</td>
        </tr>
      </c:if>
    </tbody>
  </table>

  <!-- 조회 버튼 동작 (GET 파라미터로 재조회) -->
  <script>
    document.getElementById('btnSearch')?.addEventListener('click', function () {
      const p = new URLSearchParams({
        prodCode: document.getElementById('prodCode').value || '',
        prodName: document.getElementById('prodName').value || '',
        partner : document.getElementById('partner').value  || '',
        stmtNo  : document.getElementById('stmtNo').value   || ''
      });
      // 컨트롤러 매핑에 맞게 수정 (예: GET /sales/statements)
      location.href = '/sales/statements?' + p.toString();
    });
  </script>

</body>
</html>
<%@ include file="../common/footer.jsp" %>