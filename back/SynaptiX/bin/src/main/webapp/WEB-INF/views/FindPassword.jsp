<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>비밀번호 찾기</title>
</head>
<body>
<h2>비밀번호 찾기</h2>
<form method="post" action="/user/findPassword">
    <label for="userId">아이디:</label>
    <input type="text" id="userId" name="userId" required><br>
    <label for="email">이메일:</label>
    <input type="text" id="email" name="email" required><br>
    <button type="submit">비밀번호 찾기</button>
</form>
<c:if test="${not empty message}">
    <p>${message}</p>
</c:if>
<a href="/user/login">로그인으로 돌아가기</a>
</body>
</html>
