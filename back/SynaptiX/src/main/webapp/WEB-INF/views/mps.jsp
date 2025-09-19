<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
request.setAttribute("pageTitle", "MPS관리");
request.setAttribute("active_product", "active");
request.setAttribute("active_mps", "active");
%>
<%@ include file="header.jsp" %>
<body>
    <h2>MPS 조회결과</h2>
    <table border="1">
        <tr>
            <th>제품ID</th>
            <th>제품명</th>
            <th>종료일</th>
			<th>생산량</th>
        </tr>
        <c:forEach var="mps" items="${list}">
            <tr>
                <td>${mps.productId}</td>
                <td>${mps.productName}</td>
                <td><fmt:formatDate value="${mps.period}" pattern="yyyy-MM-dd"/></td>
				<td><fmt:formatNumber value="${mps.volume}" type="number" maxFractionDigits="0"/></td>
            </tr>
        </c:forEach>
    </table>
<%@ include file="footer.jsp" %>