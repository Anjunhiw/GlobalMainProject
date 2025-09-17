<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>아이디 찾기</title>
	<link rel="stylesheet" href="<c:url value='/css/style.css?v=1'/>">
</head>
<body class="form-page"> 
  <div class="form-card">
    <h2 class="form-title">아이디 찾기</h2>

    <label class="label-title">이메일</label>
    <input type="email" placeholder="가입 시 등록한 이메일을 입력하세요" class="form-input"/>

    <label class="label-title">생년월일</label>
    <div class="form-3col">
      <input type="text" placeholder="년" class="form-input"/>
      <input type="text" placeholder="월" class="form-input"/>
      <input type="text" placeholder="일" class="form-input"/>
    </div>

	<div class="form-help">
		<span>아직 계정이 없으신가요? <a href="<c:url value='/register'/>">회원가입</a></span>
		     <span>혹시 아이디가 있으신가요? <a href="<c:url value='/login'/>">로그인 하러가기</a></span>
	   </div>
	
	
    <button type="submit" class="btn-primary">아이디 찾기</button>

   
  </div>
</body>

</html>
