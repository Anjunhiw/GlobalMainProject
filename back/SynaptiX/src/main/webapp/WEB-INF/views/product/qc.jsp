<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
request.setAttribute("pageTitle", "QC");
request.setAttribute("active_product", "active");
request.setAttribute("active_qc", "active");
%>
<%@ include file="../common/header.jsp" %>
    <h2>QC 조회결과</h2>
    <table border="1">
        <tr>
            <th>MPS ID</th>
            <th>생산계획검사 합/불</th>
        </tr>
        <c:forEach var="qc" items="${list}">
            <tr>
                <td>${qc.mpsId}</td>
                <td>
                  <c:choose>
                    <c:when test="${qc.passed}">합격</c:when>
                    <c:otherwise>불합격</c:otherwise>
                  </c:choose>
                </td>
            </tr>
        </c:forEach>
    </table>
<%@ include file="../common/footer.jsp" %>