<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
request.setAttribute("pageTitle", "BOM 관리");
request.setAttribute("active_product", "active");
request.setAttribute("active_bom", "active");
%>
<%@ include file="../common/header.jsp" %>

<link rel="stylesheet" href="<c:url value='/css/stock.css?v=1'/>">
<link rel="stylesheet" href="<c:url value='/css/bom.css?v=1'/>">


<main class ="container">

	<h2>BOM</h2>

<div class="filters">
  <div class="field">
    <label>제품코드</label>
    <input type="text" id="code" name="code" placeholder="예: A-1001">
  </div>
  <div class="field">
    <label>제품명</label>
    <input type="text" id="name" name="name" placeholder="예:***">
  </div>
  <div class="field">
    <label>카테고리</label>
    <div class="select-wrap">
      <select id="category" name="category">
        <option value="">전체</option>
        <option value="원자재">원자재</option>
        <option value="제품">제품</option>
      </select>
    </div>
  </div>
  <div class="field">
    <label>원자재코드</label>
    <input type="text" id="model" name="model" placeholder="예: MTR-200">
  </div>
  <div class="field">
    <label>원자재명</label>
    <input type="text" id="model" name="model" placeholder="예: 모터">
  </div>
  <div class="btn-group">
    <button type="button" id="btn-search" class="btn btn-primary">검색</button>
    <button type="button" class="btn btn-ee" onclick="openRegister()">등록</button>
	<button type="button" id="btnExcel" class="btn btn-success">엑셀 다운로드</button>
  </div>
</div>

<br/>
<!-- CSRF -->
<input type="hidden" id="csrfToken" name="${_csrf.parameterName}" value="${_csrf.token}" />



<script>
  var csrfHeader = "${_csrf.headerName}";
  var csrfToken  = "${_csrf.token}";

  // 등록 모달 열기
  function openRegister() {
    document.getElementById('bomRegisterModal').style.display = 'block';
    document.getElementById('bomRegisterForm').reset();
  }

  // 등록 모달 닫기
  function closeBomRegisterModal() {
    document.getElementById('bomRegisterModal').style.display = 'none';
  }

  // BOM 등록 전송
  function submitBomRegister() {
    const form = document.getElementById('bomRegisterForm');
    const formData = new FormData(form);
    const params = {};
    for (const [key, value] of formData.entries()) {
      params[key] = value;
    }
    fetch('/bom/register', {
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
        closeBomRegisterModal();
        location.reload();
      } else {
        alert('등록 실패: ' + (data.message || '오류'));
      }
    })
    .catch(() => {
      alert('등록 중 오류가 발생했습니다.');
    });
  }

  // 검색/조회 버튼 이벤트 연결
  function searchBom() {
    const code = document.getElementById('code').value;
    const name = document.getElementById('name').value;
    const category = document.getElementById('category').value;
    const model = document.getElementById('model').value;
    fetch('/bom/search', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        [csrfHeader]: csrfToken
      },
      body: JSON.stringify({ code, name, category, model })
    })
    .then(res => res.text())
    .then(html => {
      document.getElementById('bomResultBodyModal').innerHTML = html;
      openBomResultModal();
      bindModalExcelButton(); // 검색 결과 삽입 후 이벤트 연결
    })
    .catch(() => {
      alert('검색 중 오류가 발생했습니다.');
    });
  }
  document.getElementById('btn-search')?.addEventListener('click', searchBom);

  // 엑셀 다운로드 (첫페이지)
  document.getElementById('btnExcel')?.addEventListener('click', function () {
    window.location.href = '/bom/excel';
  });

  // 모달 엑셀 다운로드 버튼 이벤트 연결 함수
  function bindModalExcelButton() {
    const btn = document.getElementById('btnModalExcel');
    if (!btn) return;
    btn.onclick = function () {
      const code = document.getElementById('code')?.value || '';
      const name = document.getElementById('name')?.value || '';
      const category = document.getElementById('category')?.value || '';
      const model = document.getElementById('model')?.value || '';
      const materialName = document.getElementById('model')?.value || '';
      const params = new URLSearchParams({ code, name, category, model, materialName });
      fetch('/bom/excel-modal?' + params.toString(), {
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
        a.download = '검색결과_BOM.xlsx';
        document.body.appendChild(a);
        a.click();
        a.remove();
        window.URL.revokeObjectURL(url);
      })
      .catch(() => {
        alert('엑셀 다운로드 중 오류가 발생했습니다.');
      });
    };
  }
</script>

<!-- 등록 모달 -->
<div id="bomRegisterModal" class="modal" style="display:none;" role="dialog" aria-modal="true" aria-labelledby="bomRegisterModalTitle">
  <div class="modal-content">
    <span class="close" onclick="closeBomRegisterModal()" aria-label="닫기">&times;</span>
    <h3 id="bomRegisterModalTitle">BOM 등록</h3>
    <form id="bomRegisterForm" class="form-rows">
      <div class="field">
        <label>제품ID</label>
        <input type="number" id="regProductId" name="productId" required>
      </div>
      <div class="field">
        <label>원자재ID</label>
        <input type="number" id="regMaterialId" name="materialId" required>
      </div>
      <div class="field">
        <label>필요자재량</label>
        <input type="number" step="0.01" id="regMaterialAmount" name="materialAmount" required>
      </div>

        <div class="actions">
          <button type="button" class="btn-pill" onclick="submitBomRegister()">저장</button>
        </div>
      </div>
    </form>
  </div>
