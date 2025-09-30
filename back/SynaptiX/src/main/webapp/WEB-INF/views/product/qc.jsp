<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.util.Date, java.text.SimpleDateFormat" %>
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
request.setAttribute("pageTitle", "QC");
request.setAttribute("active_product", "active");
request.setAttribute("active_qc", "active");
%>
<%@ include file="../common/header.jsp" %>
<!-- CSRF를 JS에서 쓰기 위해 노출 -->
<meta name="_csrf_header" content="${_csrf.headerName}">
<meta name="_csrf" content="${_csrf.token}">
<link rel="stylesheet" href="<c:url value='/css/stock.css?v=1'/>">
<link rel="stylesheet" href="<c:url value='/css/bom.css?v=1'/>">

<body>

  <h2>QC 검사 결과 조회</h2>

  <!-- 상단 필터 -->
  <div class="filter-smallq">
    <div class="field">
      <label>기간</label>
      <div class="input-with-btn">
        <input type="date" id="dateFrom" name="dateFrom" placeholder="시작일" value="<c:choose><c:when test='${not empty param.dateFrom}'>${param.dateFrom}</c:when><c:otherwise>${firstDayOfMonth}</c:otherwise></c:choose>">
        ~
        <input type="date" id="dateTo" name="dateTo" placeholder="종료일" value="<c:choose><c:when test='${not empty param.dateTo}'>${param.dateTo}</c:when><c:otherwise>${lastDayOfMonth}</c:otherwise></c:choose>">
      </div>
    </div>

 
    <div class="field">
      <label>제품명</label>
      <input type="text" id="prodName" name="prodName" placeholder="예: 전동드릴">
    </div>

    <div class="field">
      <label>합격여부</label>
      <div class="select-wrap">
        <select id="category" name="category">
          <option value="">전체</option>
          <option value="passed">합격</option>
          <option value="failed">불합격</option>
        </select>
      </div>
    </div>

    <div class="btn-group">
      <button type="button" class="btn btn-primary" id="btnSearch">조회</button>
      <button type="button" class="btn btn-ee" onclick="openQcRegister()">등록</button>
	  <button type="button" class="btn btn-success" id="downloadExcel">엑셀 다운로드</button>
    </div>
  </div>
 
  

  <h2>QC 검사 결과</h2>

  <table class="table">
    <thead>
      <tr>
        <th>제품코드</th>
        <th>제품명</th>
        <th>모델명</th>
        <th>규격</th>
        <th>검사일자</th>
        <th>합격여부</th>
      </tr>
    </thead>
    <tbody>
      <!-- 컨트롤러에서 model.addAttribute("qcList", 리스트) 로 전달 -->
      <c:forEach var="qc" items="${list}">
        <tr>
          <td>prod2025<c:choose><c:when test="${qc.code lt 10}">0${qc.code}</c:when><c:otherwise>${qc.code}</c:otherwise></c:choose></td>
          <td>${qc.name}</td>
          <td>${qc.model}</td>
		  <td>${qc.specification}</td>
          <td><fmt:formatDate value="${qc.period}" pattern="yyyy-MM-dd"/></td>
          <td>
            <c:choose>
              <c:when test="${qc.passed}">합격</c:when>
              <c:otherwise>불합격</c:otherwise>
            </c:choose>
          </td>
        </tr>
      </c:forEach>

      <c:if test="${empty list}">
        <tr>
          <td colspan="6" style="text-align:center;">QC 검사 데이터가 없습니다.</td>
        </tr>
      </c:if>
    </tbody>
  </table>

  <!-- 등록 모달 -->
  <div id="qcRegisterModal" class="modal" style="display:none;" role="dialog" aria-modal="true" aria-labelledby="qcRegisterModalTitle">
    <div class="modal-content">
      <span class="close" onclick="closeQcRegisterModal()" aria-label="닫기">&times;</span>
      <h3 id="qcRegisterModalTitle">QC 등록</h3>
      <form id="qcRegisterForm" class="form-rows">
        <div class="field">
          <label>MPS ID</label>
          <input type="number" id="regMpsId" name="mpsId" required>
        </div>
        <div class="field">
          <label>합격여부</label>
          <select id="regPassed" name="passed" required>
            <option value="true">합격</option>
            <option value="false">불합격</option>
          </select>
        </div>
        <div class="actions">
          <button type="button" class="btn-pill" onclick="submitQcRegister()">저장</button>
        </div>
      </form>
    </div>
  </div>

  <!-- 조회 결과 모달 -->
  <div id="qcSearchModal" class="modal" style="display:none; position:fixed; top:0; left:0; width:100vw; height:100vh; background:rgba(0,0,0,0.3); z-index:9999; align-items:center; justify-content:center;">
    <div style="background:#fff; padding:30px; border-radius:8px; min-width:600px; position:relative; max-height:80vh; overflow:auto;">
      <h4>QC 검사 결과</h4>
      <div id="qcSearchResult">
        <!-- 검색 결과 테이블이 여기에 동적으로 렌더링됩니다. -->
      </div>
      <div class="btn-group" style="margin-top:15px;">
        <button type="button" class="btn btn-info" id="downloadExcelModal">엑셀 다운로드</button>
        <button type="button" class="btn btn-secondary" onclick="closeQcSearchModal()">닫기</button>
      </div>
    </div>
  </div>

  <!-- (선택) 검색버튼에 대한 간단한 자바스크립트 자리만 잡아둠 -->
  <script>
    function openQcRegister() {
      document.getElementById('qcRegisterModal').style.display = 'block';
      document.getElementById('qcRegisterForm').reset();
    }
    function closeQcRegisterModal() {
      document.getElementById('qcRegisterModal').style.display = 'none';
    }
    function closeQcSearchModal() {
      document.getElementById('qcSearchModal').style.display = 'none';
    }
    function submitQcRegister() {
      const form = document.getElementById('qcRegisterForm');
      const mpsId = form.querySelector('[name="mpsId"]').value;
      const passed = form.querySelector('[name="passed"]').value === 'true';
      const params = { mpsId: Number(mpsId), passed };
      fetch('/qc', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          [csrfHeader]: csrfToken
        },
        body: JSON.stringify(params)
      })
      .then(res => res.json())
      .then(data => {
        if (data.success) {
          alert('등록되었습니다.');
          closeQcRegisterModal();
          location.reload();
        } else {
          alert('등록 실패: ' + (data.message || '오류'));
        }
      })
      .catch(() => {
        alert('등록 중 오류가 발생했습니다.');
      });
    }
    document.getElementById('btnSearch')?.addEventListener('click', function () {
      const dateFrom = document.getElementById('dateFrom').value;
      const dateTo = document.getElementById('dateTo').value;
      const prodName = document.getElementById('prodName').value;
      const category = document.getElementById('category').value;
      fetch('/qc/search', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          [csrfHeader]: csrfToken
        },
        body: JSON.stringify({ dateFrom, dateTo, prodName, category })
      })
      .then(res => res.json())
      .then(data => {
        let html = '';
        if (data && data.length > 0) {
          html += '<table class="table"><thead><tr>';
          html += '<th>제품코드</th><th>제품명</th><th>모델명</th><th>규격</th><th>검사일자</th><th>합격여부</th>';
          html += '</tr></thead><tbody>';
          data.forEach(function(qc) {
            html += '<tr>';
            html += '<td>prod2025' + (qc.code < 10 ? '0' + qc.code : qc.code) + '</td>';
            html += '<td>' + qc.name + '</td>';
            html += '<td>' + (qc.model || '') + '</td>';
            html += '<td>' + (qc.specification || '') + '</td>';
            html += '<td>' + (qc.period ? qc.period.substring(0, 10) : '') + '</td>';
            html += '<td>' + (qc.passed ? '합격' : '불합격') + '</td>';
            html += '</tr>';
          });
          html += '</tbody></table>';
        } else {
          html = '<div style="text-align:center; padding:30px;">검색 결과가 없습니다.</div>';
        }
        document.getElementById('qcSearchResult').innerHTML = html;
        document.getElementById('qcSearchModal').style.display = 'flex';
      })
      .catch(() => {
        document.getElementById('qcSearchResult').innerHTML = '<div style="text-align:center; padding:30px; color:red;">검색 중 오류가 발생했습니다.</div>';
        document.getElementById('qcSearchModal').style.display = 'flex';
      });
    });

    // QC 전체 리스트 엑셀 다운로드
    document.getElementById('downloadExcel').onclick = function() {
      fetch('/qc/excel')
        .then(response => {
          if (!response.ok) throw new Error('엑셀 다운로드 실패');
          return response.blob();
        })
        .then(blob => {
          var url = window.URL.createObjectURL(blob);
          var a = document.createElement('a');
          a.href = url;
          a.download = 'QC_전체리스트.xlsx';
          document.body.appendChild(a);
          a.click();
          a.remove();
          window.URL.revokeObjectURL(url);
        })
        .catch(() => {
          alert('엑셀 다운로드 중 오류가 발생했습니다.');
        });
    };
    // QC 조회 모달 엑셀 다운로드
    document.getElementById('downloadExcelModal').onclick = function() {
      var dateFrom = document.getElementById('dateFrom').value;
      var dateTo = document.getElementById('dateTo').value;
      var prodName = document.getElementById('prodName').value;
      var category = document.getElementById('category').value;
      var csrfHeader = document.querySelector('meta[name="_csrf_header"]')?.content;
      var csrfToken = document.querySelector('meta[name="_csrf"]')?.content;
      var headers = {
        'Content-Type': 'application/json'
      };
      if (csrfHeader && csrfToken) headers[csrfHeader] = csrfToken;
      var body = JSON.stringify({ dateFrom, dateTo, prodName, category });
      fetch('/qc/excel-modal', {
        method: 'POST',
        headers: headers,
        body: body
      })
      .then(response => {
        if (!response.ok) throw new Error('엑셀 다운로드 실패');
        return response.blob();
      })
      .then(blob => {
        var url = window.URL.createObjectURL(blob);
        var a = document.createElement('a');
        a.href = url;
        a.download = 'QC_검색결과.xlsx';
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