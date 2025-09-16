<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>Login Page</title>
  
</head>
<body>
    <div class="login-container">
        <h2>로그인</h2>
        <form action="${pageContext.request.contextPath}/login" method="post">
            <label for="id">아이디</label>
            <input type="text" id="id" name="id" required ><br><br>
            <label for="pw">비밀번호</label>
            <input type="password" id="pw" name="pw" required><br><br>
            <button type="submit">로그인</button>
        </form>
        
        <!-- 에러 메시지 출력 -->
        <c:if test="${not empty error}">
            <p style="color:red;">${error}</p>
        </c:if>
    </div>
</body> 
</html>
