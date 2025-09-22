<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
request.setAttribute("pageTitle", "판매출고");
request.setAttribute("active_sales", "active");
request.setAttribute("active_sale", "active");
%>
<%@ include file="../common/header.jsp" %>
<link rel="stylesheet" href="<c:url value='/css/stock.css?v=1'/>">
<link rel="stylesheet" href="<c:url value='/css/bom.css?v=1'/>">

<body>

  <h2>판매/출고</h2>

  <!-- 상단 검색 필터 -->
  <div class="filter-small">
    <div class="field">
      <label>제품코드</label>
      <input type="text" id="code" name="code" placeholder="예: P-1001">
    </div>

    <div class="field">
      <label>제품명</label>
      <input type="text" id="name" name="name" placeholder="예: 전동드릴">
    </div>

    <div class="field">
      <label>출고일자</label>
      <input type="date" id="outDate" name="outDate">
    </div>

    <div class="field">
      <label>카테고리</label>
      <div class="select-wrap">
        <select id="category" name="category">
          <option value="">전체</option>
          <option value="product">제품</option>
          <option value="materials">원자재</option>
        </select>
      </div>
    </div>

    <div class="btn-group">
      <button type="button" class="btn btn-primary" id="btnSearch">조회</button>
    </div>
  </div>

  <h2>판매현황</h2>

  <table class="table">
    <thead>
      <tr>
        <th>출고번호</th>
        <th>출고일</th>
        <th>제품코드</th>
        <th>제품명</th>
        <th>수량</th>
        <th>단가</th>
		<th>금액</th>
        <th>출고상태</th>
      </tr>
    </thead>
    <tbody>
      <!-- 컨트롤러에서 shipments 리스트를 내려주세요 -->
      <c:forEach var="row" items="${shipments}">
        <tr>
          <td>${row.shipNo}</td>
          <td><fmt:formatDate value="${row.shipDate}" pattern="yyyy-MM-dd"/></td>
          <td>${row.prodCode}</td>
          <td>${row.prodName}</td>
          <td class="text-right">
            <fmt:formatNumber value="${row.unitPrice}" type="number" groupingUsed="true"/>
          </td>
          <td class="text-right">
            <fmt:formatNumber value="${row.amount}" type="number" groupingUsed="true"/>
          </td>
          <td>${row.status}</td> <!-- 예: '출고완료', '부분출고', '대기' -->
        </tr>
      </c:forEach>

      <c:if test="${empty shipments}">
        <tr>
          <td colspan="8" style="text-align:center;">판매/출고 데이터가 없습니다.</td>
        </tr>
      </c:if>
    </tbody>
  </table>

  <!-- (선택) 조회 버튼 동작 자리 -->
  <script>
    document.getElementById('btnSearch')?.addEventListener('click', function () {
      const p = new URLSearchParams({
        code:     document.getElementById('code').value || '',
        name:     document.getElementById('name').value || '',
        outDate:  document.getElementById('outDate').value || '',
        category: document.getElementById('category').value || ''
      });
      // 컨트롤러 매핑에 맞게 수정하세요. (GET 조회 예시)
      location.href = '/sales/outbound?' + p.toString();
    });
  </script>
</body>
</html>


<%@ include file="../common/footer.jsp" %>