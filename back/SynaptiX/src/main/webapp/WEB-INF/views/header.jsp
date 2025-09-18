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
            flex-direction: column;
            align-items: center;
            border-bottom: 1px solid #dee2e6;
        }
        .logo {
            margin-bottom: 8px;
        }
        nav {
            display: flex;
            flex-wrap: wrap;
            justify-content: center;
        }
        nav a {
            margin: 0 15px;
            text-decoration: none;
            color: #007bff;
            font-size: 1.1em;
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
			<a href="/hrm">인사관리</a>
			<a href="/login/logout">로그아웃</a>
        </nav>
        <c:if test="${not empty subNavPage}">
            <jsp:include page="${subNavPage}" />
        </c:if>
	</header>