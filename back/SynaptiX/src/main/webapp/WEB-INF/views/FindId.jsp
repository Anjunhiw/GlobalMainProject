<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>아이디 찾기</title>
	<link rel="stylesheet" href="<c:url value='/css/style.css?v=1'/>">
</head>
<body class="findid-page">
  <div class="findid-container">
    <h2>아이디 찾기</h2>

    <form action="<c:url value='/findId'/>" method="post">
      <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

      <label for="email">이메일</label>
      <input type="email" id="email" name="email" placeholder="회원가입 하신 이메일을 적어주세요" required>

	  <label>생년월일</label>
	  <div class="birth-row">
	      <input type="text" name="year" maxlength="4" placeholder="YYYY" required>
	      <input type="text" name="month" maxlength="2" placeholder="MM" required>
	      <input type="text" name="day" maxlength="2" placeholder="DD" required>
	  </div>

	  
	  <div class="findid-footer">
	        <div>아직 계정이 없으신가요? <a href="<c:url value='/register'/>">회원가입</a></div>
	        <div>혹시 아이디가 있으신가요? <a href="<c:url value='/login'/>">로그인 하러가기</a></div>
	      </div>
	  
	  
	  
      <button class="btn-primary" type="submit">아이디 찾기</button>
    </form>

    
  </div>
</body>
</html>
