<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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
        <tr>
          <td class="text-right"><fmt:formatNumber value="${asset.totalAssets}" type="number" /></td>
          <td class="text-right"><fmt:formatNumber value="${asset.currentAssets}" type="number" /></td>
        </tr>
      <c:if test="${empty asset}">
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
        <tr>
          <td class="text-right"><fmt:formatNumber value="${asset.totalEarning}" type="number" /></td>
          <td class="text-right"><fmt:formatNumber value="${asset.totalCost}" type="number" /></td>
        </tr>
      <c:if test="${empty asset}">
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