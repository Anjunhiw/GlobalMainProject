<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
request.setAttribute("pageTitle", "경영보고서");
%>
<%
request.setAttribute("subNav", "<a href='/managereport'>경영보고서</a> <a href='/assetplan'>자금계획</a>");
%>
<%@ include file="header.jsp" %>

<div class="container">
    <h2>자산 현황</h2>
    <table border="1" style="width:50%; text-align:center;">
        <tr>
            <th>총자금</th>
            <th>유동자금</th>
            <th>총수익</th>
            <th>총비용</th>
        </tr>
        <tr>
            <td>${asset.totalAssets}</td>
            <td>${asset.currentAssets}</td>
            <td>${asset.totalEarning}</td>
            <td>${asset.totalCost}</td>
        </tr>
    </table>
</div>

<%@ include file="footer.jsp" %>