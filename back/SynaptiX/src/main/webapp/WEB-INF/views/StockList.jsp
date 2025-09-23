<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"  %>
<% request.setAttribute("active_stock", "active"); %>

<%@ include file="common/header.jsp" %>

  <link rel="stylesheet" href="<c:url value='/css/stock.css?v=1'/>">

  <!-- CSRF를 JS에서 쓰기 위해 노출 -->
  <meta name="_csrf_header" content="${_csrf.headerName}">
  <meta name="_csrf"        content="${_csrf.token}">

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
          <option value="materials">원자재</option>
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

  <h2>원자재 재고 목록</h2>
  <table>
    <thead>
      <tr>
        <th>품목코드</th><th>품목명</th><th>원자재명</th><th>규격</th><th>단위</th>
        <th>단가</th><th>재고수량</th><th>재고금액</th><th>관리</th><th>품목수정</th><th>품목삭제</th>
      </tr>
    </thead>
	<tbody>
<!-- <c:forEach var="material" items="${materials}">
	    <tr>
	      <td>${material.pk}</td>
	      <td>${material.name}</td>
	      <td>${material.category}</td>
	      <td>${material.specification}</td>
	      <td>${material.unit}</td>
	      <td><fmt:formatNumber value="${material.price}"  type="number" groupingUsed="true"/></td>
	      <td><fmt:formatNumber value="${material.stock}"  type="number" maxFractionDigits="0" groupingUsed="true"/></td>
	      <td><fmt:formatNumber value="${material.amount}" type="number" maxFractionDigits="0" groupingUsed="true"/></td>

	       관리 
	      <td><span class="muted">-</span></td>

	       품목수정 
	      <td>
	        <form action="/stock/edit" method="get">
	          <input type="hidden" name="pk" value="${material.pk}">
	          <input type="hidden" name="category" value="material">
	          <button type="submit" class="btn btn-sm btn-warning">수정</button>
	        </form>
	      </td>

	       품목삭제 
	      <td>
	        <form action="/stock/delete" method="post" onsubmit="return confirm('정말 삭제하시겠습니까?');">
	          <input type="hidden" name="pk" value="${material.pk}">
	          <input type="hidden" name="category" value="material">
	          <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
	          <button type="submit" class="btn btn-sm btn-danger">삭제</button>
	        </form>
	      </td>
	    </tr>
	  </c:forEach>-->
	  
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

	 	    
	  <c:if test="${empty materials}">
	    <tr><td colspan="11">원자재 데이터가 없습니다.</td></tr>
	  </c:if>
	</tbody>

  </table>

  <h2>제품 재고 목록</h2>
  
  
  
 
  <table>
    <thead>
      <tr>
        <th>PK</th><th>카테고리</th><th>제품명</th><th>모델명</th><th>규격</th>
        <th>단가</th><th>재고량</th><th>재고금액</th><th>관리</th><th>품목수정</th><th>품목삭제</th>
      </tr>
    </thead>
	<tbody>
	<c:forEach var="product" items="${products}">
	    <tr>
	      <td>${product.pk}</td>
	      <td>${product.category}</td>
	      <td>${product.name}</td>
	      <td>${product.model}</td>
	      <td>${product.specification}</td>
	      <td><fmt:formatNumber value="${product.price}"  type="number" groupingUsed="true"/></td>
	      <td><fmt:formatNumber value="${product.stock}"  type="number" maxFractionDigits="0" groupingUsed="true"/></td>
	      <td><fmt:formatNumber value="${product.amount}" type="number" maxFractionDigits="0" groupingUsed="true"/></td>

	       관리 
	      <td><span class="muted">-</span></td>

	       품목수정 
	      <td>
	        <form action="/stock/edit" method="get">
	          <input type="hidden" name="pk" value="${product.pk}">
	          <input type="hidden" name="category" value="product">
	          <button type="submit" class="btn btn-sm btn-warning">수정</button>
	        </form>
	      </td>

		               품목삭제 
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

</body>
</html>