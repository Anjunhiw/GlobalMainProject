<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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
      <button type="button" class="btn btn-success">등록</button>
      <button type="button" class="btn btn-primary">조회</button>
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
	      <tr>
	        <td>prod2025<c:choose><c:when test="${plan.productId lt 10}">0${plan.productId}</c:when><c:otherwise>${plan.productId}</c:otherwise></c:choose></td>
	        <td>${plan.productName}</td>
	        <td><fmt:formatNumber value="${plan.volume}" type="number" maxFractionDigits="0"/></td>
	        <td><fmt:formatDate value="${plan.period}" pattern="yyyy-MM-dd"/></td>
	        <td><fmt:formatNumber value="${plan.price * plan.volume}" type="number" groupingUsed="true"/></td>
	        <td>
	          <form action="/mps/edit" method="get" style="display:inline;">
	            <input type="hidden" name="id" value="${plan.pk}">
	            <button type="submit" class="btn btn-sm btn-warning">수정</button>
	          </form>
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

  <script>
    // 나중에 Ajax/실데이터 연결 시 사용
  </script>
</body>
</html>
<%@ include file="../common/footer.jsp" %>