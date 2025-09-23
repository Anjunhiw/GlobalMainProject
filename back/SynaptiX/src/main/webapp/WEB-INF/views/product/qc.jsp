<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
request.setAttribute("pageTitle", "QC");
request.setAttribute("active_product", "active");
request.setAttribute("active_qc", "active");
%>
<%@ include file="../common/header.jsp" %>
<link rel="stylesheet" href="<c:url value='/css/stock.css?v=1'/>">
<link rel="stylesheet" href="<c:url value='/css/bom.css?v=1'/>">

<body>

  <h2>QC 검사 결과 조회</h2>

  <!-- 상단 필터 -->
  <div class="filter-smallq">
    <div class="field">
      <label>기간</label>
      <div class="input-with-btn">
        <input type="date" id="dateFrom" name="dateFrom">
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
      <button type="button" class="btn btn-success" onclick="openQcRegister()">등록</button>
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
      <c:forEach var="qc" items="${qcList}">
        <tr>
          <td>${qc.prodCode}</td>
          <td>${qc.prodName}</td>
          <td>${qc.model}</td>
          <td>${qc.specification}</td>
          <td>
            <fmt:formatDate value="${qc.inspectedAt}" pattern="yyyy-MM-dd"/>
          </td>
          <td>${qc.inspector}</td>
          <td>
            <c:choose>
              <c:when test="${qc.passed}">합격</c:when>
              <c:otherwise>불합격</c:otherwise>
            </c:choose>
          </td>
        </tr>
      </c:forEach>

      <c:if test="${empty qcList}">
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
      <form id="qcRegisterForm">
        <div class="field">
          <label>제품코드</label>
          <input type="text" id="regProdCode" name="prodCode" required>
        </div>
        <div class="field">
          <label>제품명</label>
          <input type="text" id="regProdName" name="prodName" required>
        </div>
        <div class="field">
          <label>모델명</label>
          <input type="text" id="regModel" name="model">
        </div>
        <div class="field">
          <label>규격</label>
          <input type="text" id="regSpec" name="specification">
        </div>
        <div class="field">
          <label>검사일자</label>
          <input type="date" id="regInspectedAt" name="inspectedAt" required>
        </div>
        <div class="field">
          <label>검사자</label>
          <input type="text" id="regInspector" name="inspector" required>
        </div>
        <div class="field">
          <label>합격여부</label>
          <select id="regPassed" name="passed" required>
            <option value="true">합격</option>
            <option value="false">불합격</option>
          </select>
        </div>
        <div class="btn-group">
          <button type="button" class="btn btn-success" onclick="submitQcRegister()">저장</button>
          <button type="button" class="btn btn-secondary" onclick="closeQcRegisterModal()">취소</button>
        </div>
      </form>
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
    function submitQcRegister() {
      const form = document.getElementById('qcRegisterForm');
      const formData = new FormData(form);
      const params = {};
      for (const [key, value] of formData.entries()) {
        params[key] = value;
      }
      fetch('/qc/register', {
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
      const prodName = document.getElementById('prodName').value;
      const category = document.getElementById('category').value;
      fetch('/qc/search', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          [csrfHeader]: csrfToken
        },
        body: JSON.stringify({ dateFrom, prodName, category })
      })
      .then(res => res.text())
      .then(html => {
        document.querySelector('tbody').innerHTML = html;
      })
      .catch(() => {
        alert('검색 중 오류가 발생했습니다.');
      });
    });
  </script>
</body>
</html>
<%@ include file="../common/footer.jsp" %>