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


<main class ="container">
  <h2>이익관리</h2>

  <!-- 검색 폼 -->
  <form method="get" action="/profit">
    <input type="hidden" name="page" value="${page}" />
    <input type="hidden" name="size" value="${size}" />
    <div class="filter-smallq">
      <div class="field">
        <label for="code">품목코드</label>
        <input type="text" id="code" name="item_code" placeholder="예: A-1001" value="${param.item_code}" />
      </div>
      <div class="field">
        <label for="name">품목명</label>
        <input type="text" id="name" name="item_name" placeholder="예: 모터" value="${param.item_name}" />
      </div>
      <div class="field">
        <label for="category">카테고리</label>
        <div class="select-wrap">
          <select id="category" name="category">
            <option value="" ${empty param.category ? 'selected' : ''}>전체</option>
            <option value="제품" ${param.category == '제품' ? 'selected' : ''}>제품</option>
            <option value="원자재" ${param.category == '원자재' ? 'selected' : ''}>원자재</option>
          </select>
        </div>
      </div>
      <div class="btn-group">
        <button type="submit" class="btn btn-primary">조회</button>
        <div>
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
  <!-- 페이징 UI -->
  <div class="pagination">
    <c:set var="totalPages" value="${(totalCount / size) + (totalCount % size > 0 ? 1 : 0)}" />
    <c:if test="${totalPages > 1}">
      <ul class="paging-list">
        <c:if test="${page > 0}">
          <li><a href="?page=${page - 1}&size=${size}&item_code=${param.item_code}&item_name=${param.item_name}&category=${param.category}">이전</a></li>
        </c:if>
        <c:forEach var="i" begin="0" end="${totalPages - 1}">
          <li>
            <a href="?page=${i}&size=${size}&item_code=${param.item_code}&item_name=${param.item_name}&category=${param.category}" class="${i == page ? 'active' : ''}">${i + 1}</a>
          </li>
        </c:forEach>
        <c:if test="${page < totalPages - 1}">
          <li><a href="?page=${page + 1}&size=${size}&item_code=${param.item_code}&item_name=${param.item_name}&category=${param.category}">다음</a></li>
        </c:if>
      </ul>
      <span class="paging-info">총 ${totalCount}건, ${page + 1}/${totalPages}페이지</span>
    </c:if>
  </div>

  <!-- 검색 결과 모달 -->
  <div id="resultModal" class="modal" role="dialog" aria-modal="true" aria-labelledby="modalTitle" style="display:none;">
    <div class="modal-content">
      <span class="close" onclick="closeModal()" aria-label="닫기">&times;</span>
      <h3 id="modalTitle">검색 결과</h3>
	  <div style="text-align:right; margin-bottom:10px;">
        <button type="button" class="btn btn-success" onclick="downloadExcelFromModal()">엑셀 다운로드</button>
      </div>
      <div id="modalResultBody"><!-- Ajax 결과 테이블이 여기에 표시 --></div>
    </div>
  </div>

  <!-- CSRF를 JS에서 쓰기 위해 노출 -->
  <meta name="_csrf_header" content="${_csrf.headerName}">
  <meta name="_csrf"        content="${_csrf.token}">
</main>

  <script>
    function downloadProfitExcel() {
      const item_code = document.getElementById('code').value;
      const item_name = document.getElementById('name').value;
      const category = document.getElementById('category').value;
      const params = new URLSearchParams();
      if (item_code) params.append('item_code', item_code);
      if (item_name) params.append('item_name', item_name);
      if (category) params.append('category', category);
      const url = '/profit/excel?' + params.toString();
      fetch(url, {
        method: 'GET'
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
      const params = new URLSearchParams();
      if (item_code) params.append('item_code', item_code);
      if (item_name) params.append('item_name', item_name);
      if (category) params.append('category', category);
      const url = '/profit/search?' + params.toString();
      fetch(url, {
        method: 'GET'
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
      const params = new URLSearchParams();
      if (item_code) params.append('item_code', item_code);
      if (item_name) params.append('item_name', item_name);
      if (category) params.append('category', category);
      const url = '/profit/excel-modal?' + params.toString();
      fetch(url, {
        method: 'GET'
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
    .pagination {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-top: 20px;
    }
    .paging-list {
      list-style: none;
      padding: 0;
      display: flex;
      gap: 5px;
    }
    .paging-list li {
      display: inline;
    }
    .paging-list a {
      text-decoration: none;
      padding: 8px 12px;
      border: 1px solid #007bff;
      color: #007bff;
      border-radius: 4px;
    }
    .paging-list a.active {
      background-color: #007bff;
      color: white;
    }
    .paging-info {
      font-size: 14px;
      color: #555;
    }
  </style>

</body>


<%@ include file="../common/footer.jsp" %>