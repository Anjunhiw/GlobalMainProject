<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
request.setAttribute("pageTitle", "MPS");
%>
<%
request.setAttribute("subNav", "<a href='/bom'>BOM</a> <a href='/mps'>MPS</a> <a href='/qc'>QC</a>");
%>
<%@ include file="header.jsp" %>
    <title>MPS List</title>
</head>
<body>
    <h2>MPS List</h2>
    <table border="1">
        <tr>
            <th>ID</th>
            <th>Name</th>
            <th>Plan Date</th>
			<th>Volume</th>
        </tr>
        <c:forEach var="mps" items="${list}">
            <tr>
                <td>${mps.pk}</td>
                <td>${mps.productId}</td>
                <td>${mps.period}</td>
				<td>${mps.volume}</td>
            </tr>
        </c:forEach>
    </table>
<%@ include file="footer.jsp" %>