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
        <option value="materials">원자재</option>
        <option value="product">제품</option>
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
	       <button type="button" class="btn btn-success" onclick="openRegister()">등록</button>
	  	</div>
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
      document.getElementById('bomResultBody').innerHTML = html;
    })
    .catch(() => {
      alert('검색 중 오류가 발생했습니다.');
    });
  }
  document.getElementById('btn-search')?.addEventListener('click', searchBom);
</script>

<!-- 등록 모달 -->
<div id="bomRegisterModal" class="modal" style="display:none;" role="dialog" aria-modal="true" aria-labelledby="bomRegisterModalTitle">
  <div class="modal-content">
    <span class="close" onclick="closeBomRegisterModal()" aria-label="닫기">&times;</span>
    <h3 id="bomRegisterModalTitle">BOM 등록</h3>
    <form id="bomRegisterForm">
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
      <div class="btn-group">
        <button type="button" class="btn btn-success" onclick="submitBomRegister()">저장</button>
        <button type="button" class="btn btn-secondary" onclick="closeBomRegisterModal()">취소</button>
      </div>
    </form>
  </div>
</div>

<!-- 검색 결과 표시 영역 -->
<div id="bomResultBody">
<!-- 기존 테이블 영역을 여기에 옮기면 Ajax로 갱신 가능 -->
<table border="1">
  <tr>
    <th>제품코드</th>
    <th>생산제품명</th>
    <th>소요원자재명</th>
    <th>소요원자재량</th>
	<th>소요금액</th>
	<th>수정</th>
  </tr>

  <c:forEach var="bom" items="${bomList}">
    <tr>
      <td>prod2025<c:choose><c:when test="${bom.productId lt 10}">0${bom.productId}</c:when><c:otherwise>${bom.productId}</c:otherwise></c:choose></td>
      <td>${bom.productName}</td>
      <td>${bom.materialName}</td>
      <td><fmt:formatNumber value="${bom.materialAmount}" type="number" maxFractionDigits="2"/></td>
      <td>
        <button type="button"
          onclick="openBomEditPopup(
            '${bom.productId}',
            '${bom.materialId}',
            '${bom.materialAmount != null ? bom.materialAmount : ''}'
          )">수정</button>
      </td>
    </tr>
  </c:forEach>

  <c:if test="${empty bomList}">
    <tr><td colspan="6	">데이터가 없습니다.</td></tr>
  </c:if>
</table>
</div>

<script>
    function openBomEditPopup(productId, materialId, materialAmount) {
        var popup = window.open('', 'BOM 수정', 'width=400,height=400');
        if (!popup) {
            alert('팝업이 차단되었습니다. 팝업 차단을 해제해주세요.');
            return;
        }
        // 팝업에 HTML만 먼저 작성
        popup.document.write(`
            <html>
            <head><title>BOM 수정</title></head>
            <body>
                <h3>BOM 수정</h3>
                <form id='bomEditForm'>
                    <label for='productId'>ProductID:</label>
                    <input type='number' id='productId' name='productId' readonly><br/>
                    <label for='materialId'>MaterialID:</label>
                    <input type='number' id='materialId' name='materialId' readonly><br/>
                    <label for='materialAmount'>MaterialAmount:</label>
                    <input type='number' step='0.01' id='materialAmount' name='materialAmount' required><br/>
                    <button type='submit' onclick='window.close();'>수정</button>
                    <button type='button' onclick='window.close();'>취소</button>
                </form>
            </body>
            </html>
        `);
        popup.document.close();
        // 폼이 완전히 로드될 때까지 폴링
        var trySetValues = function() {
            if (!popup || popup.closed) return;
            var pid = popup.document.getElementById('productId');
            var mid = popup.document.getElementById('materialId');
            var mam = popup.document.getElementById('materialAmount');
            var form = popup.document.getElementById('bomEditForm');
            if (pid && mid && mam && form) {
                pid.value = productId;
                mid.value = materialId;
                mam.value = materialAmount;
                form.onsubmit = function(e) {
                    e.preventDefault();
                    var data = {
                        productId: pid.value,
                        materialId: mid.value,
                        materialAmount: mam.value
                    };
                    fetch('/bom', {
                        method: 'PUT',
                        headers: {
                            'Content-Type': 'application/json',
                            [csrfHeader]: csrfToken
                        },
                        body: JSON.stringify(data)
                    }).then(function(res) {
                        if(res.ok) {
                            alert('수정 완료');
                            if(window.opener && !window.opener.closed) {
                                window.opener.location.reload();
                            }
                            setTimeout(function() { safeClosePopup(); }, 100);
                        } else {
                            alert('수정 실패');
                        }
                    });
                };
            } else {
                setTimeout(trySetValues, 50);
            }
        };
        trySetValues();
    }
    function submitBomEditForm(form) {
        var data = {
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
            body: JSON.stringify(data)
        }).then(res => {
            if(res.ok) {
                alert('수정 완료');
                location.reload();
            } else {
                alert('수정 실패');
            }
        });
    }
    // 안전하게 팝업을 닫는 함수 추가
    function safeClosePopup() {
        window.close();
        setTimeout(function() {
            if (!window.closed) {
                window.open('', '_self', '');
                window.close();
            }
        }, 200);
    }
    </script>
<%@ include file="../common/footer.jsp" %>