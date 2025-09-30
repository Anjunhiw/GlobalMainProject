<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>


<link rel="stylesheet" href="<c:url value='/css/edit.css?v=1'/>">


<main class="auth-container">
  <section class="auth-card">
    <h1 class="auth-title">마이페이지</h1>
    <p class="auth-sub">내 정보 확인 및 수정</p>

    <form id="myForm" class="auth-form" method="post" action="<c:url value='/edit/save'/>" enctype="multipart/form-data">
      <c:if test="${not empty _csrf}">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
      </c:if>

      <!-- 아바타 -->
      <div class="avatar-row">
        <div class="avatar-help">
          <strong>${user.name}</strong> 님
          <div class="help-sub">${user.email}</div>
        </div>
      </div>

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
      </div>

      <div class="grid two">
        <div class="field">
          <label>이메일</label>
          <input type="email" name="email" value="<c:out value='${user.email}'/>" required>
        </div>


      <div class="grid two">
        <div class="field">
          <label>부서</label>
          <input type="text" name="dept" value="<c:out value='${user.dept}'/>">
        </div>
        <div class="field">
          <label>직급</label>
          <input type="text" name="rank" value="<c:out value='${user.rank}'/>">
        </div>
      </div>

      <!-- 비밀번호 변경(선택) -->
      <details class="pw-box">
        <summary>비밀번호 변경</summary>
        <div class="grid two">
          <div class="field">
            <label>현재 비밀번호</label>
            <input type="password" name="currentPassword" autocomplete="current-password">
          </div>
          <div class="field">
            <label>새 비밀번호</label>
            <input type="password" name="newPassword" autocomplete="new-password">
          </div>
        </div>
        <div class="field">
          <label>새 비밀번호 확인</label>
          <input type="password" name="newPasswordConfirm" autocomplete="new-password">
        </div>
      </details>

      <div class="form-actions">
        <button type="button" class="btn ghost" onclick="history.back()">취소</button>
        <button type="submit" class="btn primary">저장</button>
      </div>
    </form>
  </section>
  </main>