</div>

<!-- 수정 모달 -->
<div id="bomEditModal" class="modal" style="display:none;" role="dialog" aria-modal="true" aria-labelledby="bomEditModalTitle">
  <div class="modal-content">
    <span class="close" onclick="closeBomEditModal()" aria-label="닫기">&times;</span>
    <h3 id="bomEditModalTitle">BOM 수정</h3>
    <form id="bomEditForm">
      <div class="field">
        <label>제품ID</label>
        <input type="number" id="editProductId" name="productId" readonly>
      </div>
      <div class="field">
        <label>원자재ID</label>
        <input type="number" id="editMaterialId" name="materialId" readonly>
      </div>
      <div class="field">
        <label>필요자재량</label>
        <input type="number" step="0.01" id="editMaterialAmount" name="materialAmount" required>
      </div>
      <div class="btn-group">
        <button type="button" class="btn btn-success" onclick="submitBomEdit()">저장</button>
        <button type="button" class="btn btn-secondary" onclick="closeBomEditModal()">취소</button>
      </div>
    </form>
  </div>
</div>

<!-- 검색 결과 모달 -->
<div id="bomResultModal" class="modal" style="display:none;" role="dialog" aria-modal="true" aria-labelledby="bomResultModalTitle">
  <div class="modal-content" style="min-width:900px;max-width:95vw;">
    <span class="close" onclick="closeBomResultModal()" aria-label="닫기">&times;</span>
    <h3 id="bomResultModalTitle">검색 결과</h3>
    <div id="bomResultBodyModal"></div>
    <div class="btn-group" style="margin-top:12px;">
      <button type="button" class="btn btn-info" id="btnModalExcel">엑셀 다운로드</button>
      <button type="button" class="btn btn-secondary" onclick="closeBomResultModal()">닫기</button>
    </div>
  </div>
</div>

<!-- 검색 결과 표시 영역 -->
<div id="bomResultBody">
<!-- 기존 테이블 영역을 여기에 옮기면 Ajax로 갱신 가능 -->
<table class="table">
  <tr>
    <th>제품코드</th>
    <th>생산제품명</th>
    <th>소요원자재명</th>
    <th>소요원자재량</th>
	<th>소요금액</th>
	<th>수정</th>
  </tr>

  <c:forEach var="bom" items="${bomList}">
    <c:set var="price" value="0"/>
    <c:forEach var="mat" items="${materialList}">
      <c:if test="${mat.pk == bom.materialId}">
        <c:set var="price" value="${mat.price}"/>
      </c:if>
    </c:forEach>
    <tr>
      <td>prod2025<c:choose><c:when test="${bom.productId lt 10}">0${bom.productId}</c:when><c:otherwise>${bom.productId}</c:otherwise></c:choose></td>
      <td>${bom.productName}</td>
      <td>${bom.materialName}</td>
      <td><fmt:formatNumber value="${bom.materialAmount}" type="number" maxFractionDigits="2"/></td>
      <td><fmt:formatNumber value="${bom.materialAmount * price}" type="number" maxFractionDigits="0"/></td>
	  <td>
        <button type="button" class="btn btn-edit"
          onclick="openBomEditModal('${bom.productId}', '${bom.materialId}', '${bom.materialAmount != null ? bom.materialAmount : ''}')"
        >수정</button>
      </td>
    </tr>
  </c:forEach>

  <c:if test="${empty bomList}">
    <tr><td colspan="6">데이터가 없습니다.</td></tr>
  </c:if>
</table>
</div>
</main>

<script>
  function openBomEditModal(productId, materialId, materialAmount) {
    document.getElementById('editProductId').value = productId;
    document.getElementById('editMaterialId').value = materialId;
    document.getElementById('editMaterialAmount').value = materialAmount;
    document.getElementById('bomEditModal').style.display = 'block';
  }
  function closeBomEditModal() {
    document.getElementById('bomEditModal').style.display = 'none';
  }
  function submitBomEdit() {
    const form = document.getElementById('bomEditForm');
    const params = {
      productId: form.productId.value,
      materialId: form.materialId.value,
      materialAmount: form.materialAmount.value
    };
    fetch('/bom', {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        [csrfHeader]: csrfToken
      },
      body: JSON.stringify(params)
    })
    .then(res => res.ok ? res.json() : Promise.reject())
    .then(() => {
      alert('수정 완료');
      closeBomEditModal();
      location.reload();
    })
    .catch(() => {
      alert('수정 실패');
    });
  }
  function openBomResultModal() {
    document.getElementById('bomResultModal').style.display = 'block';
  }
  function closeBomResultModal() {
    document.getElementById('bomResultModal').style.display = 'none';
  }
</script>
<%@ include file="../common/footer.jsp" %>