<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
request.setAttribute("pageTitle", "매출");
request.setAttribute("active_sales", "active");
request.setAttribute("active_earning", "active");
%>
<%@ include file="../common/header.jsp" %>
<link rel="stylesheet" href="<c:url value='/css/stock.css?v=1'/>">
<link rel="stylesheet" href="<c:url value='/css/bom.css?v=1'/>">

<body>
  <h2>매출</h2>

  <!-- 필터 -->
  <div class="filter-smalll">
    <div class="field">
      <label>제품코드</label>
      <input type="text" id="prodCode" name="prodCode" placeholder="예: P-1001" value="${param.prodCode}">
    </div>

    <div class="field">
      <label>제품명</label>
      <input type="text" id="prodName" name="prodName" placeholder="예: 전동드릴" value="${param.prodName}">
    </div>

    <div class="field">
      <label>QC합불여부</label>
      <div class="select-wrap">
        <select id="qc" name="qc">
          <option value="" ${empty param.qc ? 'selected' : ''}>전체</option>
          <option value="PASS" ${param.qc == 'PASS' ? 'selected' : ''}>합격</option>
          <option value="FAIL" ${param.qc == 'FAIL' ? 'selected' : ''}>불량</option>
        </select>
      </div>
    </div>

    <div class="field">
      <label>시작일자</label>
      <input type="date" id="startDate" name="startDate" value="${param.startDate}">
    </div>

    <div class="field">
      <label>종료일자</label>
      <input type="date" id="endDate" name="endDate" value="${param.endDate}">
    </div>

    <div class="btn-group">
      <button type="button" id="btnSearch" class="btn btn-primary">조회</button>
    </div>
  </div>

  <h2>매출현황</h2>

  <table class="table">
    <thead>
      <tr>
        <th>제품코드</th>
        <th>판매일자</th>
        <th>제품명</th>
        <th>판매수량</th>
        <th>판매금액</th>
        <th>원가</th>
        <th>순이익</th>
        <th>재고량</th>
      </tr>
    </thead>
    <tbody>
      <!-- 컨트롤러: model.addAttribute("sales", list) -->
      <c:forEach var="s" items="${sales}">
        <tr>
          <td>${s.prodCode}</td>
          <td><fmt:formatDate value="${s.salesDate}" pattern="yyyy-MM-dd"/></td>
          <td>${s.prodName}</td>
          <td class="text-right"><fmt:formatNumber value="${s.qty}" type="number" maxFractionDigits="0" groupingUsed="true"/></td>
          <td class="text-right"><fmt:formatNumber value="${s.salesAmount}" type="number" groupingUsed="true"/></td>
          <td class="text-right"><fmt:formatNumber value="${s.costAmount}"  type="number" groupingUsed="true"/></td>
          <td class="text-right">
            <fmt:formatNumber value="${s.salesAmount - s.costAmount}" type="number" groupingUsed="true"/>
          </td>
          <td class="text-right"><fmt:formatNumber value="${s.remainStock}" type="number" maxFractionDigits="0" groupingUsed="true"/></td>
        </tr>
      </c:forEach>

      <c:if test="${empty sales}">
        <tr><td colspan="8" style="text-align:center;">매출 데이터가 없습니다.</td></tr>
      </c:if>
    </tbody>
  </table>

  <!-- 조회 버튼: GET 파라미터로 재조회 -->
  <script>
    document.getElementById('btnSearch')?.addEventListener('click', function () {
      const p = new URLSearchParams({
        prodCode : document.getElementById('prodCode').value || '',
        prodName : document.getElementById('prodName').value || '',
        qc       : document.getElementById('qc').value || '',
        startDate: document.getElementById('startDate').value || '',
        endDate  : document.getElementById('endDate').value || ''
      });
      // 컨트롤러 매핑에 맞게 경로만 바꿔주세요 (예: GET /sales/revenue)
      location.href = '/sales/revenue?' + p.toString();
    });
  </script>

</body>
</html>
<%@ include file="../common/footer.jsp" %>