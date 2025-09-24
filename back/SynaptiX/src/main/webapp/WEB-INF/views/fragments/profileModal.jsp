<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<link rel="stylesheet" href="<c:url value='/css/pfofile.css?v=1'/>">

<div id="profile-modal">
  <div class="modal-content">
    <span id="btn-profile-close" class="close">&times;</span>
    <h2>회원 정보 수정</h2>

    <form>
      <label>성명</label>
      <input type="text" value="${user.name}">
      <label>이메일</label>
      <input type="email" value="${user.email}">
      <label>비밀번호 변경</label>
      <input type="password" placeholder="새 비밀번호 입력">
      <div class="actions">
        <button type="submit" class="btn-save">저장</button>
        <button type="button" id="btn-cancel" class="btn-cancel">취소</button>
      </div>
    </form>
  </div>
</div>