<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>Login Page</title>
	<link rel="stylesheet" href="<c:url value='/css/style.css?v=1'/>">

</head>
<body class="login-page">
    <div class="login-container">
        <h2>로그인</h2>
        <form action="${pageContext.request.contextPath}/login" method="post">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
            <label for="id" class="styleID">아이디</label>
            <input type="text" id="id" placeholder="아이디를 입력해주세요."  name="id" required><br><br>
            <label for="pw" class="styleID">비밀번호</label>
            <input type="password" id="pw" name="pw" placeholder="비밀번호를 입력해주세요." required><br><br>
		
			
			<div class="login-meta">
			          <span class="user">아직 계정이 없으신가요? 
						<a href="<c:url value='/register'/>">회원가입</a></span>
			     </div>
				 
				
				<div class="login-shortcuts">
				  <a href="<c:url value='findId'/>" >아이디 찾기</a> <a class="finds">/</a> 
				  <a href="<c:url value='/findPassword'/>">비밀번호 찾기</a>
			
				  </div> 
			  <button type="submit">로그인</button>
        </form>
        
        <!-- 에러 메시지 출력 -->
        <c:if test="${not empty error}">
            <p style="color:red;">${error}</p>
        </c:if>
    </div>
</body> 
</html>