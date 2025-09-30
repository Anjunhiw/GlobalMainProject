<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    java.util.Calendar cal = java.util.Calendar.getInstance();
    cal.set(java.util.Calendar.DAY_OF_MONTH, 1);
    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
    String firstDayOfMonth = sdf.format(cal.getTime());
    request.setAttribute("firstDayOfMonth", firstDayOfMonth);
%>
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
      <input type="date" id="planDate" name="planDate" value="<c:choose><c:when test='${not empty param.planDate}'>${param.planDate}</c:when><c:otherwise>${firstDayOfMonth}</c:otherwise></c:choose>">
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
      <button type="button" id="btnExcel" class="btn btn-success">엑셀 다운로드</button>
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
      <c:forEach var="plan" items="${assetPlans}">
        <tr>
          <td><fmt:formatDate value="${plan.date}" pattern="yyyy-MM-dd"/></td>
          <td>${plan.productName}</td>
          <td class="text-right"><fmt:formatNumber value="${plan.price}" type="number"/></td>
          <td class="text-right"><fmt:formatNumber value="${plan.amount}" type="number"/></td>
          <td class="text-right"><fmt:formatNumber value="1" type="number"/></td>
        </tr>
      </c:forEach>
      <c:if test="${empty assetPlans}">
        <tr><td colspan="5" style="text-align:center;">자금계획 데이터가 없습니다.</td></tr>
      </c:if>
    </tbody>
  </table>

  <!-- 모달 구조 추가 -->
  <div id="searchModal" class="modal" style="display:none;">
    <div class="modal-content">
      <span class="close" id="closeModal">&times;</span>
      <h3>검색 결과</h3>
      <div id="modalResults">
        <!-- AJAX results will be injected here -->
      </div>
      <div style="text-align:right; margin-top:10px;">
        <button type="button" id="btnModalExcel" class="btn btn-info">엑셀 다운로드</button>
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
    document.getElementById('btnSearch')?.addEventListener('click', function (e) {
      e.preventDefault();
      const p = new URLSearchParams({
        planDate: document.getElementById('planDate').value || '',
        productName: document.getElementById('productName').value || '',
        salesQty: document.getElementById('salesQty').value || ''
      });
      fetch('/fund/plan/search?' + p.toString(), { headers: { 'X-Requested-With': 'XMLHttpRequest' } })
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

    // 엑셀 다운로드 (첫 화면)
    document.getElementById('btnExcel')?.addEventListener('click', function () {
      const planDate = document.getElementById('planDate').value || '';
      const productName = document.getElementById('productName').value || '';
      const salesQty = document.getElementById('salesQty').value || '';
      const params = new URLSearchParams({ planDate, productName, salesQty });
      fetch('/fund/plan/excel?' + params.toString(), {
        method: 'GET',
        headers: { 'X-Requested-With': 'XMLHttpRequest' }
      })
      .then(response => {
        if (!response.ok) throw new Error('엑셀 다운로드 실패');
        return response.blob();
      })
      .then(blob => {
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = '자금계획내역.xlsx';
        document.body.appendChild(a);
        a.click();
        a.remove();
        window.URL.revokeObjectURL(url);
      })
      .catch(() => {
        alert('엑셀 다운로드 중 오류가 발생했습니다.');
      });
    });

    // 모달 내 엑셀 다운로드
    document.getElementById('btnModalExcel')?.addEventListener('click', function () {
      const planDate = document.getElementById('planDate').value || '';
      const productName = document.getElementById('productName').value || '';
      const salesQty = document.getElementById('salesQty').value || '';
      const params = new URLSearchParams({ planDate, productName, salesQty });
      fetch('/fund/plan/excel-modal?' + params.toString(), {
        method: 'GET',
        headers: { 'X-Requested-With': 'XMLHttpRequest' }
      })
      .then(response => {
        if (!response.ok) throw new Error('엑셀 다운로드 실패');
        return response.blob();
      })
      .then(blob => {
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = '검색결과_자금계획내역.xlsx';
        document.body.appendChild(a);
        a.click();
        a.remove();
        window.URL.revokeObjectURL(url);
      })
      .catch(() => {
        alert('엑셀 다운로드 중 오류가 발생했습니다.');
      });
    });
  </script>
</body>
</html>
<%@ include file="../common/footer.jsp" %>