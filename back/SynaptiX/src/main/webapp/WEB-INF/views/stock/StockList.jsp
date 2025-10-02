<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"  %>
<%
request.setAttribute("active_stock", "active");
request.setAttribute("active_stl", "active");
%>
<%@ include file="../common/header.jsp" %>

  <link rel="stylesheet" href="<c:url value='/css/stock.css?v=1'/>">
  <link rel="stylesheet" href="<c:url value='/css/bom.css?v=1'/>">

  <!-- CSRF를 JS에서 쓰기 위해 노출 -->
  <meta name="_csrf_header" content="${_csrf.headerName}">
  <meta name="_csrf"        content="${_csrf.token}">


  <h2>창고재고관리</h2>

  <div class="filter-smallb">
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
          <option value="원자재">원자재</option>
          <option value="제품">제품</option>
        </select>
      </div>
    </div>
	<div class="field grow">
	  <label>이름</label>
	  <div class="input-with-btn">
	    <input type="text" id="searchName" name="name" placeholder="이름 입력">
	  </div>
	</div>
    <div class="btn-group">
      <button type="button" class="btn btn-ee" onclick="openRegister()">등록</button>
      <button type="button" class="btn btn-primary" id="btn-search" onclick="searchData()">조회</button>
		<button type=button class="btn btn-success">엑셀 다운로드</button>
	  </a>
    </div>
  </div>
 
	
  <!-- 검색 결과 모달 -->
  <div id="resultModal" class="modal" role="dialog" aria-modal="true" aria-labelledby="modalTitle">
    <div class="modal-content">
      <span class="close" onclick="closeModal()" aria-label="닫기">&times;</span>
      <h3 id="modalTitle">검색 결과</h3>
	  <div style="text-align:right; margin-top:10px;">
        <button type="button" class="btn btn-success" style="float:right; margin-bottom:10px;" onclick="downloadExcelFromModal()">엑셀 다운로드</button>
      </div>
      <div id="modalResultBody"><!-- Ajax 결과 테이블이 여기에 표시 --></div>
      
    </div>
  </div>

  <!-- 등록 모달 -->
  <div id="registerModal" class="modal" role="dialog" aria-modal="true" aria-labelledby="registerModalTitle">
    <div class="modal-content">
      <span class="close" onclick="closeRegisterModal()" aria-label="닫기">&times;</span>
      <h3 id="registerModalTitle">품목등록</h3>
      <form id="registerForm" class="form-rows">
	        
	        <div class="field">
	          <label for="regCategory" class="label">품목등록</label>
	          <div class="control">
	            <select id="regCategory" name="category" required onchange="toggleRegisterFields()">
	              <option value="원자재">원자재</option>
	              <option value="제품">제품</option>
	            </select>
	          </div>
	        </div>

			<div class="field">
			     <label for="regName" class="label">품목명</label>
			     <div class="control">
			       <input type="text" id="regName" name="name" required />
			     </div>
			   </div>
			
	        <!-- 제품에서만 보이는 모델명 -->
	        <div class="field product-only" style="display:none;">
	          <label for="regModel" class="label">모델명</label>
	          <div class="control">
	            <input type="text" id="regModel" name="model" />
	          </div>
	        </div>

	        <!-- 공통 -->
	        <div class="field">
	          <label for="regSpec" class="label">규격</label>
	          <div class="control">
	            <input type="text" id="regSpec" name="specification" />
	          </div>
	        </div>
				
	        <!-- 원자재에서만 보이는 단위 -->
	        <div class="field material-only">
	          <label for="regUnit" class="label">단위</label>
	          <div class="control narrow">
	            <input type="text" id="regUnit" name="unit" />
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

	        <!-- 버튼 영역: 가운데, 초록색 알약 버튼 -->
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
      <h3 id="editModalTitle">품목수정</h3>
      <form id="editForm" class="form-rows" method="post" action="/stock/edit">
        <input type="hidden" id="editPk" name="pk" />
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
        <div class="field">
          <label for="editCategory" class="label">카테고리</label>
          <div class="control">
            <select id="editCategory" name="category" required onchange="toggleEditFields()">
              <option value="원자재">원자재</option>
              <option value="제품">제품</option>
            </select>
          </div>
        </div>
        <div class="field">
          <label for="editName" class="label">품목명</label>
          <div class="control">
            <input type="text" id="editName" name="name" required />
          </div>
        </div>
        <div class="field product-only-edit" style="display:none;">
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
        <div class="field material-only-edit">
          <label for="editUnit" class="label">단위</label>
          <div class="control narrow">
            <input type="text" id="editUnit" name="unit" />
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
        <button type="button" class="btn btn-sm btn-warning" onclick="openEditModal('${material.pk}', '원자재', this)">수정</button>
      </td> 
	      <td> 
	        <form action="/stock/delete" method="post" class="form-delete" onsubmit="return confirm('정말 삭제하시겠습니까?');">
                <input type="hidden" name="pk" value="${material.pk}">
                <input type="hidden" name="category" value="원자재">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
				<button type="submit" class="btn btn-sm btn-danger">삭제</button>	
	        </form>
	      </td>
	    </tr>
	</c:forEach>	  
	<c:if test="${empty materials}">
	  <tr>
	    <td colspan="11" class="empty-msg">
	      원자재 데이터가 없습니다. 상단 [등록]을 눌러 추가하세요.
	    </td>
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
        <button type="button" class="btn btn-sm btn-warning" onclick="openEditModal('${product.pk}', '제품', this)">수정</button>
      </td>
	      <td>
	          <input type="hidden" name="pk" value="${product.pk}">
	          <input type="hidden" name="category" value="product">
	          <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
	          <form action="/stock/delete" method="post" class="form-delete" onsubmit="return confirm('정말 삭제하시겠습니까?');">
                <button type="submit" class="btn btn-sm btn-danger">삭제</button>
	        </form>
	      </td>
	    </tr>
	  </c:forEach>



	  <c:if test="${empty products}">
	    <tr><td colspan="11">제품 데이터가 없습니다.</td></tr>
	  </c:if>
