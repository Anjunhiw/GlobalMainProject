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

<jsp:useBean id="now" class="java.util.Date"/>
<fmt:formatDate value="${now}" pattern="yyyy-MM-dd" var="today"/>

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
      <c:forEach var="row" items="${salesList}">
        <fmt:formatDate value="${row.saleDate}" pattern="yyyy-MM-dd" var="saleDateStr"/>
        <tr>
          <td>${row.pk}</td>
          <td><fmt:formatDate value="${row.saleDate}" pattern="yyyy-MM-dd"/></td>
          <td>prod2025<c:choose><c:when test="${row.productId lt 10}">0${row.productId}</c:when><c:otherwise>${row.productId}</c:otherwise></c:choose></td>
          <td>${row.productName}</td>
          <td class="text-right">
            <fmt:formatNumber value="${row.quantity}" type="number" groupingUsed="true"/>
          </td>
		  <td><fmt:formatNumber value="${row.price}" type="number" groupingUsed="true"/></td>
          <td class="text-right">
            <fmt:formatNumber value="${row.earning}" type="number" groupingUsed="true"/>
          </td>
          <td>
            <c:choose>
              <c:when test="${saleDateStr lt today}">출고완료</c:when>
              <c:otherwise>출고준비</c:otherwise>
            </c:choose>
          </td>
        </tr>
      </c:forEach>

      <c:if test="${empty salesList}">
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