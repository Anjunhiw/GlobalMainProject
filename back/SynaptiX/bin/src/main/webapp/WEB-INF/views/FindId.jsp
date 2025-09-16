<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>아이디 찾기</title>
</head>
<body>
<h2>아이디 찾기</h2>
<form method="post" action="/user/findId">
    <label for="email">이메일:</label>
    <input type="text" id="email" name="email" required><br>
    <label for="name">이름:</label>
    <input type="text" id="name" name="name" required><br>
    <button type="submit">아이디 찾기</button>
</form>
<c:if test="${not empty message}">
    <p>${message}</p>
</c:if>
<a href="/user/login">로그인으로 돌아가기1</a>
</body>
</html>
