<!DOCTYPE html>
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
request.setAttribute("pageTitle", "주문관리");
request.setAttribute("active_sales", "active");
request.setAttribute("active_order", "active");
%>
<%@ include file="../common/header.jsp" %>

<link rel="stylesheet" href="<c:url value='/css/stock.css?v=1'/>">
<link rel="stylesheet" href="<c:url value='/css/bom.css?v=1'/>">

<!-- CSRF를 JS에서 쓰기 위해 노출 -->
<meta name="_csrf_header" content="${_csrf.headerName}">
<meta name="_csrf" content="${_csrf.token}">

<body>

  <h2>주문관리</h2>

  <!-- 상단 검색 필터 -->
  <div class="filter-small">
    <div class="field">
      <label for="prodCode">제품코드</label>
      <input type="text" id="prodCode" name="prodCode" placeholder="예: P-1001" value="${param.prodCode}">
    </div>

    <div class="field">
      <label for="prodName">제품명</label>
      <input type="text" id="prodName" name="prodName" placeholder="예: 전동드릴" value="${param.prodName}">
    </div>

    <div class="field">
      <label for="orderDate">주문일자</label>
      <input type="date" id="orderDate" name="orderDate"
        value="<c:choose><c:when test='${not empty param.orderDate}'>${param.orderDate}</c:when><c:otherwise>${firstDayOfMonth}</c:otherwise></c:choose>">
    </div>

    <div class="field">
      <label for="status">주문상태</label>
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
  
  <div style="text-align:right; margin-bottom:10px;">
    <button type="button" class="btn btn-info" id="downloadExcel">엑셀 다운로드</button>
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

  <!-- Modal for search results -->
  <div id="searchModal" class="modal" style="display:none;">
    <div class="modal-content">
      <span class="close" id="closeModal">&times;</span>
      <h3>검색 결과</h3>
      <div id="modalResults">
        <!-- AJAX results will be injected here -->
      </div>
      <div style="text-align:right; margin-top:10px;">
        <button type="button" class="btn btn-info" id="downloadExcelModal">엑셀 다운로드</button>
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

  <!-- 조회 버튼: 모달 AJAX 조회로 변경 -->
  <script>
    document.getElementById('btnSearch')?.addEventListener('click', function (e) {
      e.preventDefault();
      const p = new URLSearchParams({
        prodCode : document.getElementById('prodCode').value || '',
        prodName : document.getElementById('prodName').value || '',
        orderDate: document.getElementById('orderDate').value || '',
        status   : document.getElementById('status').value || ''
      });
      fetch('/sales/orders/search?' + p.toString(), { headers: { 'X-Requested-With': 'XMLHttpRequest' } })
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
    // 첫페이지 엑셀 다운로드
    document.getElementById('downloadExcel').onclick = function() {
      fetch('/sales/orders/excel')
        .then(response => {
          if (!response.ok) throw new Error('엑셀 다운로드 실패');
          return response.blob();
        })
        .then(blob => {
          var url = window.URL.createObjectURL(blob);
          var a = document.createElement('a');
          a.href = url;
          a.download = '주문관리_전체리스트.xlsx';
          document.body.appendChild(a);
          a.click();
          a.remove();
          window.URL.revokeObjectURL(url);
        })
        .catch(() => {
          alert('엑셀 다운로드 중 오류가 발생했습니다.');
        });
    };
    // 모달 엑셀 다운로드
    document.getElementById('downloadExcelModal').onclick = function() {
      var prodCode = document.getElementById('prodCode').value;
      var prodName = document.getElementById('prodName').value;
      var orderDate = document.getElementById('orderDate').value;
      var status = document.getElementById('status').value;
      var csrfHeader = document.querySelector('meta[name="_csrf_header"]')?.content;
      var csrfToken = document.querySelector('meta[name="_csrf"]')?.content;
      var headers = {
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
      };
      if (csrfHeader && csrfToken) headers[csrfHeader] = csrfToken;
      var params = new URLSearchParams();
      if (prodCode) params.append('prodCode', prodCode);
      if (prodName) params.append('prodName', prodName);
      if (orderDate) params.append('orderDate', orderDate);
      if (status) params.append('status', status);
      fetch('/sales/orders/excel-modal', {
        method: 'POST',
        headers: headers,
        body: params.toString()
      })
      .then(response => {
        if (!response.ok) throw new Error('엑셀 다운로드 실패');
        return response.blob();
      })
      .then(blob => {
        var url = window.URL.createObjectURL(blob);
        var a = document.createElement('a');
        a.href = url;
        a.download = '주문관리_검색결과.xlsx';
        document.body.appendChild(a);
        a.click();
        a.remove();
        window.URL.revokeObjectURL(url);
      })
      .catch(() => {
        alert('엑셀 다운로드 중 오류가 발생했습니다.');
      });
    };
  </script>

</body>
</html>
<%@ include file="../common/footer.jsp" %>