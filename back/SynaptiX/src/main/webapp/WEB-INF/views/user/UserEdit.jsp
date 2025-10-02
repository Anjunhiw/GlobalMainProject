<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>


<link rel="stylesheet" href="<c:url value='/css/edit.css?v=1'/>">
<link rel="stylesheet" href="<c:url value='/css/style.css?v=1'/>">

<main class="auth-container">
  <section class="auth-card">
    <h1 class="auth-title">마이페이지</h1>
    <p class="auth-sub">내 정보 확인 및 수정</p>

    <form id="myForm" class="auth-form" method="post" action="<c:url value='/edit/save'/>" enctype="multipart/form-data">
      <c:if test="${not empty _csrf}">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
      </c:if>

   
      <!-- 기본 정보 -->
      <div class="grid two">
        <div class="field">
          <label>이름</label>
          <input type="text" name="name" value="<c:out value='${user.name}'/>" required>
        </div>
        <div class="field">
          <label>아이디</label>
          <input type="text" value="<c:out value='${user.id}'/>" disabled>
        </div>
     

      
        <div class="field">
          <label>이메일</label>
          <input type="email" name="email" value="<c:out value='${user.email}'/>" required>
        </div>



        <div class="field">
    		<label for="dept">부서</label>
				<select id="dept" name="dept"  value="<c:out value='${user.dept}'/>"required>
					<option value="인사">인사팀</option>
			        <option value="물류">물류팀</option>
			        <option value="영업">영업팀</option>
			        <option value="회계">회계팀</option>
			        <option value="재무">재무팀</option>
			        <option value="생산">생산팀</option>
					<option value="생산관리">생산관리팀</option>
					<option value="기술개발">기술개발팀</option>
					<option value="개발">개발팀</option>
					<option value="이사회">이사회</option>
			</select>
		<div>
		<div class="field">
		     <label>직급</label>
			  	<select id="rank" name="rank"  value="<c:out value='${user.rank}'/>" required>
		  		<option value="인턴">인턴</option>
		           <option value="사원">사원</option>
		           <option value="대리">대리</option>
		           <option value="과장">과장</option>
		           <option value="차장">차장</option>
		           <option value="부장">부장</option>
		  </select>
		   </div>

      <!-- 비밀번호 변경(선택) -->

        <div class="grid two">
          <div class="field">
            <label>현재 비밀번호</label>
            <input type="password" name="currentPassword" autocomplete="current-password">
          </div>
          <div class="field">
            <label>새 비밀번호</label>
            <input type="password" name="newPassword" autocomplete="new-password">
          </div>

        <div class="field">
          <label>새 비밀번호 확인</label>
          <input type="password" name="newPasswordConfirm" autocomplete="new-password">
        </div>

      <div class="form-actions">
        <button type="button" class="btn ghost" onclick="history.back()">취소</button>
        <button type="submit" class="btn primary">저장</button>
      </div>
	  </div>
    </form>
  </section>
  </main>