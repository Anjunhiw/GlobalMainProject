<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"  %>
<%
request.setAttribute("active_stock", "active");
request.setAttribute("active_prod", "active");
%>
<%@ include file="../common/header.jsp" %>
<link rel="stylesheet" href="<c:url value='/css/stock.css?v=1'/>">
<link rel="stylesheet" href="<c:url value='/css/bom.css?v=1'/>">
<!-- CSRF를 JS에서 쓰기 위해 노출 -->
<meta name="_csrf_header" content="${_csrf.headerName}">
<meta name="_csrf"        content="${_csrf.token}">
<main class="container">
  <h2>제품 재고관리</h2>
  <div class="filter-smallb">
    <div class="field">
      <label>품목코드</label>
      <input type="text" id="code" name="code" placeholder="예: P-1001">
    </div>
    <div class="field">
      <label>제품명</label>
      <input type="text" id="name" name="name" placeholder="예: 완제품">
    </div>
    <div class="field">
      <label>모델명</label>
      <input type="text" id="model" name="model" placeholder="예: PRD-200">
    </div>
    <div class="field">
      <label>규격</label>
      <input type="text" id="specification" name="specification" placeholder="예: 20mm">
    </div>
    <div class="btn-group">
      <button type="button" class="btn btn-ee" onclick="openRegister()">등록</button>
      <button type="button" class="btn btn-primary" id="btn-search" onclick="searchData()">조회</button>
      <a href="/stock/excel/product">
        <button type=button class="btn btn-success">엑셀 다운로드</button>
      </a>
    </div>
  </div>
  <!-- 검색 결과 모달 -->
  <div id="resultModal" class="modal" role="dialog" aria-modal="true" aria-labelledby="modalTitle">
    <div class="modal-content">
      <span class="close" onclick="closeModal()" aria-label="닫기">&times;</span>
      <div style="text-align:right; margin-bottom:10px;">
        <button type="button" class="btn btn-success" onclick="downloadExcelFromModal()">엑셀 다운로드</button>
      </div>
      <h3 id="modalTitle">검색 결과</h3>
      <div id="modalResultBody"><!-- Ajax 결과 테이블이 여기에 표시 --></div>
    </div>
  </div>
  <!-- 등록 모달 -->
  <div id="registerModal" class="modal" role="dialog" aria-modal="true" aria-labelledby="registerModalTitle">
    <div class="modal-content">
      <span class="close" onclick="closeRegisterModal()" aria-label="닫기">&times;</span>
      <h3 id="registerModalTitle">제품 등록</h3>
      <form id="registerForm" class="form-rows">
        <div class="field">
          <label for="regName" class="label">제품명</label>
          <div class="control">
            <input type="text" id="regName" name="name" required />
          </div>
        </div>
        <div class="field">
          <label for="regModel" class="label">모델명</label>
          <div class="control">
            <input type="text" id="regModel" name="model" />
          </div>
        </div>
        <div class="field">
          <label for="regSpec" class="label">규격</label>
          <div class="control">
            <input type="text" id="regSpec" name="specification" />
          </div>
        </div>
        <div class="field">
          <label for="regPrice" class="label">단가</label>
          <div class="control narrow">
            <input type="number" id="regPrice" name="price" required />
          </div>
        </div>
        <div class="field">
          <label for="regStock" class="label">재고수량</label>
          <div class="control narrow">
            <input type="number" id="regStock" name="stock" min="0" value="0" required />
          </div>
        </div>
        <div class="field">
          <label for="regAmount" class="label">재고금액</label>
          <div class="control">
            <input type="number" id="regAmount" name="amount" min="0" value="0" />
          </div>
        </div>
        <div class="actions">
          <button type="button" class="btn-pill" onclick="submitRegister()">등록</button>
        </div>
      </form>
    </div>
  </div>
  <!-- 수정 모달 -->
  <div id="editModal" class="modal" role="dialog" aria-modal="true" aria-labelledby="editModalTitle" style="display:none;">
    <div class="modal-content">
      <span class="close" onclick="closeEditModal()" aria-label="닫기">&times;</span>
      <h3 id="editModalTitle">제품 수정</h3>
      <form id="editForm" class="form-rows" method="post" action="/stock/edit/product">
        <input type="hidden" id="editPk" name="pk" />
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
        <div class="field">
          <label for="editName" class="label">제품명</label>
          <div class="control">
            <input type="text" id="editName" name="name" required />
          </div>
        </div>
        <div class="field">
          <label for="editModel" class="label">모델명</label>
          <div class="control">
            <input type="text" id="editModel" name="model" />
          </div>
        </div>
        <div class="field">
          <label for="editSpec" class="label">규격</label>
          <div class="control">
            <input type="text" id="editSpec" name="specification" />
          </div>
        </div>
        <div class="field">
          <label for="editPrice" class="label">단가</label>
          <div class="control narrow">
            <input type="number" id="editPrice" name="price" required />
          </div>
        </div>
        <div class="field">
          <label for="editStock" class="label">재고수량</label>
          <div class="control narrow">
            <input type="number" id="editStock" name="stock" min="0" required />
          </div>
        </div>
        <div class="field">
          <label for="editAmount" class="label">재고금액</label>
          <div class="control">
            <input type="number" id="editAmount" name="amount" min="0" />
          </div>
        </div>
        <div class="actions">
          <button type="submit" class="btn-pill">수정</button>
        </div>
      </form>
    </div>
  </div>
  <h2>제품 재고 목록</h2>
  <table>
    <thead>
      <tr>
        <th>품목코드</th><th>제품명</th><th>모델명</th><th>규격</th>
        <th>단가</th><th>재고수량</th><th>재고금액</th><th>수정</th><th>삭제</th>
      </tr>
    </thead>
    <tbody>
      <c:forEach var="product" items="${products}">
        <tr>
          <td>prd2025<c:choose><c:when test="${product.pk lt 10}">0${product.pk}</c:when><c:otherwise>${product.pk}</c:otherwise></c:choose></td>
          <td>${product.name}</td>
          <td>${product.model}</td>
          <td>${product.specification}</td>
          <td><fmt:formatNumber value="${product.price}"  type="number" groupingUsed="true"/></td>
          <td><fmt:formatNumber value="${product.stock}"  type="number" maxFractionDigits="0" groupingUsed="true"/></td>
          <td><fmt:formatNumber value="${product.amount}" type="number" maxFractionDigits="0" groupingUsed="true"/></td>
          <td>
            <button type="button" class="btn btn-sm btn-warning" onclick="openEditModal('${product.pk}', this)">수정</button>
          </td>
          <td>
            <form action="/stock/delete/product" method="post" class="form-delete" onsubmit="return confirm('정말 삭제하시겠습니까?');">
              <input type="hidden" name="pk" value="${product.pk}">
              <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
              <button type="submit" class="btn btn-sm btn-danger">삭제</button>
            </form>
          </td>
        </tr>
      </c:forEach>
      <c:if test="${empty products}">
        <tr>
          <td colspan="9" class="empty-msg">
            제품 데이터가 없습니다. 상단 [등록]을 눌러 추가하세요.
          </td>
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
          <li><a href="?page=${page - 1}&size=${size}">이전</a></li>
        </c:if>
        <c:forEach var="i" begin="0" end="${totalPages - 1}">
          <li>
            <a href="?page=${i}&size=${size}" class="${i == page ? 'active' : ''}">${i + 1}</a>
          </li>
        </c:forEach>
        <c:if test="${page < totalPages - 1}">
          <li><a href="?page=${page + 1}&size=${size}">다음</a></li>
        </c:if>
      </ul>
      <span class="paging-info">총 ${totalCount}건</span>
    </c:if>
  </div>
