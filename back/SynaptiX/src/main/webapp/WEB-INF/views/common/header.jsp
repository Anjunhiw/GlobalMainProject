<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>



<c:set var="active" value="${empty active_main ? 'sales' : active_main}"/>
<c:set var="uri" value="${pageContext.request.requestURI}" />
<link rel="stylesheet" href="/css/header.css?v=3">




	
	
	<header class="nav">
	  <div class="top">
	    
	    <div class="tabbar">
		  <div class="tab${active_main eq 'active' ? ' active' : ''}" onclick="location.href='/home'">메인</div>
	      <div class="tab${active_stock eq 'active' ? ' active' : ''}" onclick="location.href='/stock'">재고 / 유통</div>
	      <div class="tab${active_product eq 'active' ? ' active' : ''}" onclick="location.href='/bom'">생산 / 제조</div>
	      <div class="tab${active_sales eq 'active' ? ' active' : ''}" onclick="location.href='/sales'">영업 / 판매</div>
	      <div class="tab${active_purchase eq 'active' ? ' active' : ''}" onclick="location.href='/purchase'">구매</div>
	      <div class="tab${active_asset eq 'active' ? ' active' : ''}" onclick="location.href='/managereport'">경리회계</div>
	      <div class="tab${active_personal eq 'active' ? ' active' : ''}" onclick="location.href='/hrm'">인사 / 급여</div>
	    </div>
	  </div>

	  <div class="subtabs">
		<c:if test="${not empty active_main}">
			<a class="link ${active_main eq 'sales' ? 'active' : ''}" href="<c:url value='/home'/>">매출현황</a>
			  <a class="link ${active_main eq 'costs' ? 'active' : ''}" href="<c:url value='/home/costs'/>">비용현황</a>
			  <a class="link ${active_main eq 'stock' ? 'active' : ''}" href="<c:url value='/home/stock'/>">재고현황</a>
			  <a class="link ${active_main eq 'production' ? 'active' : ''}" href="<c:url value='/home/production'/>">생산현황</a>
			  <a class="link ${active_main eq 'hr' ? 'active' : ''}" href="<c:url value='/home/hr'/>">인사/급여현황</a>
			  <a class="link ${active_main eq 'alert' ? 'active' : ''}" href="<c:url value='/home/alert'/>">알림영역</a>
		</c:if>
		<c:if test="${not empty active_stock}">
			<a class="link active" href="/stock">재고</a>
		</c:if>
		<c:if test="${not empty active_product}">
		    <a class="link ${active_bom}" href="/bom">BOM</a>
		    <a class="link ${active_mps}" href="/mps">MPS</a>
		    <a class="link ${active_qc}" href="/qc">QC</a>
			<a class="link ${active_profit}" href="/profit">이익관리</a>
		</c:if>
		<c:if test="${not empty active_sales}">
		    <a class="link ${active_sale}" href="/sales">판매/출고</a>
		    <a class="link ${active_transaction}" href="/transaction">거래명세서</a>
		    <a class="link ${active_order}" href="/order">주문관리</a>
			<a class="link ${active_earning}" href="/earning">매출</a>
		</c:if>
		<c:if test="${not empty active_purchase}">
		    <a class="link ${active_pch}" href="/purchase">입고</a>
		    <a class="link ${active_mrp}" href="/mrp">MRP</a>
		</c:if>
		<c:if test="${not empty active_asset}">
		    <a class="link ${active_mr}" href="/managereport">경영보고서</a>
		    <a class="link ${active_asp}" href="/assetplan">자금계획</a>
		</c:if>
		<c:if test="${not empty active_personal}">
		    <a class="link active" href="/hrm">인사관리</a>
		</c:if>
	    <div class="search" title="검색">
	      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
	        <circle cx="11" cy="11" r="7" stroke-width="2"/>
	        <line x1="21" y1="21" x2="16.65" y2="16.65" stroke-width="2"/>
	      </svg>
	    </div>
	  </div>
	</header>
