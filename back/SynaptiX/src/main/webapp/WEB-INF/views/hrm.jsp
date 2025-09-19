<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
request.setAttribute("pageTitle", "인사관리");
request.setAttribute("active_personal", "active");
%>
<%@ include file="header.jsp" %>
<div class="container">
    <h2>인사관리</h2>
    <table border="1" style="width:70%; text-align:center;">
        <tr>
            <th>사원번호</th>
            <th>이름</th>
            <th>생년월일</th>
            <th>이메일</th>
            <th>부서</th>
            <th>직급</th>
            <th>근속년수</th>
            <th>연봉</th>
        </tr>
        <c:forEach var="user" items="${users}">
            <tr>
                <td>${user.userId}</td>
                <td>${user.name}</td>
                <td>${user.birth}</td>
                <td>${user.email}</td>
                <td>${user.dept}</td>
                <td>${user.rank}</td>
                <td>${user.years}</td>
                <td><fmt:formatNumber value="${user.salary}" type="number"/></td>
            </tr>
        </c:forEach>
    </table>
</div>
<%@ include file="footer.jsp" %>