</table>
</tbody>
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
      document.querySelectorAll('.product-only').forEach(e => e.style.display = (cat === '제품' ? '' : 'none'));
      document.querySelectorAll('.material-only').forEach(e => e.style.display = (cat === '원자재' ? '' : 'none'));
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

    // 수정 모달 열기
    function openEditModal(pk, category, btn) {
      // 테이블에서 데이터 추출
      let tr = btn.closest('tr');
      document.getElementById('editPk').value = pk;
      document.getElementById('editCategory').value = category;
      document.getElementById('editName').value = tr.children[1].innerText;
      if (category === '제품') {
        document.getElementById('editModel').value = tr.children[3].innerText;
        document.querySelector('.product-only-edit').style.display = '';
        document.querySelector('.material-only-edit').style.display = 'none';
      } else {
        document.getElementById('editModel').value = '';
        document.querySelector('.product-only-edit').style.display = 'none';
        document.querySelector('.material-only-edit').style.display = '';
      }
      document.getElementById('editSpec').value = tr.children[4].innerText;
      document.getElementById('editUnit').value = (category === '원자재') ? tr.children[4].nextElementSibling.innerText : '';
      document.getElementById('editPrice').value = tr.children[5].innerText.replace(/,/g, '');
      document.getElementById('editStock').value = tr.children[6].innerText.replace(/,/g, '');
      document.getElementById('editAmount').value = tr.children[7].innerText.replace(/,/g, '');
      document.getElementById('editModal').style.display = 'block';
    }
    function closeEditModal() {
      document.getElementById('editModal').style.display = 'none';
    }
    function toggleEditFields() {
      const cat = document.getElementById('editCategory').value;
      document.querySelector('.product-only-edit').style.display = (cat === '제품' ? '' : 'none');
      document.querySelector('.material-only-edit').style.display = (cat === '원자재' ? '' : 'none');
    }

    // 검색/조회 버튼: Ajax로 검색 결과를 모달에 표시
    function searchData() {
      const code = document.getElementById('code').value;
      const name = document.getElementById('name').value;
      const model = document.getElementById('model').value;
      const category = document.getElementById('category').value;
      const searchName = document.getElementById('searchName').value;
      // GET 방식으로 파라미터를 쿼리스트링으로 조합
      const params = new URLSearchParams();
      if (code) params.append('code', code);
      if (name) params.append('name', name);
      if (model) params.append('model', model);
      if (category) params.append('category', category);
      if (searchName) params.append('searchName', searchName);
      const url = '/stock/search?' + params.toString();
      fetch(url, {
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

    // 첫페이지 엑셀 다운로드 (GET 방식)
    function downloadStockExcel() {
      const code = document.getElementById('code').value;
      const name = document.getElementById('name').value;
      const model = document.getElementById('model').value;
      const category = document.getElementById('category').value;
      const searchName = document.getElementById('searchName').value;
      const params = new URLSearchParams();
      if (code) params.append('code', code);
      if (name) params.append('name', name);
      if (model) params.append('model', model);
      if (category) params.append('category', category);
      if (searchName) params.append('searchName', searchName);
      const url = '/stock/excel?' + params.toString();
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
        a.download = '재고목록.xlsx';
        document.body.appendChild(a);
        a.click();
        a.remove();
        window.URL.revokeObjectURL(url);
      })
      .catch(() => {
        alert('엑셀 다운로드 중 오류가 발생했습니다.');
      });
    }

    // btn-group에 엑셀 다운로드 버튼 이벤트 연결
    document.addEventListener('DOMContentLoaded', function() {
      document.querySelector('.btn-group .btn-success').addEventListener('click', downloadStockExcel);
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

    // 검색 결과 모달에서 엑셀 다운로드
    function downloadExcelFromModal() {
      const code = document.getElementById('code').value;
      const name = document.getElementById('name').value;
      const model = document.getElementById('model').value;
      const category = document.getElementById('category').value;
      const searchName = document.getElementById('searchName').value;
      // GET 방식으로 파라미터를 쿼리스트링으로 조합
      const params = new URLSearchParams();
      if (code) params.append('code', code);
      if (name) params.append('name', name);
      if (model) params.append('model', model);
      if (category) params.append('category', category);
      if (searchName) params.append('searchName', searchName);
      const url = '/stock/excel-modal?' + params.toString();
      // GET 방식으로 fetch
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
        a.download = '검색결과.xlsx';
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
<%@ include file="../common/footer.jsp" %>