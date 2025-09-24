<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
request.setAttribute("pageTitle", "MRP");
request.setAttribute("active_purchase", "active");
request.setAttribute("active_mrp", "active");
%>
<%@ include file="../common/header.jsp" %>
<link rel="stylesheet" href="<c:url value='/css/stock.css?v=1'/>">
<link rel="stylesheet" href="<c:url value='/css/bom.css?v=1'/>">
<body>
  <h2>MRP</h2>

  <!-- 검색 영역 -->
  <div class="filter-small">
    <div class="field">
      <label>제품코드</label>
      <input type="text" id="prodCode" name="prodCode"
             placeholder="예: P-1001" value="${param.prodCode}">
    </div>

    <div class="field">
      <label>제품명</label>
      <input type="text" id="prodName" name="prodName"
             placeholder="예: 완제품A" value="${param.prodName}">
    </div>

    <div class="field">
      <label>입고일자</label>
      <input type="date" id="inDate" name="inDate" value="${param.inDate}">
    </div>

    <div class="field">
      <label>MRP상태</label>
      <div class="select-wrap">
        <select id="mrpStatus" name="mrpStatus">
          <option value=""      ${empty param.mrpStatus ? 'selected' : ''}>전체</option>
          <option value="PLAN"  ${param.mrpStatus == 'PLAN'  ? 'selected' : ''}>계획</option>
          <option value="NEED"  ${param.mrpStatus == 'NEED'  ? 'selected' : ''}>부족</option>
          <option value="OK"    ${param.mrpStatus == 'OK'    ? 'selected' : ''}>충분</option>
        </select>
      </div>
    </div>

    <div class="btn-group">
      <button type="button" id="btnSearch" class="btn btn-primary">조회</button>
    </div>
  </div>

  <!-- 결과 테이블 -->
  <h2>재고 계획 현황</h2>
  <table class="table">
    <thead>
      <tr>
        <th>제품명</th>
        <th>필요 원자재</th>
        <th>필요량</th>
        <th>현재재고</th>
        <th>추가재고필요량</th>
        <th>계획일자</th>
      </tr>
    </thead>
    <tbody>
      <!-- mrps: 서버에서 내려주는 리스트 -->
      <!-- 예시 DTO 필드: productName, materialName, requiredQty, currentStock, shortageQty, planDate -->
      <c:forEach var="m" items="${mrps}">
        <tr>
          <td>${m.productName}</td>
          <td>${m.materialName}</td>
          <td class="text-right"><fmt:formatNumber value="${m.requiredQty}" type="number" maxFractionDigits="0"/></td>
          <td class="text-right"><fmt:formatNumber value="${m.currentStock}" type="number" maxFractionDigits="0"/></td>
          <td class="text-right">
            <fmt:formatNumber value="${m.shortageQty}" type="number" maxFractionDigits="0"/>
          </td>
          <td><fmt:formatDate value="${m.planDate}" pattern="yyyy-MM-dd"/></td>
        </tr>
      </c:forEach>

      <c:if test="${empty mrps}">
        <tr><td colspan="6" style="text-align:center;">표시할 MRP 데이터가 없습니다.</td></tr>
      </c:if>
    </tbody>
  </table>

  <script>
    // 조회 버튼: GET 파라미터로 필터 전달
    document.getElementById('btnSearch')?.addEventListener('click', () => {
      const p = new URLSearchParams({
        prodCode  : document.getElementById('prodCode').value || '',
        prodName  : document.getElementById('prodName').value || '',
        inDate    : document.getElementById('inDate').value   || '',
        mrpStatus : document.getElementById('mrpStatus').value || ''
      });
      location.href = '/mrp?' + p.toString();   // 컨트롤러 매핑에 맞춰 경로 수정
    });
  </script>
</body>
</html>
<%@ include file="../common/footer.jsp" %>