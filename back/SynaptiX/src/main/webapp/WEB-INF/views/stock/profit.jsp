	<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
request.setAttribute("pageTitle", "이익 관리");
request.setAttribute("active_stock", "active");
request.setAttribute("active_profit", "active");
%>
<%@ include file="../common/header.jsp" %>
<link rel="stylesheet" href="<c:url value='/css/stock.css?v=1'/>">
<link rel="stylesheet" href="<c:url value='/css/bom.css?v=1'/>">

<body>

  <h2>이익관리</h2>

  <!-- 검색 폼 -->
  <form method="get" action="/profit">
    <div class="filter-smallq">
      <div class="field">
        <label for="code">품목코드</label>
        <input type="text" id="code" name="code" placeholder="예: A-1001">
      </div>
      <div class="field">
        <label for="name">품목명</label>
        <input type="text" id="name" name="name" placeholder="예: 모터">
      </div>
      <div class="field">
        <label for="category">카테고리</label>
		<div class="select-wrap">
        <select id="category" name="category">
          <option value="">전체</option>
          <option value="제품">제품</option>
          <option value="원자재">원자재</option>
        </select>
      </div>
	  </div>
      <div class="btn-group">
        <button type="submit" class="btn btn-primary">조회</button>
		<div >
		  <button type="button" class="btn btn-success" onclick="downloadProfitExcel()">엑셀 다운로드</button>
		</div>
      </div>
    </div>
  </form>

  <!-- 이익현황 엑셀 다운로드 버튼 -->


  <!-- 이익현황 -->
  <h2>품목별 이익현황</h2>
  <table class="profit-table">
    <thead>
      <tr>
        <th rowspan="2">품목코드</th>
        <th rowspan="2">품목명</th>
        <th colspan="3">판매</th>
        <th colspan="2">원가</th>
        <th colspan="2">이익</th>
        <th rowspan="2">이익률</th>
      </tr>
      <tr>
        <th>수량</th>
        <th>단가</th>
        <th>금액</th>
        <th>단가</th>
        <th>금액</th>
        <th>단가</th>
        <th>금액</th>
      </tr>
    </thead>

    <tbody>
      <c:forEach var="item" items="${profitList}">
        <tr>
          <td>${item.code}</td>
          <td>${item.name}</td>
          <td><fmt:formatNumber value="${item.salesQty}" /></td>
          <td><fmt:formatNumber value="${item.salesPrice}" /></td>
          <td><fmt:formatNumber value="${item.salesAmount}" /></td>
          <td><fmt:formatNumber value="${item.costPrice}" /></td>
          <td><fmt:formatNumber value="${item.costAmount}" /></td>
          <td><fmt:formatNumber value="${item.profitUnit}" /></td>
          <td><fmt:formatNumber value="${item.profitAmount}" /></td>
          <td><fmt:formatNumber value="${item.profitRate}" />%</td>
        </tr>
      </c:forEach>
      <c:if test="${empty profitList}">
        <tr>
          <td colspan="10">데이터가 없습니다.</td>
        </tr>
      </c:if>
    </tbody>
  </table>

  <!-- 검색 결과 모달 -->
  <div id="resultModal" class="modal" role="dialog" aria-modal="true" aria-labelledby="modalTitle" style="display:none;">
    <div class="modal-content">
      <span class="close" onclick="closeModal()" aria-label="닫기">&times;</span>
      <h3 id="modalTitle">검색 결과</h3>
	  <div style="text-align:right; margin-top:10px;">
        <button type="button" class="btn btn-success" style="float:right; margin-bottom:10px;" onclick="downloadExcelFromModal()">엑셀 다운로드</button>
      </div>
	  <div id="modalResultBody"><!-- Ajax 결과 테이블이 여기에 표시 --></div>
    </div>
  </div>

  <!-- CSRF를 JS에서 쓰기 위해 노출 -->
  <meta name="_csrf_header" content="${_csrf.headerName}">
  <meta name="_csrf"        content="${_csrf.token}">

  <script>
    function downloadProfitExcel() {
      const item_code = document.getElementById('code').value;
      const item_name = document.getElementById('name').value;
      const category = document.getElementById('category').value;
      const CSRF_HEADER = document.querySelector('meta[name="_csrf_header"]').content;
      const CSRF_TOKEN  = document.querySelector('meta[name="_csrf"]').content;
      const params = new URLSearchParams();
      if (item_code) params.append('item_code', item_code);
      if (item_name) params.append('item_name', item_name);
      if (category) params.append('category', category);
      fetch('/profit/excel', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
          [CSRF_HEADER]: CSRF_TOKEN
        },
        body: params.toString()
      })
      .then(response => {
        if (!response.ok) throw new Error('엑셀 다운로드 실패');
        return response.blob();
      })
      .then(blob => {
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = '이익관리.xlsx';
        document.body.appendChild(a);
        a.click();
        a.remove();
        window.URL.revokeObjectURL(url);
      })
      .catch(() => {
        alert('엑셀 다운로드 중 오류가 발생했습니다.');
      });
    }
    function searchProfit() {
      const item_code = document.getElementById('code').value;
      const item_name = document.getElementById('name').value;
      const category = document.getElementById('category').value;
      const CSRF_HEADER = document.querySelector('meta[name="_csrf_header"]').content;
      const CSRF_TOKEN  = document.querySelector('meta[name="_csrf"]').content;
      const params = new URLSearchParams();
      if (item_code) params.append('item_code', item_code);
      if (item_name) params.append('item_name', item_name);
      if (category) params.append('category', category);
      fetch('/profit/search', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
          [CSRF_HEADER]: CSRF_TOKEN
        },
        body: params.toString()
      })
      .then(res => res.text())
      .then(html => {
        document.getElementById('modalResultBody').innerHTML = html;
        document.getElementById('resultModal').style.display = 'block';
      })
      .catch(() => {
        alert('검색 중 오류가 발생했습니다.');
      });
    }
    function closeModal() {
      document.getElementById('resultModal').style.display = 'none';
    }
    function downloadExcelFromModal() {
      const item_code = document.getElementById('code').value;
      const item_name = document.getElementById('name').value;
      const category = document.getElementById('category').value;
      const CSRF_HEADER = document.querySelector('meta[name="_csrf_header"]').content;
      const CSRF_TOKEN  = document.querySelector('meta[name="_csrf"]').content;
      const params = new URLSearchParams();
      if (item_code) params.append('item_code', item_code);
      if (item_name) params.append('item_name', item_name);
      if (category) params.append('category', category);
      fetch('/profit/excel-modal', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
          [CSRF_HEADER]: CSRF_TOKEN
        },
        body: params.toString()
      })
      .then(response => {
        if (!response.ok) throw new Error('엑셀 다운로드 실패');
        return response.blob();
      })
      .then(blob => {
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = '이익관리.xlsx';
        document.body.appendChild(a);
        a.click();
        a.remove();
        window.URL.revokeObjectURL(url);
      })
      .catch(() => {
        alert('엑셀 다운로드 중 오류가 발생했습니다.');
      });
    }
    document.addEventListener('DOMContentLoaded', function() {
      document.querySelector('.btn-group .btn-primary').addEventListener('click', function(e) {
        e.preventDefault();
        searchProfit();
      });
    });
  </script>
  <style>
    #resultModal .modal-content {
      max-width: 800px;
      max-height: 80vh;
      display: flex;
      flex-direction: column;
    }
    #modalResultBody {
      max-height: 400px;
      overflow-y: auto;
      margin-bottom: 10px;
    }
  </style>

</body>


<%@ include file="../common/footer.jsp" %>