</main>
<script>
// 등록 버튼: 등록 폼 모달 열기
function openRegister() {
  document.getElementById('registerModal').style.display = 'block';
  document.getElementById('registerForm').reset();
}
function closeRegisterModal() {
  document.getElementById('registerModal').style.display = 'none';
}
// 등록 폼 제출
function submitRegister() {
  const form = document.getElementById('registerForm');
  const formData = new FormData(form);
  const params = new URLSearchParams();
  for (const [key, value] of formData.entries()) {
    params.append(key, value);
  }
  const CSRF_HEADER = document.querySelector('meta[name="_csrf_header"]').content;
  const CSRF_TOKEN  = document.querySelector('meta[name="_csrf"]').content;
  fetch('/stock/register/product', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      [CSRF_HEADER]: CSRF_TOKEN
    },
    body: params.toString()
  })
  .then(res => res.json())
  .then(data => {
    if (data.success) {
      alert('등록되었습니다.');
      closeRegisterModal();
      location.reload();
    } else {
      alert('등록 실패: ' + (data.message || '오류'));
    }
  })
  .catch(() => {
    alert('등록 중 오류가 발생했습니다.');
  });
}
// 수정 모달 열기
function openEditModal(pk, btn) {
  let tr = btn.closest('tr');
  document.getElementById('editPk').value = pk;
  document.getElementById('editName').value = tr.children[1].innerText;
  document.getElementById('editModel').value = tr.children[2].innerText;
  document.getElementById('editSpec').value = tr.children[3].innerText;
  document.getElementById('editPrice').value = tr.children[4].innerText.replace(/,/g, '');
  document.getElementById('editStock').value = tr.children[5].innerText.replace(/,/g, '');
  document.getElementById('editAmount').value = tr.children[6].innerText.replace(/,/g, '');
  document.getElementById('editModal').style.display = 'block';
}
function closeEditModal() {
  document.getElementById('editModal').style.display = 'none';
}
// 조회 버튼: Ajax로 검색 결과를 모달에 표시
function searchData() {
  const code = document.getElementById('code').value;
  const name = document.getElementById('name').value;
  const model = document.getElementById('model').value;
  const specification = document.getElementById('specification').value;
  const params = new URLSearchParams();
  if (code) params.append('code', code);
  if (name) params.append('name', name);
  if (model) params.append('model', model);
  if (specification) params.append('specification', specification);
  fetch('/stock/search/product?' + params.toString(), {
    method: 'GET'
  })
  .then(res => res.text())
  .then(html => {
    document.getElementById('modalResultBody').innerHTML = html;
    document.getElementById('resultModal').style.display = 'block';
    bindModalDeleteButtons();
  })
  .catch(() => {
    alert('검색 중 오류가 발생했습니다.');
  });
}
// 검색 모달 닫기
function closeModal() {
  document.getElementById('resultModal').style.display = 'none';
}
// 검색 버튼 이벤트 연결
  document.addEventListener('DOMContentLoaded', function() {
    document.getElementById('btn-search').addEventListener('click', searchData);
  });
