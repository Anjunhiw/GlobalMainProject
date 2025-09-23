<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"  %>
<%
request.setAttribute("active_stock", "active");
request.setAttribute("active_stl", "active");
%>
<%@ include file="../common/header.jsp" %>

<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>재고관리</title>
  
  <link rel="stylesheet" href="<c:url value='/css/stock.css?v=1'/>">

  <!-- CSRF를 JS에서 쓰기 위해 노출 -->
  <meta name="_csrf_header" content="${_csrf.headerName}">
  <meta name="_csrf"        content="${_csrf.token}">
</head>

<body>
  <h2>창고재고관리</h2>

  <div class="filters">
    <div class="field">
      <label>품목코드</label>
      <input type="text" id="code" name="code" placeholder="예: A-1001">
    </div>

    <div class="field">
      <label>품목명</label>
      <input type="text" id="name" name="name" placeholder="예: 모터">
    </div>

    <div class="field">
      <label>모델명</label>
      <input type="text" id="model" name="model" placeholder="예: MTR-200">
    </div>

    <div class="field">
      <label>카테고리</label>
      <div class="select-wrap">
        <select id="category" name="category">
          <option value="">전체</option>
          <option value="material">원자재</option>
          <option value="product">제품</option>
        </select>
      </div>
    </div>
	<div class="field grow">
	  <label>이름</label>
	  <div class="input-with-btn">
	    <input type="text" id="searchName" name="name" placeholder="이름 입력">
	    <button type="button" id="btn-search" class="btn btn-primary">검색</button>
	  </div>
	</div>
    <div class="btn-group">
      <button type="button" class="btn btn-success" onclick="openRegister()">등록</button>
      <button type="button" class="btn btn-primary" onclick="searchData()">조회</button>
    </div>
  </div>
 
	
  <!-- 검색 결과 모달 -->
  <div id="resultModal" class="modal" role="dialog" aria-modal="true" aria-labelledby="modalTitle">
    <div class="modal-content">
      <span class="close" onclick="closeModal()" aria-label="닫기">&times;</span>
      <h3 id="modalTitle">검색 결과</h3>
      <div id="modalResultBody"><!-- Ajax 결과 테이블이 여기에 표시 --></div>
    </div>
  </div>

  <!-- 등록 모달 -->
  <div id="registerModal" class="modal" style="display:none;" role="dialog" aria-modal="true" aria-labelledby="registerModalTitle">
    <div class="modal-content">
      <span class="close" onclick="closeRegisterModal()" aria-label="닫기">&times;</span>
      <h3 id="registerModalTitle">원자재/제품 등록</h3>
      <form id="registerForm">
        <div class="field">
          <label>카테고리</label>
          <select id="regCategory" name="category" required onchange="toggleRegisterFields()">
            <option value="material">원자재</option>
            <option value="product">제품</option>
          </select>
        </div>
        <div class="field">
          <label>품목명</label>
          <input type="text" id="regName" name="name" required>
        </div>
        <div class="field product-only" style="display:none;">
          <label>모델명</label>
          <input type="text" id="regModel" name="model">
        </div>
        <div class="field">
          <label>규격</label>
          <input type="text" id="regSpec" name="specification">
        </div>
        <div class="field material-only">
          <label>단위</label>
          <input type="text" id="regUnit" name="unit">
        </div>
        <div class="field">
          <label>단가</label>
          <input type="number" id="regPrice" name="price" required>
        </div>
        <div class="field">
          <label>재고수량</label>
          <input type="number" id="regStock" name="stock" min="0" value="0" required>
        </div>
        <div class="field">
          <label>재고금액</label>
          <input type="number" id="regAmount" name="amount" min="0" value="0" required>
        </div>
        <div class="btn-group">
          <button type="button" class="btn btn-success" onclick="submitRegister()">저장</button>
          <button type="button" class="btn btn-secondary" onclick="closeRegisterModal()">취소</button>
        </div>
      </form>
    </div>
  </div>

  <h2>원자재 재고 목록</h2>
  <table>
    <thead>
      <tr>
        <th>품목코드</th><th>품목명</th><th>카테고리</th><th>규격</th><th>단위</th>
        <th>단가</th><th>재고수량</th><th>재고금액</th><th>관리</th><th>품목수정</th><th>품목삭제</th>
      </tr>
    </thead>
	<tbody>
	<c:forEach var="material" items="${materials}">
	    <tr>
	      <td>mtr2025<c:choose><c:when test="${material.pk lt 10}">0${material.pk}</c:when><c:otherwise>${material.pk}</c:otherwise></c:choose></td>
	      <td>${material.name}</td>
	      <td>${material.category}</td>
	      <td>${material.specification}</td>
	      <td>${material.unit}</td>
	      <td><fmt:formatNumber value="${material.price}"  type="number" groupingUsed="true"/></td>
	      <td><fmt:formatNumber value="${material.stock}"  type="number" maxFractionDigits="0" groupingUsed="true"/></td>
	      <td><fmt:formatNumber value="${material.amount}" type="number" maxFractionDigits="0" groupingUsed="true"/></td>
	      <td><span class="muted">-</span></td>
	      <td>
	        <form action="/stock/edit" method="get">
	          <input type="hidden" name="pk" value="${material.pk}">
	          <input type="hidden" name="category" value="material">
	          <button type="submit" class="btn btn-sm btn-warning">수정</button>
	        </form>
	      </td> 
	      <td>
	        <form action="/stock/delete" method="post" onsubmit="return confirm('정말 삭제하시겠습니까?');">
	          <input type="hidden" name="pk" value="${material.pk}">
	          <input type="hidden" name="category" value="material">
	          <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
	          <button type="submit" class="btn btn-sm btn-danger">삭제</button>
	        </form>
	      </td>
	    </tr>
	</c:forEach>	  
	<c:if test="${empty materials}">
	    <!-- 샘플/플레이스홀더 2줄 -->
	    <c:forEach begin="1" end="2">
	      <tr class="placeholder">
	        <td>—</td>
	        <td>materials</td>
	        <td>샘플 원자재</td>
	        <td>규격</td>
	        <td>EA</td>
	        <td>0</td>
	        <td>0</td>
	        <td>0</td>
	        <!-- 관리 -->
	        <td><span class="muted">-</span></td>
	        <!-- 품목수정 -->
	        <td><button type="button" class="btn btn-sm btn-warning" disabled>수정</button></td>
	        <!-- 품목삭제 -->
	        <td><button type="button" class="btn btn-sm btn-danger"  disabled>삭제</button></td>
	      </tr>
	    </c:forEach>

	    <!-- 안내 문구 행 (11칸 맞춤) -->
	    <tr>
	      <td colspan="11" class="empty-msg">원자재 데이터가 없습니다. 상단 [등록]을 눌러 추가하세요.</td>
	    </tr>
	  </c:if>
	</tbody>

  </table>

  <h2>제품 재고 목록</h2>
  
  
  
 
  <table>
    <thead>
      <tr>
        <th>품목코드</th><th>카테고리</th><th>제품명</th><th>모델명</th><th>규격</th>
        <th>단가</th><th>재고량</th><th>재고금액</th><th>관리</th><th>품목수정</th><th>품목삭제</th>
      </tr>
    </thead>
	<tbody>
	<c:forEach var="product" items="${products}">
	    <tr>
	      <td>prod2025<c:choose><c:when test="${product.pk lt 10}">0${product.pk}</c:when><c:otherwise>${product.pk}</c:otherwise></c:choose></td>
	      <td>${product.category}</td>
	      <td>${product.name}</td>
	      <td>${product.model}</td>
	      <td>${product.specification}</td>
	      <td><fmt:formatNumber value="${product.price}"  type="number" groupingUsed="true"/></td>
	      <td><fmt:formatNumber value="${product.stock}"  type="number" maxFractionDigits="0" groupingUsed="true"/></td>
	      <td><fmt:formatNumber value="${product.amount}" type="number" maxFractionDigits="0" groupingUsed="true"/></td>
	      <td><span class="muted">-</span></td>
	      <td>
	        <form action="/stock/edit" method="get">
	          <input type="hidden" name="pk" value="${product.pk}">
	          <input type="hidden" name="category" value="product">
	          <button type="submit" class="btn btn-sm btn-warning">수정</button>
	        </form>
	      </td>
	      <td>
	        <form action="/stock/delete" method="post" onsubmit="return confirm('정말 삭제하시겠습니까?');">
	          <input type="hidden" name="pk" value="${product.pk}">
	          <input type="hidden" name="category" value="product">
	          <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
	          <button type="submit" class="btn btn-sm btn-danger">삭제</button>
	        </form>
	      </td>
	    </tr>
	  </c:forEach>



	  <c:if test="${empty products}">
	    <tr><td colspan="11">제품 데이터가 없습니다.</td></tr>
	  </c:if>
	</tbody>

  </table>
  <!-- stock.jsp 하단 script 일부만 발췌/수정 -->
  <script>
    // 등록 버튼: 등록 폼 페이지로 이동
    function openRegister() {
      document.getElementById('registerModal').style.display = 'block';
      document.getElementById('registerForm').reset();
      toggleRegisterFields();
    }
    // 등록 모달 닫기
    function closeRegisterModal() {
      document.getElementById('registerModal').style.display = 'none';
    }
    // 카테고리 선택에 따라 입력 필드 표시
    function toggleRegisterFields() {
      const cat = document.getElementById('regCategory').value;
      document.querySelectorAll('.product-only').forEach(e => e.style.display = (cat === 'product' ? '' : 'none'));
      document.querySelectorAll('.material-only').forEach(e => e.style.display = (cat === 'material' ? '' : 'none'));
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
      fetch('/stock/register', {
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

    // 검색/조회 버튼: Ajax로 검색 결과를 모달에 표시
    function searchData() {
      const code = document.getElementById('code').value;
      const name = document.getElementById('name').value;
      const model = document.getElementById('model').value;
      const category = document.getElementById('category').value;
      const searchName = document.getElementById('searchName').value;
      const CSRF_HEADER = document.querySelector('meta[name="_csrf_header"]').content;
      const CSRF_TOKEN  = document.querySelector('meta[name="_csrf"]').content;

      const params = new URLSearchParams();
      if (code) params.append('code', code);
      if (name) params.append('name', name);
      if (model) params.append('model', model);
      if (category) params.append('category', category);
      if (searchName) params.append('searchName', searchName);

      fetch('/stock/search', {
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
	      const category = this.getAttribute('data-category');

	      const params = new URLSearchParams();
	      params.append('pk', pk);
	      params.append('category', category);

	      fetch('<c:url value="/stock/delete"/>', {
	        method: 'POST',
	        headers: {
	          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
	          [CSRF_HEADER]: CSRF_TOKEN
	        },
	        body: params.toString()
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

  </script>
<%@ include file="../common/footer.jsp" %>