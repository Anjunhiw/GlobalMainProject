<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
request.setAttribute("pageTitle", "인사관리");
request.setAttribute("active_personal", "active");
%>
<%@ include file="../common/header.jsp" %>
<link rel="stylesheet" href="<c:url value='/css/stock.css?v=1'/>">
<link rel="stylesheet" href="<c:url value='/css/bom.css?v=1'/>">
<body>
  <h2>인사</h2>

  <!-- 필터 영역 -->
  <div class="filter-smallq">
    <div class="field">
      <label>소속부서</label>
      <input type="text" id="dept" name="dept" value="${param.dept}" placeholder="">
    </div>
    <div class="field">
      <label>직급</label>
      <input type="text" id="position" name="position" value="${param.position}" placeholder="">
    </div>
    <div class="field">
      <label>이름</label>
      <input type="text" id="empName" name="empName" value="${param.empName}" placeholder="">
    </div>

    <div class="btn-group">
      <button type="button" id="btn-search" class="btn btn-primary">조회</button>
    </div>
  </div>

  <h3>지출내역</h3>
  <table class="table">
    <thead>
      <tr>
        <th>사번</th>
        <th>이름</th>
        <th>생년월일</th>
        <th>이메일</th>
        <th>부서명</th>
        <th>직급</th>
        <th>근속년수</th>
        <th>급여</th>
      </tr>
    </thead>
    <tbody>
      <c:forEach var="emp" items="${employees}">
        <tr>
          <td>${emp.userId}</td>
          <td>${emp.name}</td>
          <td>"${emp.birth}"</td>
          <td>${emp.email}</td>
          <td>${emp.dept}</td>
          <td>${emp.rank}</td>
          <td><fmt:formatNumber value="${emp.years}" type="number" maxFractionDigits="0"/></td>
          <td class="text-right"><fmt:formatNumber value="${emp.salary}" type="number"/></td>
        </tr>
      </c:forEach>

      <c:if test="${empty employees}">
        <tr>
          <td colspan="8" style="text-align:center;">사원 데이터가 없습니다.</td>
        </tr>
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
    document.getElementById('btn-search')?.addEventListener('click', function (e) {
      e.preventDefault();
      const params = new URLSearchParams({
        dept: document.getElementById('dept').value || '',
        position: document.getElementById('position').value || '',
        empName: document.getElementById('empName').value || ''
      });
      fetch('/hr/search?' + params.toString(), { headers: { 'X-Requested-With': 'XMLHttpRequest' } })
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