// 모달 결과 주입 뒤에 호출
function bindModalDeleteButtons() {
  const CSRF_HEADER = document.querySelector('meta[name="_csrf_header"]').content;
  const CSRF_TOKEN  = document.querySelector('meta[name="_csrf"]').content;
  document.querySelectorAll('#modalResultBody .btn-del').forEach(btn => {
    btn.addEventListener('click', function () {
      if (!confirm('정말 삭제하시겠습니까?')) return;
      const pk = this.getAttribute('data-pk');
      fetch('<c:url value="/stock/delete/product"/>', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
          [CSRF_HEADER]: CSRF_TOKEN
        },
        body: new URLSearchParams({ pk }).toString()
      }).then(res => {
        if (res.ok) {
          alert('삭제되었습니다.');
          location.reload();
        } else {
          alert('삭제 중 오류가 발생했습니다.');
        }
      });
    });
  });
}
// 검색 결과 모달에서 엑셀 다운로드
function downloadExcelFromModal() {
  const code = document.getElementById('code').value;
  const name = document.getElementById('name').value;
  const model = document.getElementById('model').value;
  const specification = document.getElementById('specification').value;
  const params = new URLSearchParams();
  if (code) params.append('code', code);
  if (name) params.append('name', name);
  if (model) params.append('model', model);
  if (specification) params.append('specification', specification);
  fetch('/stock/excel-modal/product?' + params.toString(), {
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
    a.download = 'product_Result.xlsx';
    document.body.appendChild(a);
    a.click();
    a.remove();
    window.URL.revokeObjectURL(url);
  })
  .catch(() => {
    alert('엑셀 다운로드 중 오류가 발생했습니다.');
  });
}
</script>
<style>

</style>
<%@ include file="../common/footer.jsp" %>