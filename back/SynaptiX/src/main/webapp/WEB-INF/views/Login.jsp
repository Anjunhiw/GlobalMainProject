<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Login Page</title>
</head>
<body>
    <h2>로그인</h2>
    <form action="/login" method="post">
        <label for="id">아이디:</label>
        <input type="text" id="id" name="id" required><br><br>
        <label for="pw">비밀번호:</label>
        <input type="password" id="pw" name="pw" required><br><br>
        <button type="submit">로그인</button>
    </form>
    <c:if test="${not empty error}">
        <p style="color:red;">${error}</p>
    </c:if>
</body>	
</html>