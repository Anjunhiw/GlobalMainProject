<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    java.util.Calendar cal = java.util.Calendar.getInstance();
    cal.set(java.util.Calendar.DAY_OF_MONTH, 1);
    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
    String firstDayOfMonth = sdf.format(cal.getTime());
    request.setAttribute("firstDayOfMonth", firstDayOfMonth);
%>
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
      <label>거래일자</label>
      <input type="date" id="date" name="date" placeholder="예: 2025-09-26" value="<c:choose><c:when test='${not empty param.date}'>${param.date}</c:when><c:otherwise>${firstDayOfMonth}</c:otherwise></c:choose>">
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
    <tbody id="transactionTableBody">
      <c:forEach var="row" items="${transactionList}">
        <tr>
          <td><fmt:formatDate value="${row.date}" pattern="yyyyMM"/>-${row.pk}</td>
          <td><fmt:formatDate value="${row.date}" pattern="yyyy-MM-dd"/></td>
          <td>prod2025<c:choose><c:when test="${row.productId lt 10}">0${row.productId}</c:when><c:otherwise>${row.productId}</c:otherwise></c:choose></td>
          <td>${row.prodName}</td>
          <td class="text-right">
            <fmt:formatNumber value="${row.sales}" type="number" maxFractionDigits="0" groupingUsed="true"/>
          </td>
          <td class="text-right">
            <fmt:formatNumber value="${row.unitPrice}" type="number" groupingUsed="true"/>
          </td>
          <td class="text-right">
            <fmt:formatNumber value="${row.amount}" type="number" groupingUsed="true"/>
          </td>
          <td class="text-right">
            <fmt:formatNumber value="${row.earning}" type="number" groupingUsed="true"/>
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

  <!-- 검색 결과 모달 (Sales.jsp와 동일한 구조) -->
  <div id="searchModal" class="modal" style="display:none;">
    <div class="modal-content">
      <span class="close" id="closeModal">&times;</span>
      <h3>검색 결과</h3>
      <div id="modalResults">
        <!-- AJAX results will be injected here -->
      </div>
    </div>
  </div>

  <style>
  .modal {
    position: fixed;
    z-index: 9999;
    left: 0; top: 0; width: 100vw; height: 100vh;
    background: rgba(0,0,0,0.4);
    display: flex; align-items: center; justify-content: center;
  }
  .modal-content {
    background: #fff; padding: 20px; border-radius: 8px; min-width: 400px; max-width: 90vw;
    max-height: 80vh; overflow-y: auto; position: relative;
  }
  .close {
    position: absolute; right: 16px; top: 10px; font-size: 24px; cursor: pointer;
  }
  </style>

  <script>
    // 조회 버튼 Ajax 검색
    document.getElementById('btnSearch')?.addEventListener('click', function (e) {
      e.preventDefault();
      const p = new URLSearchParams({
        prodCode: document.getElementById('prodCode').value || '',
        prodName: document.getElementById('prodName').value || '',
        date:     document.getElementById('date').value || '',
        stmtNo:   document.getElementById('stmtNo').value || ''
      });
      fetch('/transaction/search?' + p.toString(), { headers: { 'X-Requested-With': 'XMLHttpRequest' } })
        .then(res => res.text())
        .then(html => {
          document.getElementById('modalResults').innerHTML = html;
          document.getElementById('searchModal').style.display = 'flex';
        })
        .catch(() => {
          document.getElementById('modalResults').innerHTML = '<p style="color:red;">검색 결과를 불러오지 못했습니다.</p>';
          document.getElementById('searchModal').style.display = 'flex';
        });
    });
    document.getElementById('closeModal')?.addEventListener('click', function () {
      document.getElementById('searchModal').style.display = 'none';
    });
    window.addEventListener('click', function(e) {
      if (e.target === document.getElementById('searchModal')) {
        document.getElementById('searchModal').style.display = 'none';
      }
    });
  </script>

</body>
</html>
<%@ include file="../common/footer.jsp" %>