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
    <!-- 세션 존재 여부 표시 -->
    <c:choose>
        <c:when test="${not empty user}">
            <p style="color:green;">로그인 상태</p>
        </c:when>
        <c:otherwise>
            <p style="color:red;">비로그인 상태</p>
        </c:otherwise>
    </c:choose>
    <!-- 로그아웃 버튼 추가 -->
    <form action="/login/logout" method="get">
        <button type="submit">로그아웃</button>
    </form>
    <!-- 로그인 페이지로 이동 버튼 추가 -->
    <form action="/login" method="get">
        <button type="submit">로그인 페이지로 이동</button>
    </form>
</body>
</html>