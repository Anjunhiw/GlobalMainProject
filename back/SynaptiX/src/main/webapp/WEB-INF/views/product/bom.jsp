<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
request.setAttribute("pageTitle", "BOM 관리");
request.setAttribute("active_product", "active");
request.setAttribute("active_bom", "active");
%>
<%@ include file="header.jsp" %>

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

  // 등록 팝업 (ID와 수량만)
  function openBomPopup() {
    var w = window.open('', 'BOM 등록', 'width=360,height=320');
    w.document.write(`
      <html><head><meta charset="UTF-8"><title>BOM 등록</title></head>
      <body>
        <h3>BOM 등록</h3>
        <form id='bomForm'>
          <label for='productId'>제품ID:</label>
          <input type='number' id='productId' name='productId' required><br/>
          <label for='materialId'>원자재ID:</label>
          <input type='number' id='materialId' name='materialId' required><br/>
          <label for='materialAmount'>필요자재량:</label>
          <input type='number' step='0.01' id='materialAmount' name='materialAmount' required><br/><br/>
          <button type='button' onclick='window.opener.submitBomForm(this.form);window.close();'>등록</button>
          <button type='button' onclick='window.close();'>취소</button>
        </form>
      </body></html>
    `);
  }

  // 등록 전송 (ID/수량만)
  function submitBomForm(form) {
    var payload = {
      productId: form.productId.value,
      materialId: form.materialId.value,
      materialAmount: form.materialAmount.value
    };
    fetch('/bom', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', [csrfHeader]: csrfToken },
      body: JSON.stringify(payload)
    }).then(r => r.ok ? (alert('등록 완료'), location.reload()) : alert('등록 실패'));
  }

  // 수정 팝업 (ID/수량만)
  function openBomEditPopup(productId, materialId, materialAmount) {
    var w = window.open('', 'BOM 수정', 'width=360,height=320');
    w.document.write(`
      <html><head><meta charset="UTF-8"><title>BOM 수정</title></head>
      <body>
        <h3>BOM 수정</h3>
        <form id='bomEditForm'>
          <label>제품ID:</label>
          <input type='number' name='productId' value='${productId}' readonly><br/>
          <label>원자재ID:</label>
          <input type='number' name='materialId' value='${materialId}' readonly><br/>
          <label>필요자재량:</label>
          <input type='number' step='0.01' name='materialAmount' value='${materialAmount}' required><br/><br/>
          <button type='button' onclick='window.opener.submitBomEditForm(this.form);window.close();'>저장</button>
          <button type='button' onclick='window.close();'>취소</button>
        </form>
      </body></html>
    `);
  }

  // 수정 전송 (ID/수량만)
  function submitBomEditForm(form) {
    var payload = {
      productId: form.productId.value,
      materialId: form.materialId.value,
      materialAmount: form.materialAmount.value
    };
    fetch('/bom', {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json', [csrfHeader]: csrfToken },
      body: JSON.stringify(payload)
    }).then(r => r.ok ? (alert('수정 완료'), location.reload()) : alert('수정 실패'));
  }
</script>

<!-- 테이블: 고유코드/수량만 표시 -->
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
      <td>${bom.productId}</td>
      <td>${bom.materialId}</td>
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
    <script>
    function openBomEditPopup(productId, materialId, materialAmount) {
        var popup = window.open('', 'BOM 수정', 'width=400,height=400');
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
                    <button type='button' onclick='window.opener.submitBomEditForm(this.form);window.close();'>수정</button>
                    <button type='button' onclick='window.close();'>취소</button>
                </form>
            </body>
            </html>
        `);
        // 팝업이 열린 후 input value를 직접 설정
        setTimeout(function() {
            if (popup.document.getElementById('productId')) {
                popup.document.getElementById('productId').value = productId;
                popup.document.getElementById('materialId').value = materialId;
                popup.document.getElementById('materialAmount').value = materialAmount;
            }
        }, 100);
        popup.document.close();
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
    </script>
<%@ include file="../common/footer.jsp" %>