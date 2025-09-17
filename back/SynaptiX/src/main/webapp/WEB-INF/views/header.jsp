<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!Doctype html>
<html>
<head>
    <title>
        <c:choose>
            <c:when test="${not empty pageTitle}">
                ${pageTitle}
            </c:when>
            <c:otherwise>
                SynaptiX
            </c:otherwise>
        </c:choose>
    </title>
    <style>
        /* 헤더 스타일 */
        header {
            background-color: #f8f9fa;
            padding: 10px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #dee2e6;
        }
        nav a {
            margin: 0 15px;
            text-decoration: none;
            color: #007bff;
        }
        nav a:hover {
            text-decoration: underline;
        }
    </style>
<body>
	<header>
		<div class="logo">
            <h1>SynaptiX</h1>
        </div>
        <nav>
            <a href="/home">홈</a>
            <a href="/stock">재고관리</a>
            <a href="/bom">생산/제조</a>
			<a href="/sales">영업/판매</a>
			<a href="/managereport">경리회계</a>
			<a href="/user/hrm">인사관리</a>
			<a href="/login">로그인</a>
			<a href="/register">회원가입</a>
        </nav>
        <nav class="sub-nav">
        <c:if test="${not empty subNav}">
            ${subNav}
        </c:if>
    </nav>
	</header>