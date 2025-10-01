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
request.setAttribute("pageTitle", "판매출고");
request.setAttribute("active_sales", "active");
request.setAttribute("active_sale", "active");
%>
<%@ include file="../common/header.jsp" %>
<link rel="stylesheet" href="<c:url value='/css/stock.css?v=1'/>">
<link rel="stylesheet" href="<c:url value='/css/bom.css?v=1'/>">

<jsp:useBean id="now" class="java.util.Date"/>
<fmt:formatDate value="${now}" pattern="yyyy-MM-dd" var="today"/>

<!-- CSRF를 JS에서 쓰기 위해 노출 -->
<meta name="_csrf_header" content="${_csrf.headerName}">
<meta name="_csrf" content="${_csrf.token}">

<body>

  <h2>판매/출고</h2>

  <!-- 상단 검색 필터 -->
  <div class="filter-small">
    <div class="field">
      <label>제품코드</label>
      <input type="text" id="code" name="code" placeholder="예: P-1001">
    </div>

    <div class="field">
      <label>제품명</label>
      <input type="text" id="name" name="name" placeholder="예: 전동드릴">
    </div>

    <div class="field">
      <label>출고일자</label>
      <input type="date" id="outDate" name="outDate" value="<c:choose><c:when test='${not empty param.outDate}'>${param.outDate}</c:when><c:otherwise>${firstDayOfMonth}</c:otherwise></c:choose>">
    </div>

    <div class="field">
      <label>카테고리</label>
      <div class="select-wrap">
        <select id="category" name="category">
          <option value="">전체</option>
          <option value="product">제품</option>
          <option value="materials">원자재</option>
        </select>
      </div>
    </div>

    <div class="btn-group">
      <button type="button" class="btn btn-primary" id="btnSearch">조회</button>
	  <button type="button" class="btn btn-success" id="downloadExcel">엑셀 다운로드</button>
    </div>
  </div>


  
  <h2>판매현황</h2>

  <table class="table">
    <thead>
      <tr>
        <th>출고번호</th>
        <th>출고일</th>
        <th>제품코드</th>
        <th>제품명</th>
        <th>수량</th>
        <th>단가</th>
		<th>금액</th>
        <th>출고상태</th>
      </tr>
    </thead>
    <tbody>
      <c:forEach var="row" items="${salesList}">
        <fmt:formatDate value="${row.saleDate}" pattern="yyyy-MM-dd" var="saleDateStr"/>
        <tr>
          <td>${row.pk}</td>
          <td><fmt:formatDate value="${row.saleDate}" pattern="yyyy-MM-dd"/></td>
          <td>prod2025<c:choose><c:when test="${row.productId lt 10}">0${row.productId}</c:when><c:otherwise>${row.productId}</c:otherwise></c:choose></td>
          <td>${row.productName}</td>
          <td class="text-right">
            <fmt:formatNumber value="${row.quantity}" type="number" groupingUsed="true"/>
          </td>
		  <td><fmt:formatNumber value="${row.price}" type="number" groupingUsed="true"/></td>
          <td class="text-right">
            <fmt:formatNumber value="${row.earning}" type="number" groupingUsed="true"/>
          </td>
          <td>
            <c:choose>
              <c:when test="${saleDateStr lt today}">출고완료</c:when>
              <c:otherwise>출고준비</c:otherwise>
            </c:choose>
          </td>
        </tr>
      </c:forEach>

      <c:if test="${empty salesList}">
        <tr>
          <td colspan="8" style="text-align:center;">판매/출고 데이터가 없습니다.</td>
        </tr>
      </c:if>
    </tbody>
  </table>

  <!-- Modal for search results -->
  <div id="searchModal" class="modal" style="display:none;">
    <div class="modal-content">
      <span class="close" id="closeModal">&times;</span>
      <h3>검색 결과</h3>
	  <div style="text-align:right; margin-top:10px;">
	    <button type="button" class="btn btn-success" id="downloadExcelModal" style="float:right; margin-bottom:10px;">엑셀 다운로드</button>
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

  <!-- (선택) 조회 버튼 동작 자리 -->
  <script>
    document.getElementById('btnSearch')?.addEventListener('click', function (e) {
      e.preventDefault();
      const p = new URLSearchParams({
        code:     document.getElementById('code').value || '',
        name:     document.getElementById('name').value || '',
        outDate:  document.getElementById('outDate').value || '',
        category: document.getElementById('category').value || ''
      });
      fetch('/sales/outbound?' + p.toString(), { headers: { 'X-Requested-With': 'XMLHttpRequest' } })
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
      fetch('/sales/excel')
        .then(response => {
          if (!response.ok) throw new Error('엑셀 다운로드 실패');
          return response.blob();
        })
        .then(blob => {
          var url = window.URL.createObjectURL(blob);
          var a = document.createElement('a');
          a.href = url;
          a.download = '판매출고_전체리스트.xlsx';
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
      var code = document.getElementById('code').value;
      var name = document.getElementById('name').value;
      var outDate = document.getElementById('outDate').value;
      var category = document.getElementById('category').value;
      var csrfHeader = document.querySelector('meta[name="_csrf_header"]')?.content;
      var csrfToken = document.querySelector('meta[name="_csrf"]')?.content;
      var headers = {
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
      };
      if (csrfHeader && csrfToken) headers[csrfHeader] = csrfToken;
      var params = new URLSearchParams();
      if (code) params.append('code', code);
      if (name) params.append('name', name);
      if (outDate) params.append('outDate', outDate);
      if (category) params.append('category', category);
      fetch('/sales/excel-modal', {
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
        a.download = '판매출고_검색결과.xlsx';
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