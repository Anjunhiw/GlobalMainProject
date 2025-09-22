<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
request.setAttribute("pageTitle", "QC");
request.setAttribute("active_product", "active");
request.setAttribute("active_qc", "active");
%>
<%@ include file="../common/header.jsp" %>
<link rel="stylesheet" href="<c:url value='/css/stock.css?v=1'/>">
<link rel="stylesheet" href="<c:url value='/css/bom.css?v=1'/>">

<body>

  <h2>QC 검사 결과 조회</h2>

  <!-- 상단 필터 -->
  <div class="filter-small">
    <div class="field">
      <label>기간</label>
      <div class="input-with-btn">
        <input type="date" id="dateFrom" name="dateFrom">
      </div>
    </div>

 
    <div class="field">
      <label>제품명</label>
      <input type="text" id="prodName" name="prodName" placeholder="예: 전동드릴">
    </div>

    <div class="field">
      <label>합격여부</label>
      <div class="select-wrap">
        <select id="category" name="category">
          <option value="">전체</option>
          <option value="passed">합격</option>
          <option value="failed">불합격</option>
        </select>
      </div>
    </div>

    <div class="btn-group">
      <button type="button" class="btn btn-primary" id="btnSearch">조회</button>
    </div>
  </div>

  <h2>QC 검사 결과</h2>

  <table class="table">
    <thead>
      <tr>
        <th>제품코드</th>
        <th>제품명</th>
        <th>모델명</th>
        <th>규격</th>
        <th>검사일자</th>
        <th>합격여부</th>
      </tr>
    </thead>
    <tbody>
      <!-- 컨트롤러에서 model.addAttribute("qcList", 리스트) 로 전달 -->
      <c:forEach var="qc" items="${qcList}">
        <tr>
          <td>${qc.prodCode}</td>
          <td>${qc.prodName}</td>
          <td>${qc.model}</td>
          <td>${qc.specification}</td>
          <td>
            <fmt:formatDate value="${qc.inspectedAt}" pattern="yyyy-MM-dd"/>
          </td>
          <td>${qc.inspector}</td>
          <td>
            <c:choose>
              <c:when test="${qc.passed}">합격</c:when>
              <c:otherwise>불합격</c:otherwise>
            </c:choose>
          </td>
        </tr>
      </c:forEach>

      <c:if test="${empty qcList}">
        <tr>
          <td colspan="6" style="text-align:center;">QC 검사 데이터가 없습니다.</td>
        </tr>
      </c:if>
    </tbody>
  </table>

  <!-- (선택) 검색버튼에 대한 간단한 자바스크립트 자리만 잡아둠 -->
  <script>
    document.getElementById('btnSearch')?.addEventListener('click', function () {
      // 여기서 location.href or fetch 로 조회 요청을 붙이면 됩니다.
      // 예) location.href = `/qc?from=${dateFrom.value}&to=${dateTo.value}&name=${prodName.value}&cat=${category.value}`;
      alert('조회 로직을 컨트롤러에 맞춰 연결하세요 🙂');
    });
  </script>
</body>
</html>
<%@ include file="../common/footer.jsp" %>
