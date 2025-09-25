<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="csrfParameterName" value="${_csrf.parameterName}" />
<c:set var="csrfToken" value="${_csrf.token}" />
<%
request.setAttribute("pageTitle", "MPS관리");
request.setAttribute("active_product", "active");
request.setAttribute("active_mps", "active");
%>
<%@ include file="../common/header.jsp" %>

<link rel="stylesheet" href="<c:url value='/css/stock.css?v=1'/>">
<link rel="stylesheet" href="<c:url value='/css/bom.css?v=1'/>">

<body>
  <h2>MPS</h2>
  <!-- 상단 검색/입력 필터 -->
  <div class="filter-small">
    <div class="field">
      <label>제품코드</label>
      <input type="text" id="prodCode" placeholder="예: P-1001">
    </div>
    <div class="field">
      <label>제품명</label>
      <input type="text" id="prodName" placeholder="예: 전동드릴">
    </div>
    <div class="btn-groups">
      <button type="button" class="btn btn-success" id="openRegisterModal">등록</button>
      <button type="button" class="btn btn-primary" id="openSearchModal">조회</button>
    </div>
  </div>

  <!-- 등록 모달 -->
  <div id="registerMpsModal" class="modal" style="display:none; position:fixed; top:0; left:0; width:100vw; height:100vh; background:rgba(0,0,0,0.3); z-index:9999; align-items:center; justify-content:center;">
    <div style="background:#fff; padding:30px; border-radius:8px; min-width:350px; position:relative;">
      <h4>MPS 등록</h4>
      <form id="registerMpsForm">
        <div class="field">
          <label>제품ID</label>
          <input type="number" name="ProductId" id="registerProductId" required>
        </div>
        <div class="field">
          <label>기간(종료날짜)</label>
          <input type="date" name="Period" id="registerPeriod" required>
        </div>
        <div class="field">
          <label>생산량</label>
          <input type="number" name="Volume" id="registerVolume" min="0" required>
        </div>
        <div class="btn-groups" style="margin-top:15px;">
          <button type="submit" class="btn btn-success">등록</button>
          <button type="button" class="btn btn-secondary" id="closeRegisterModal">취소</button>
        </div>
      </form>
    </div>
  </div>

  <!-- 조회 모달 -->
  <div id="searchMpsModal" class="modal" style="display:none; position:fixed; top:0; left:0; width:100vw; height:100vh; background:rgba(0,0,0,0.3); z-index:9999; align-items:center; justify-content:center;">
    <div style="background:#fff; padding:30px; border-radius:8px; min-width:500px; position:relative; max-height:80vh; overflow:auto;">
      <h4>MPS 조회 결과</h4>
      <div id="searchMpsResult">
        <!-- 검색 결과 테이블이 여기에 동적으로 렌더링됩니다. -->
      </div>
      <div class="btn-groups" style="margin-top:15px;">
        <button type="button" class="btn btn-secondary" id="closeSearchModal">닫기</button>
      </div>
    </div>
  </div>

  <h2>생산 계획 리스트</h2>

  <table class="table">
    <thead>
      <tr>
        <th>제품코드</th>
        <th>제품명</th>
        <th>생산량</th>
        <th>기간(종료날짜)</th>
        <th>생산금액</th>
        <th>수정</th>
      </tr>
    </thead>
	<tbody>
	    <c:forEach var="plan" items="${list}">
	      <tr data-pk="${plan.pk}" data-productid="${plan.productId}" data-productname="${plan.productName}" data-volume="${plan.volume}" data-period="${plan.period}" data-price="${plan.price}">
	        <td>prod2025<c:choose><c:when test="${plan.productId lt 10}">0${plan.productId}</c:when><c:otherwise>${plan.productId}</c:otherwise></c:choose></td>
	        <td>${plan.productName}</td>
	        <td><fmt:formatNumber value="${plan.volume}" type="number" maxFractionDigits="0"/></td>
	        <td>${plan.period}</td>
	        <td><fmt:formatNumber value="${plan.price * plan.volume}" type="number" groupingUsed="true"/></td>
	        <td>
	          <button type="button" class="btn btn-sm btn-warning btn-edit">수정</button>
	        </td>
	      </tr>
	    </c:forEach>

	    <c:if test="${empty list}">
	      <tr>
	        <td colspan="6" style="text-align:center;">생산 계획 데이터가 없습니다.</td>
	      </tr>
	    </c:if>
	  </tbody>
  </table>

  <!-- MPS 수정 모달 -->
  <div id="editMpsModal" class="modal" style="display:none; position:fixed; top:0; left:0; width:100vw; height:100vh; background:rgba(0,0,0,0.3); z-index:9999; align-items:center; justify-content:center;">
    <div style="background:#fff; padding:30px; border-radius:8px; min-width:350px; position:relative;">
      <h4>MPS 수정</h4>
      <form id="editMpsForm">
        <input type="hidden" name="pk" id="editPk">
        <div class="field">
          <label>제품ID</label>
          <input type="number" name="ProductId" id="editProductId" required>
        </div>
        <div class="field">
          <label>기간(종료날짜)</label>
          <input type="date" name="Period" id="editPeriod" required>
        </div>
        <div class="field">
          <label>생산량</label>
          <input type="number" name="Volume" id="editVolume" min="0" required>
        </div>
        <div class="btn-groups" style="margin-top:15px;">
          <button type="submit" class="btn btn-primary">수정</button>
          <button type="button" class="btn btn-secondary" id="closeEditModal">취소</button>
        </div>
      </form>
    </div>
  </div>

  <script>
    // 모달 열기/닫기 함수
    function openEditModal(data) {
      document.getElementById('editPk').value = data.pk;
      document.getElementById('editProductId').value = data.ProductId !== undefined ? Number(data.ProductId) : '';
      document.getElementById('editPeriod').value = data.Period || '';
      document.getElementById('editVolume').value = data.Volume !== undefined ? Number(data.Volume) : '';
      document.getElementById('editMpsModal').style.display = 'flex';
    }
    function closeEditModal() {
      document.getElementById('editMpsModal').style.display = 'none';
    }
    document.getElementById('closeEditModal').onclick = closeEditModal;

    // 등록 모달 열기/닫기
    document.getElementById('openRegisterModal').onclick = function() {
      document.getElementById('registerMpsModal').style.display = 'flex';
    };
    document.getElementById('closeRegisterModal').onclick = function() {
      document.getElementById('registerMpsModal').style.display = 'none';
    };

    // 조회 모달 열기/닫기
    document.getElementById('openSearchModal').onclick = function() {
      // 입력폼에서 값 읽기
      var prodCode = document.getElementById('prodCode').value;
      var prodName = document.getElementById('prodName').value;
      // AJAX로 검색 요청
      fetch('/mps/search?prodCode=' + encodeURIComponent(prodCode) + '&prodName=' + encodeURIComponent(prodName))
        .then(res => res.json())
        .then(data => {
          var html = '';
          if(data && data.length > 0) {
            html += '<table class="table"><thead><tr>';
            html += '<th>제품코드</th><th>제품명</th><th>생산량</th><th>기간(종료날짜)</th><th>생산금액</th>';
            html += '</tr></thead><tbody>';
            data.forEach(function(plan) {
              html += '<tr>';
              html += '<td>prod2025' + (plan.productId < 10 ? '0' + plan.productId : plan.productId) + '</td>';
              html += '<td>' + plan.productName + '</td>';
              html += '<td>' + plan.volume + '</td>';
              html += '<td>' + plan.period + '</td>';
              html += '<td>' + (plan.price * plan.volume).toLocaleString() + '</td>';
              html += '</tr>';
            });
            html += '</tbody></table>';
          } else {
            html = '<div style="text-align:center; padding:30px;">검색 결과가 없습니다.</div>';
          }
          document.getElementById('searchMpsResult').innerHTML = html;
          document.getElementById('searchMpsModal').style.display = 'flex';
        })
        .catch(() => {
          document.getElementById('searchMpsResult').innerHTML = '<div style="text-align:center; padding:30px; color:red;">검색 중 오류 발생</div>';
          document.getElementById('searchMpsModal').style.display = 'flex';
        });
    };
    document.getElementById('closeSearchModal').onclick = function() {
      document.getElementById('searchMpsModal').style.display = 'none';
    };

    // 수정 버튼 이벤트
    document.querySelectorAll('.btn-edit').forEach(function(btn) {
      btn.onclick = function() {
        var tr = btn.closest('tr');
        openEditModal({
          pk: tr.getAttribute('data-pk'),
          ProductId: tr.getAttribute('data-productid'),
          Period: tr.getAttribute('data-period'),
          Volume: tr.getAttribute('data-volume')
        });
      };
    });

    // 등록 폼 제출
    document.getElementById('registerMpsForm').onsubmit = function(e) {
      e.preventDefault();
      var form = e.target;
      var ProductId = form.querySelector('[name="ProductId"]').value;
      var Period = form.querySelector('[name="Period"]').value;
      var Volume = form.querySelector('[name="Volume"]').value;
      if(!ProductId || !Period || !Volume) {
        alert('모든 값을 입력해 주세요.');
        return;
      }
      var formData = new FormData();
      formData.append('ProductId', ProductId);
      formData.append('Period', Period);
      formData.append('Volume', Volume);
      formData.append('${csrfParameterName}', '${csrfToken}');
      fetch('/mps', {
        method: 'POST',
        body: formData
      })
      .then(res => res.json())
      .then(data => {
        if(data.success) {
          alert('등록되었습니다.');
          location.reload();
        } else {
          alert('등록 실패: ' + (data.message || '오류'));
        }
      })
      .catch(() => alert('등록 중 오류 발생'));
    };

    // 폼 제출(수정)
    document.getElementById('editMpsForm').onsubmit = function(e) {
      e.preventDefault();
      var form = e.target;
      // 값 체크
      var pk = form.querySelector('[name="pk"]').value;
      var ProductId = form.querySelector('[name="ProductId"]').value;
      var Period = form.querySelector('[name="Period"]').value;
      var Volume = form.querySelector('[name="Volume"]').value;
      if(!pk || !ProductId || !Period || !Volume) {
        alert('모든 값을 입력해 주세요.');
        return;
      }
      var formData = new FormData(form);
      // 디버깅: FormData 값 출력
      for (var pair of formData.entries()) {
        console.log(pair[0]+ ': ' + pair[1]);
      }
      // CSRF 토큰 추가
      formData.append('${csrfParameterName}', '${csrfToken}');
      fetch('/mps/edit', {
        method: 'POST',
        body: formData
      })
      .then(res => res.json())
      .then(data => {
        if(data.success) {
          alert('수정되었습니다.');
          location.reload();
        } else {
          alert('수정 실패: ' + (data.message || '오류'));
        }
      })
      .catch(() => alert('수정 중 오류 발생'));
    };
  </script>
</body>
</html>
<%@ include file="../common/footer.jsp" %>