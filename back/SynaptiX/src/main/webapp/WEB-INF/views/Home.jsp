<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
request.setAttribute("pageTitle", "대시보드");
%>
<%@ include file="header.jsp" %>
<link rel="stylesheet" href="<c:url value='/css/home.css'/>">
<div class="dashboard-container">
    <div class="dashboard-header">
        <div>
            <h2>대시보드</h2>
            <div style="color:#888; font-size:0.95em;">오늘 날짜: <%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %></div>
        </div>
    </div>
    <div class="dashboard-charts">
        <div class="dashboard-chart-box">
            <h3>월별 매출(더미)</h3>
            <canvas id="barChart" width="400" height="200"></canvas>
        </div>
        <div class="dashboard-chart-box">
            <h3>제품별 비율(더미)</h3>
            <canvas id="pieChart" width="400" height="200"></canvas>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
// 막대그래프(월별 매출 더미)
const barCtx = document.getElementById('barChart').getContext('2d');
new Chart(barCtx, {
    type: 'bar',
    data: {
        labels: ['1월', '2월', '3월', '4월', '5월', '6월'],
        datasets: [{
            label: '매출(만원)',
            data: [120, 150, 180, 90, 200, 170],
            backgroundColor: 'rgba(54, 162, 235, 0.6)'
        }]
    },
    options: {
        responsive: true,
        plugins: { legend: { display: false } }
    }
});
// 원형그래프(제품별 비율 더미)
const pieCtx = document.getElementById('pieChart').getContext('2d');
new Chart(pieCtx, {
    type: 'pie',
    data: {
        labels: ['A제품', 'B제품', 'C제품'],
        datasets: [{
            data: [40, 35, 25],
            backgroundColor: [
                'rgba(255, 99, 132, 0.7)',
                'rgba(255, 206, 86, 0.7)',
                'rgba(75, 192, 192, 0.7)'
            ]
        }]
    },
    options: {
        responsive: true
    }
});
</script>
<%@ include file="footer.jsp" %>