<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
request.setAttribute("pageTitle", "QC");
%>
%>
<%
request.setAttribute("subNav", "<a href='/bom'>BOM</a> <a href='/mps'>MPS</a> <a href='/qc'>QC</a>");
%>
<%@ include file="header.jsp" %>
    <title>QC List</title>
</head>
<body>
    <h2>QC List</h2>
    <table border="1">
        <tr>
            <th>MPS ID</th>
            <th>Is Passed</th>
        </tr>
        <c:forEach var="qc" items="${list}">
            <tr>
                <td>${qc.mpsId}</td>
                <td>${qc.passed}</td>
            </tr>
        </c:forEach>
    </table>
<%@ include file="footer.jsp" %>