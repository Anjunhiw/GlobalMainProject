<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
request.setAttribute("pageTitle", "경영보고서");
request.setAttribute("active_asset", "active");
request.setAttribute("active_mr", "active");
%>
<%@ include file="../common/header.jsp" %>
<link rel="stylesheet" href="<c:url value='/css/stock.css?v=1'/>">
<link rel="stylesheet" href="<c:url value='/css/bom.css?v=1'/>">

  <h2>경영보고서</h2>

  <!-- 검색 영역 -->
  <div class="filter-smally">
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

  <!-- 자금 현황 -->
  <h3>자금현황</h3>
  <table class="table">
    <thead>
      <tr>
        <th>총자금</th>
        <th>유동자금</th>
      </tr>
    </thead>
    <tbody>
      <c:forEach var="f" items="${funds}">
        <tr>
          <td class="text-right"><fmt:formatNumber value="${f.total}" type="number" /></td>
          <td class="text-right"><fmt:formatNumber value="${f.current}" type="number" /></td>
        </tr>
      </c:forEach>
      <c:if test="${empty funds}">
        <tr><td colspan="2" style="text-align:center;">자금 데이터가 없습니다.</td></tr>
      </c:if>
    </tbody>
  </table>

  <!-- 수익/비용 현황 -->
  <h3>수익/비용 현황</h3>
  <table class="table">
    <thead>
      <tr>
        <th>총판매수익</th>
        <th>총구매비용</th>
      </tr>
    </thead>
    <tbody>
      <c:forEach var="p" items="${profits}">
        <tr>
          <td class="text-right"><fmt:formatNumber value="${p.sales}" type="number" /></td>
          <td class="text-right"><fmt:formatNumber value="${p.purchases}" type="number" /></td>
        </tr>
      </c:forEach>
      <c:if test="${empty profits}">
        <tr><td colspan="2" style="text-align:center;">수익/비용 데이터가 없습니다.</td></tr>
      </c:if>
    </tbody>
  </table>

  <script>
    document.getElementById('btnSearch')?.addEventListener('click', () => {
      const params = new URLSearchParams({
        startDate: document.getElementById('startDate').value || '',
        endDate: document.getElementById('endDate').value || ''
      });
      location.href = '/report?' + params.toString(); // 컨트롤러 매핑에 맞게 수정
    });
  </script>
</body>
</html>
<%@ include file="../common/footer.jsp" %>