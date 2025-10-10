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
request.setAttribute("pageTitle", "MRP");
request.setAttribute("active_purchase", "active");
request.setAttribute("active_mrp", "active");
%>
<%@ include file="../common/header.jsp" %>
<link rel="stylesheet" href="<c:url value='/css/stock.css?v=1'/>">
<link rel="stylesheet" href="<c:url value='/css/bom.css?v=1'/>">
  <main class="container">
  <h2>MRP</h2>

  <!-- 검색 영역 -->
  <div class="filter-small">
    <div class="field">
      <label>제품코드</label>
      <input type="text" id="prodCode" name="prodCode"
             placeholder="예: P-1001" value="${param.prodCode}">
    </div>

    <div class="field">
      <label>제품명</label>
      <input type="text" id="prodName" name="prodName"
             placeholder="예: 완제품A" value="${param.prodName}">
    </div>

    <div class="field">
      <label>입고일자</label>
      <input type="date" id="inDate" name="inDate" value="<c:choose><c:when test='${not empty param.inDate}'>${param.inDate}</c:when><c:otherwise>${firstDayOfMonth}</c:otherwise></c:choose>">
    </div>

    <div class="field">
      <label>MRP상태</label>
      <div class="select-wrap">
        <select id="mrpStatus" name="mrpStatus">
          <option value=""      ${empty param.mrpStatus ? 'selected' : ''}>전체</option>
          <option value="PLAN"  ${param.mrpStatus == 'PLAN'  ? 'selected' : ''}>계획</option>
          <option value="NEED"  ${param.mrpStatus == 'NEED'  ? 'selected' : ''}>부족</option>
          <option value="OK"    ${param.mrpStatus == 'OK'    ? 'selected' : ''}>충분</option>
        </select>
      </div>
    </div>

    <div class="btn-group">
      <button type="button" id="btnSearch" class="btn btn-primary">조회</button>
      <button type="button" id="btnExcel" class="btn btn-success" >엑셀 다운로드</button>
    </div>
  </div>

  <!-- 결과 테이블 -->
  <h2>재고 계획 현황</h2>
  <table class="table">
    <thead>
      <tr>
        <th>제품명</th>
        <th>필요 원자재</th>
        <th>필요량</th>
        <th>현재재고</th>
        <th>추가재고필요량</th>
        <th>계획일자</th>
      </tr>
    </thead>
    <tbody>
      <!-- mrps: 서버에서 내려주는 리스트 -->
      <!-- 예시 DTO 필드: productName, materialName, requiredQty, currentStock, shortageQty, planDate -->
      <c:forEach var="m" items="${mrpList}">
        <tr>
          <td>${m.ProductName}</td>
          <td>${m.MaterialName}</td>
          <td class="text-right"><fmt:formatNumber value="${m.RequiredQuantity}" type="number" maxFractionDigits="0"/></td>
          <td class="text-right"><fmt:formatNumber value="${m.StockQuantity}" type="number" maxFractionDigits="0"/></td>
          <td class="text-right">
            <fmt:formatNumber value="${m.Shortage}" type="number" maxFractionDigits="0"/>
          </td>
          <td><fmt:formatDate value="${m.ProductionPlan}" pattern="yyyy-MM-dd"/></td>
        </tr>
      </c:forEach>

      <c:if test="${empty mrpList}">
        <tr><td colspan="6" style="text-align:center;">표시할 MRP 데이터가 없습니다.</td></tr>
      </c:if>
    </tbody>
  </table>

  <!-- 모달 구조 추가 -->
  <div id="searchModal" class="modal" style="display:none;">
    <div class="modal-content">
      <span class="close" id="closeModal">&times;</span>
      <h3>검색 결과</h3>
	  <div class="btn-group" style="float:right; margin-bottom:10px;">
        <button type="button" class="btn btn-success" id="btnModalExcel">엑셀 다운로드</button>
      </div>
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
    document.getElementById('btnSearch')?.addEventListener('click', function (e) {
      e.preventDefault();
      const p = new URLSearchParams({
        prodCode  : document.getElementById('prodCode').value || '',
        prodName  : document.getElementById('prodName').value || '',
        inDate    : document.getElementById('inDate').value   || '',
        mrpStatus : document.getElementById('mrpStatus').value || ''
      });
      fetch('/mrp/search?' + p.toString(), { headers: { 'X-Requested-With': 'XMLHttpRequest' } })
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
    // 엑셀 다운로드 (첫페이지)
    document.getElementById('btnExcel')?.addEventListener('click', function () {
      window.location.href = '/mrp/excel';
    });
    // 모달 엑셀 다운로드
    document.getElementById('btnModalExcel')?.addEventListener('click', function () {
      const prodCode = document.getElementById('prodCode')?.value || '';
      const prodName = document.getElementById('prodName')?.value || '';
      const inDate = document.getElementById('inDate')?.value || '';
      const mrpStatus = document.getElementById('mrpStatus')?.value || '';
      const params = new URLSearchParams({ prodCode, prodName, inDate, mrpStatus });
      fetch('/mrp/excel-modal?' + params.toString(), {
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
        a.download = '검색결과_MRP.xlsx';
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
</main>
<%@ include file="../common/footer.jsp" %>