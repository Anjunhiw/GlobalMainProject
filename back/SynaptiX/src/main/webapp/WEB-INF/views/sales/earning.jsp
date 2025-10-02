<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
request.setAttribute("pageTitle", "매출");
request.setAttribute("active_sales", "active");
request.setAttribute("active_earning", "active");
%>
<%@ include file="../common/header.jsp" %>
<link rel="stylesheet" href="<c:url value='/css/stock.css?v=1'/>">
<link rel="stylesheet" href="<c:url value='/css/bom.css?v=1'/>">

<!-- CSRF를 JS에서 쓰기 위해 노출 -->
<meta name="_csrf_header" content="${_csrf.headerName}">
<meta name="_csrf" content="${_csrf.token}">

<body>
  <h2>매출</h2>

  <!-- 필터 -->
  <div class="filter-smalll">
    <div class="field">
      <label>제품코드</label>
      <input type="text" id="prodCode" name="prodCode" placeholder="예: P-1001" value="${param.prodCode}">
    </div>

    <div class="field">
      <label>제품명</label>
      <input type="text" id="prodName" name="prodName" placeholder="예: 전동드릴" value="${param.prodName}">
    </div>

    <div class="field">
      <label>QC합불여부</label>
      <div class="select-wrap">
        <select id="qc" name="qc">
          <option value="" ${empty param.qc ? 'selected' : ''}>전체</option>
          <option value="PASS" ${param.qc == 'PASS' ? 'selected' : ''}>합격</option>
          <option value="FAIL" ${param.qc == 'FAIL' ? 'selected' : ''}>불량</option>
        </select>
      </div>
    </div>

    <div class="field">
      <label>시작일자</label>
      <input type="date" id="startDate" name="startDate" value="<c:choose><c:when test='${not empty param.startDate}'>${param.startDate}</c:when><c:otherwise>${firstDayOfMonth}</c:otherwise></c:choose>">
    </div>

    <div class="field">
      <label>종료일자</label>
      <input type="date" id="endDate" name="endDate" value="<c:choose><c:when test='${not empty param.endDate}'>${param.endDate}</c:when><c:otherwise>${lastDayOfMonth}</c:otherwise></c:choose>">
    </div>

    <div class="btn-group">
      <button type="button" id="btnSearch" class="btn btn-primary">조회</button>
      <button type="button" class="btn btn-success" id="downloadExcel">엑셀 다운로드</button>
    </div>
  </div>


  <h2>매출현황</h2>

  <table class="table">
    <thead>
      <tr>
        <th>제품코드</th>
        <th>판매일자</th>
        <th>제품명</th>
        <th>판매수량</th>
        <th>단가</th>
        <th>판매금액</th>
        <th>순이익</th>
        <th>재고량</th>
      </tr>
    </thead>
    <tbody>
      <!-- 컨트롤러: model.addAttribute("sales", list) -->
      <c:forEach var="s" items="${earningList}">
        <tr>
          <td>${s.ProductId}</td>
          <td><fmt:formatDate value="${s.Date}" pattern="yyyy-MM-dd"/></td>
          <td>${s.ProductName}</td>
          <td class="text-right"><fmt:formatNumber value="${s.Amount}" type="number" maxFractionDigits="0" groupingUsed="true"/></td>
          <td class="text-right"><fmt:formatNumber value="${s.Price}" type="number" groupingUsed="true"/></td>
          <td class="text-right"><fmt:formatNumber value="${s.Total}"  type="number" groupingUsed="true"/></td>
          <td class="text-right">
            <fmt:formatNumber value="${s.Earning}" type="number" groupingUsed="true"/>
          </td>
          <td class="text-right"><fmt:formatNumber value="${s.Stock}" type="number" maxFractionDigits="0" groupingUsed="true"/></td>
        </tr>
      </c:forEach>

      <c:if test="${empty earningList}">
        <tr><td colspan="8" style="text-align:center;">매출 데이터가 없습니다.</td></tr>
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

</body>

  <!-- 조회 버튼: 모달 AJAX 조회로 변경 -->
  <script>
    document.getElementById('btnSearch')?.addEventListener('click', function (e) {
      e.preventDefault();
      const p = new URLSearchParams({
        prodCode : document.getElementById('prodCode').value || '',
        prodName : document.getElementById('prodName').value || '',
        qc       : document.getElementById('qc').value || '',
        startDate: document.getElementById('startDate').value || '',
        endDate  : document.getElementById('endDate').value || ''
      });
      fetch('/sales/earning/search?' + p.toString(), { headers: { 'X-Requested-With': 'XMLHttpRequest' } })
        .then(res => res.text())
        .then(html => {
          document.getElementById('modalResults').innerHTML = html;
          document.getElementById('searchModal').style.display = 'flex';
          // 팝업이 열릴 때마다 다운로드 버튼 이벤트 연결 (기존 이벤트 제거 후 재연결)
          const excelBtn = document.getElementById('downloadExcelModal');
          if (excelBtn) {
            excelBtn.onclick = null; // 기존 이벤트 제거
            excelBtn.addEventListener('click', function(e) {
              e.preventDefault(); // 기본 동작 방지
              var prodCode = document.getElementById('prodCode').value;
              var prodName = document.getElementById('prodName').value;
              var qc = document.getElementById('qc').value;
              var startDate = document.getElementById('startDate').value;
              var endDate = document.getElementById('endDate').value;
              var params = new URLSearchParams();
              if (prodCode) params.append('prodCode', prodCode);
              if (prodName) params.append('prodName', prodName);
              if (qc) params.append('qc', qc);
              if (startDate) params.append('startDate', startDate);
              if (endDate) params.append('endDate', endDate);
              var url = '/sales/earning/excel-modal?' + params.toString();
              fetch(url)
              .then(response => {
                if (!response.ok) throw new Error('엑셀 다운로드 실패');
                return response.blob();
              })
              .then(blob => {
                var downloadUrl = window.URL.createObjectURL(blob);
                var a = document.createElement('a');
                a.href = downloadUrl;
                a.download = '매출_검색결과.xlsx';
                document.body.appendChild(a);
                a.click();
                a.remove();
                window.URL.revokeObjectURL(downloadUrl);
              })
              .catch(() => {
                alert('엑셀 다운로드 중 오류가 발생했습니다.');
              });
            });
          }
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
      fetch('/sales/earning/excel')
        .then(response => {
          if (!response.ok) throw new Error('엑셀 다운로드 실패');
          return response.blob();
        })
        .then(blob => {
          var url = window.URL.createObjectURL(blob);
          var a = document.createElement('a');
          a.href = url;
          a.download = '매출_전체리스트.xlsx';
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


</html>
<%@ include file="../common/footer.jsp" %>