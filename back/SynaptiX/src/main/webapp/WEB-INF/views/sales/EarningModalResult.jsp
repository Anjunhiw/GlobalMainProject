<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

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
    <c:forEach var="s" items="${earningList}">
      <tr>
        <td>${s.ProductId}</td>
        <td><fmt:formatDate value="${s.Date}" pattern="yyyy-MM-dd"/></td>
        <td>${s.ProductName}</td>
        <td class="text-right"><fmt:formatNumber value="${s.Amount}" type="number" maxFractionDigits="0" groupingUsed="true"/></td>
        <td class="text-right"><fmt:formatNumber value="${s.Price}" type="number" groupingUsed="true"/></td>
        <td class="text-right"><fmt:formatNumber value="${s.Total}"  type="number" groupingUsed="true"/></td>
        <td class="text-right">
          <fmt:formatNumber value="${s.Earning}" type="number" groupingUsed="true"/>
        </td>
        <td class="text-right"><fmt:formatNumber value="${s.Stock}" type="number" maxFractionDigits="0" groupingUsed="true"/></td>
      </tr>
    </c:forEach>
    <c:if test="${empty earningList}">
      <tr><td colspan="8" style="text-align:center;">검색 결과가 없습니다.</td></tr>
    </c:if>
  </tbody>
</table>
</div>

<script>
	// 모달 엑셀 다운로드
	    document.getElementById('downloadExcelModal').onclick = function() {
	      var prodCode = document.getElementById('prodCode').value;
	      var prodName = document.getElementById('prodName').value;
	      var qc = document.getElementById('qc').value;
	      var startDate = document.getElementById('startDate').value;
	      var endDate = document.getElementById('endDate').value;
	      var csrfHeader = document.querySelector('meta[name="_csrf_header"]')?.content;
	      var csrfToken = document.querySelector('meta[name="_csrf"]')?.content;
	      var headers = {
	        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
	      };
	      if (csrfHeader && csrfToken) headers[csrfHeader] = csrfToken;
	      var params = new URLSearchParams();
	      if (prodCode) params.append('prodCode', prodCode);
	      if (prodName) params.append('prodName', prodName);
	      if (qc) params.append('qc', qc);
	      if (startDate) params.append('startDate', startDate);
	      if (endDate) params.append('endDate', endDate);
	      fetch('/sales/earning/excel-modal', {
	        method: 'POST',
	        headers: headers,
	        body: params.toString()
	      })
	      .then(response => {
	        if (!response.ok) throw new Error('엑셀 다운로드 실패');
	        return response.blob();
	      })
	      .then(blob => {
	        var url = window.URL.createObjectURL(blob);
	        var a = document.createElement('a');
	        a.href = url;
	        a.download = '매출_검색결과.csv';
	        document.body.appendChild(a);
	        a.click();
	        a.remove();
	        window.URL.revokeObjectURL(url);
	      })
	      .catch(() => {
	        alert('엑셀 다운로드 중 오류가 발생했습니다.');
	      });
	    };

</script>