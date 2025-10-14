<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<table class="table">
  <thead>
    <tr>
      <th>사번</th>
      <th>이름</th>
      <th>생년월일</th>
      <th>이메일</th>
      <th>부서명</th>
      <th>직급</th>
      <th>근속년수</th>
      <th>급여</th>
    </tr>
  </thead>
  <tbody>
    <c:forEach var="emp" items="${employees}">
      <tr>
        <td><fmt:formatNumber value="${emp.pk}" pattern="000000"/></td>
        <td>${emp.name}</td>
        <td>"${emp.birth}"</td>
        <td>${emp.email}</td>
        <td>${emp.dept}</td>
        <td>${emp.rank}</td>
        <td><fmt:formatNumber value="${emp.years}" type="number" maxFractionDigits="0"/></td>
        <td class="text-right"><fmt:formatNumber value="${emp.salary}" type="number"/></td>
      </tr>
    </c:forEach>
    <c:if test="${empty employees}">
      <tr><td colspan="8" style="text-align:center;">검색 결과가 없습니다.</td></tr>
    </c:if>
  </tbody>
</table>
