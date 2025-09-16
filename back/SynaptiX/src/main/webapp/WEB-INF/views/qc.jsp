<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
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
</body>
</html>