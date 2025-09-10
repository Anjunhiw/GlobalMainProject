<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>회원가입</title>
</head>
<body>
<h2>회원가입</h2>
<form action="/user/register" method="post">
    <label for="userId">아이디:</label>
    <input type="text" id="userId" name="userId" required><br>
    <label for="password">비밀번호:</label>
    <input type="password" id="password" name="password" required><br>
    <label for="name">이름:</label>
    <input type="text" id="name" name="name" required><br>
    <label for="email">이메일:</label>
    <input type="email" id="email" name="email" required><br>
    <label for="dept">부서:</label>
    <input type="text" id="dept" name="dept" required><br>
    <label for="rank">직급:</label>
    <input type="text" id="rank" name="rank" required><br>
    <label for="birth">생년월일:</label>
    <input type="date" id="birth" name="birth" required><br>
    <label for="years">경력(년수):</label>
    <input type="number" id="years" name="years" required><br>
    <label for="salary">연봉:</label>
    <input type="number" id="salary" name="salary" required><br>
    <button type="submit">회원가입</button>
</form>
<c:if test="${not empty message}">
    <p>${message}</p>
</c:if>
</body>
</html>