<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
request.setAttribute("pageTitle", "인사관리");
request.setAttribute("active_personal", "active");
%>
<%@ include file="../common/header.jsp" %>
<link rel="stylesheet" href="<c:url value='/css/stock.css?v=1'/>">
<link rel="stylesheet" href="<c:url value='/css/bom.css?v=1'/>">
<body>
  <h2>인사</h2>

  <!-- 필터 영역 -->
  <div class="filter-smallq">
    <div class="field">
      <label>소속부서</label>
      <input type="text" id="dept" name="dept" value="${param.dept}" placeholder="">
    </div>
    <div class="field">
      <label>직급</label>
      <input type="text" id="position" name="position" value="${param.position}" placeholder="">
    </div>
    <div class="field">
      <label>이름</label>
      <input type="text" id="empName" name="empName" value="${param.empName}" placeholder="">
    </div>

    <div class="btn-group">
      <button type="button" id="btn-search" class="btn btn-primary">조회</button>
    </div>
  </div>

  <h3>지출내역</h3>
  <table class="table">
    <thead>
      <tr>
        <th>사번</th>
        <th>이름</th>
        <th>생년월일</th>
        <th>이메일</th>
        <th>부서명</th>
        <th>직급</th>
        <th>근속년수</th>
        <th>급여</th>
      </tr>
    </thead>
    <tbody>
      <c:forEach var="emp" items="${employees}">
        <tr>
          <td>${emp.userId}</td>
          <td>${emp.name}</td>
          <td><fmt:formatDate value="${emp.birth}" pattern="yyyy-MM-dd"/></td>
          <td>${emp.email}</td>
          <td>${emp.dept}</td>
          <td>${emp.rank}</td>
          <td><fmt:formatNumber value="${emp.years}" type="number" maxFractionDigits="0"/></td>
          <td class="text-right"><fmt:formatNumber value="${emp.salary}" type="number"/></td>
        </tr>
      </c:forEach>

      <c:if test="${empty employees}">
        <tr>
          <td colspan="8" style="text-align:center;">사원 데이터가 없습니다.</td>
        </tr>
      </c:if>
    </tbody>
  </table>

  <script>
    // 조회 버튼 → 쿼리 파라미터로 새로고침
    document.getElementById('btn-search')?.addEventListener('click', () => {
      const params = new URLSearchParams({
        dept: document.getElementById('dept').value || '',
        position: document.getElementById('position').value || '',
        empName: document.getElementById('empName').value || ''
      });
      // 컨트롤러 매핑에 맞게 경로만 조정
      location.href = '/hr?'+ params.toString();
    });
  </script>
</body>
</html>
<%@ include file="../common/footer.jsp" %>