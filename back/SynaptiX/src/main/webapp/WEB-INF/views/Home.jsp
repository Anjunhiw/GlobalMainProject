<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>Test JSP</title>
</head>
<body>
    <h2>JSP Test Page</h2>
    <p>This is a test JSP file for your project.</p>
    <!-- 로그인 정보 출력 -->
    <p>로그인 아이디: ${id}</p>
    <p>로그인 이름: ${name}</p>
    <p>user 객체 아이디: ${user.id}</p>
    <p>user 객체 이름: ${user.name}</p>
    <!-- homeList 정보 출력 -->
    <c:if test="${not empty homeList}">
        <p>homeList 아이디: ${homeList[0]['id']}</p>
        <p>homeList 이름: ${homeList[0]['name']}</p>
    </c:if>
</body>
</html>