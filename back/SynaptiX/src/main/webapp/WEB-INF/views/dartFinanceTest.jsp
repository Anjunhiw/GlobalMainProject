<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<html>
<head>
    <title>DART 재무제표 테스트</title>
    <style>
        body { font-family: Arial, sans-serif; background: #f8f9fa; margin: 0; padding: 0; }
        .container { max-width: 900px; margin: 40px auto; background: #fff; padding: 30px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.08); }
        h1 { text-align: center; color: #333; }
        .status { margin-bottom: 20px; text-align: center; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 10px; text-align: center; }
        th { background: #007bff; color: #fff; }
        tr:nth-child(even) { background: #f2f2f2; }
    </style>
</head>
<body>
<div class="container">
    <h1>DART 재무제표 테스트</h1>
    <div class="status">
        <b>상태:</b> <span>${response.status}</span>
        <b>메시지:</b> <span>${response.message}</span>
    </div>
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
        <div style="font-size: 1.5em; font-weight: bold;">${year}년</div>
        <div>
            <c:if test="${year > 2015}">
                <a href="dartFinanceTest.do?year=${year - 1}" style="font-size: 2em; text-decoration: none; margin-right: 10px;">&#8592;</a>
            </c:if>
            <c:if test="${year < 2024}">
                <a href="dartFinanceTest.do?year=${year + 1}" style="font-size: 2em; text-decoration: none;">&#8594;</a>
            </c:if>
        </div>
    </div>
    <c:choose>
        <c:when test="${response.status eq 'error'}">
            <div style="color: red; text-align: center; font-size: 1.2em; margin: 30px 0;">
                <b>API 호출 실패:</b> ${response.message}
            </div>
        </c:when>
        <c:otherwise>
            <table>
                <thead>
                <tr>
                    <th>접수번호</th>
                    <th>회사코드</th>
                    <th>사업연도</th>
                    <th>보고서코드</th>
                    <th>계정명</th>
                    <th>당기금액<br><span style="font-size:12px; font-weight:normal;">(단위: 원)</span></th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="item" items="${response.list}">
                    <tr>
                        <td>${item.rcept_no}</td>
                        <td>${item.corp_code}</td>
                        <td>${item.bsns_year}</td>
                        <td>${item.reprt_code}</td>
                        <td>${item.account_nm}</td>
                        <td><fmt:formatNumber value="${item.thstrm_amount}" type="number" groupingUsed="true"/> 원</td>
                    </tr>
                </c:forEach>
                <c:if test="${empty response.list}">
                    <tr><td colspan="6">데이터가 없습니다.</td></tr>
                </c:if>
                </tbody>
            </table>
        </c:otherwise>
    </c:choose>
</div>
</body>
</html>