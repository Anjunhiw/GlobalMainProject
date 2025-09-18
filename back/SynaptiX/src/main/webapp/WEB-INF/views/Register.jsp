<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>회원가입</title>
	<link rel="stylesheet" href="<c:url value='/css/style.css?v=1'/>">
	
</head>
<body>
<div class="register-container">
    <h2>계정 정보 등록</h2>
	<form action="<c:url value='/register'/>" method="post">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

        <label for="userId">아이디</label>
        <input type="text" id="userId" name="userId" placeholder="사용하실 아이디를 적어주세요" required>
		
		<c:if test="${not empty check_id}">
		        <p>${check_id}</p>
		</c:if>
		
        <label for="password">비밀번호</label>
        <input type="password" id="password" name="password" placeholder="비밀번호를 적어주세요" required>

        <label for="confirmPassword">비밀번호 확인</label>
        <input type="password" id="confirmPassword" name="confirmPassword" placeholder="비밀번호를 다시 적어주세요" required>

        <label for="birth">생년월일</label>
        <input type="date" id="birth" name="birth" required>

        <label for="gender">성별</label>
        <select id="gender" name="gender">
            <option value="female">여성</option>
            <option value="male">남성</option>
        </select>

        <label for="email">이메일</label>
        <input type="email" id="email" name="email" placeholder="이메일을 적어주세요" required>

        <label for="dept">부서</label>
        <input type="text" id="dept" name="dept" placeholder="본인의 부서를 적어주세요" required>

        <label for="rank">직급</label>
        <input type="text" id="rank" name="rank" placeholder="본인의 직급을 적어주세요" required>

        <label for="years">경력(년수)</label>
        <input type="number" id="years" name="years" required>

        <label for="salary">연봉</label>
        <input type="number" id="salary" name="salary" required>

		<div class="form-footer">
		    <span>혹시 아이디가 있으신가요?</span>
		    <a href="<c:url value='/login'/>">로그인 하러가기</a>
		</div>
		
        <button type="submit">회원가입</button>
    </form>

    <c:if test="${not empty message}">
        <p>${message}</p>
    </c:if>
</div>
</body>

</html>