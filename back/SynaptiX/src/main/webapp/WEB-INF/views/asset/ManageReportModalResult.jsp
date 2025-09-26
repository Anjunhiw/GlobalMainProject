<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

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
