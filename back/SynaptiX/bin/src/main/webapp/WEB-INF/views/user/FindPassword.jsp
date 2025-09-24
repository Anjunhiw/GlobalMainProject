<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8"/>
    <title>비밀번호 찾기</title>
    <link rel="stylesheet" href="<c:url value='/css/style.css?v=1'/>">
</head>
<body class="pwfind-page">

<div class="pwfind-card">
    <h1 class="pwfind-title">비밀번호 찾기</h1>

 <form method="post" action="<c:url value='/findPassword'/>">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

        <!-- 아이디 -->
        <label class="pwfind-label" for="userId">아이디</label>
        <input class="pwfind-input" type="text" id="userId" name="userId"
               placeholder="아이디를 적어주세요" required />

        <!-- 생년월일 (옵션) -->
        <label class="pwfind-label" for="birthYear">생년월일</label>
        <div class="pwfind-birth">
            <select class="pwfind-select" id="birthYear" name="birthYear">
                <option value="">xxxx년</option>
                <c:forEach var="y" begin="1950" end="2025">
                    <option value="${y}">${y}년</option>
                </c:forEach>
            </select>
            <select class="pwfind-select" id="birthMonth" name="birthMonth">
                <option value="">xx월</option>
                <c:forEach var="m" begin="1" end="12">
                    <option value="${m}">${m}월</option>
                </c:forEach>
            </select>
            <select class="pwfind-select" id="birthDay" name="birthDay">
                <option value="">xx일</option>
                <c:forEach var="d" begin="1" end="31">
                    <option value="${d}">${d}일</option>
                </c:forEach>
            </select>
        </div>

        <!-- 이메일 -->
        <label class="pwfind-label" for="email">이메일</label>
        <input class="pwfind-input" type="email" id="email" name="email"
               placeholder="임시 비밀번호를 받을 이메일을 적어주세요" required />

        <!-- 도움 링크 -->
        <div class="pwfind-help">
            <div>아직 계정이 없으신가요? <a href="<c:url value='/register'/>">회원가입</a></div>
            <div>혹시 아이디가 있으신가요? <a href="<c:url value='login'/>">로그인 하러가기</a></div>
        </div>
		<c:if test="${not empty result}">
			<p style="margin-top:14px; color:#4664c9;">${result}</p>
		</c:if>
        <!-- CTA 버튼 -->
        <button type="submit" class="pwfind-btn">비밀번호 찾기</button>
    </form>
	
    <c:if test="${not empty message}">
        <p style="margin-top:14px; color:#4664c9;">${message}</p>
    </c:if>
</div>

</body>
</html>