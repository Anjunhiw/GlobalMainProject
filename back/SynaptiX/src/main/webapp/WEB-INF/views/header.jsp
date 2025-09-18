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
	<link rel="stylesheet" href="/css/header.css?v=3">
  
<body>
	
	
	<header class="nav">
	  <div class="top">
	    
	    <div class="tabbar">
		<div class="tab active">메인</div>
	      <div class="tab">재고 / 유통</div>
	      <div class="tab">납 / 제조</div>
	      <div class="tab">영업 / 판매</div>
	      <div class="tab">구매</div>
	      <div class="tab">경리회계</div>
	      <div class="tab">인사 / 급여</div>
	    </div>
	  </div>

	  <div class="subtabs">
	    <a class="link active" href="#">매출현황</a>
	    <a class="link" href="#">비용현황</a>
	    <a class="link" href="#">재고현황</a>
	    <a class="link" href="#">생산현황</a>
	    <a class="link" href="#">인사 / 급여현황</a>
	    <a class="link" href="#">알림영역</a>
	    <div class="search" title="검색">
	      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
	        <circle cx="11" cy="11" r="7" stroke-width="2"/>
	        <line x1="21" y1="21" x2="16.65" y2="16.65" stroke-width="2"/>
	      </svg>
	    </div>
	  </div>
	</header>