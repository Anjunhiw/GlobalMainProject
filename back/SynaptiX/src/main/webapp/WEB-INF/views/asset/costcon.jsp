<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    java.util.Calendar cal = java.util.Calendar.getInstance();
    cal.set(java.util.Calendar.DAY_OF_MONTH, 1);
    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
    String firstDayOfMonth = sdf.format(cal.getTime());
    cal.set(java.util.Calendar.DAY_OF_MONTH, cal.getActualMaximum(java.util.Calendar.DAY_OF_MONTH));
    String lastDayOfMonth = sdf.format(cal.getTime());
    request.setAttribute("firstDayOfMonth", firstDayOfMonth);
    request.setAttribute("lastDayOfMonth", lastDayOfMonth);
%>
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
      <input type="date" id="startDate" name="startDate" value="<c:choose><c:when test='${not empty param.startDate}'>${param.startDate}</c:when><c:otherwise>${firstDayOfMonth}</c:otherwise></c:choose>">
    </div>
    <div class="field">
      <label>종료일자</label>
      <input type="date" id="endDate" name="endDate" value="<c:choose><c:when test='${not empty param.endDate}'>${param.endDate}</c:when><c:otherwise>${lastDayOfMonth}</c:otherwise></c:choose>">
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
          <td><fmt:formatDate value="${cost.date}" pattern="yyyy-MM-dd"/></td>
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

  <!-- 모달 구조 추가 -->
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
    document.getElementById('btnSearch')?.addEventListener('click', function (e) {
      e.preventDefault();
      const p = new URLSearchParams({
        startDate: document.getElementById('startDate').value || '',
        endDate: document.getElementById('endDate').value || '',
        mtrName: document.getElementById('mtrName').value || ''
      });
      fetch('/fund/cost/search?' + p.toString(), { headers: { 'X-Requested-With': 'XMLHttpRequest' } })
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
<%@ include file="../common/footer.jsp" %>