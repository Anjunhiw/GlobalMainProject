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

    <!-- 결과 메시지 출력 영역 필요 시 위치 조정-->
    <c:if test="${not empty result}">
      <div class="form-result success">회원님의 아이디는 <strong>${result}</strong> 입니다.</div>
    </c:if>
    <c:if test="${not empty errorMsg}">
      <div class="form-result error">${errorMsg}</div>
    </c:if>

	<form method="post" action="<c:url value='/findId'/>">
	  <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
	  <!-- 이메일 -->
	  <label class="form-label" for="email">이메일</label>
	  <input class="form-input" type="email" id="email" name="email"
	         placeholder="회원가입하신 이메일을 적어주세요" required/>

	  <!-- 생년월일 : 비밀번호 찾기와 동일 셀렉트 3분할 -->
	  <label class="form-label" for="birthYear">생년월일</label>
	  <div class="form-3col">
	    <select class="form-select" id="birthYear" name="birthYear" required>
	      <option value="">xxxx년</option>
	      <c:forEach var="y" begin="1950" end="2025">
	        <option value="${y}">${y}년</option>
	      </c:forEach>
	    </select>

	    <select class="form-select" id="birthMonth" name="birthMonth" required>
	      <option value="">xx월</option>
	      <c:forEach var="m" begin="1" end="12">
	        <option value="${m}">${m}월</option>
	      </c:forEach>
	    </select>

	    <select class="form-select" id="birthDay" name="birthDay" required>
	      <option value="">xx일</option>
	      <c:forEach var="d" begin="1" end="31">
	        <option value="${d}">${d}일</option>
	      </c:forEach>
	    </select>
	  </div>

	<div class="form-help">
		<span>아직 계정이 없으신가요? <a href="<c:url value='/register'/>">회원가입</a></span>
		     <span>혹시 아이디가 있으신가요? <a href="<c:url value='/login'/>">로그인 하러가기</a></span>
	   </div>
	
	
    <button type="submit" class="btn-primary">아이디 찾기</button>

   
  </div>
</body>

</html>