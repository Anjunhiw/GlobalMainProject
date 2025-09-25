<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%request.setAttribute("pageTitle", "대시보드");%>
<%request.setAttribute("active_main", "active");%>
<%request.setAttribute("active_mains", "production");%>
<link rel="stylesheet" href="/css/home.css?v=7">
<link rel="stylesheet" href="<c:url value='/css/production-status.css?v=1'/>">	


<%@ include file="../common/header.jsp" %>

<main class="container">

<section class="prod-wrap">
  <!-- 상단 3개 카드 -->
  <div class="row row-3">
    <div class="card">
      <div class="card-head">
        <div class="title">생산 달성률</div>
        <div class="sub">단위: 상반</div>
      </div>
      <div class="card-body">
        <canvas id="barTarget"></canvas>
      </div>
    </div>

    <div class="card">
      <div class="card-head">
        <div class="title">라인별 가동률</div>
      </div>
      <div class="card-body">
        <canvas id="barLine"></canvas>
      </div>
    </div>

    <div class="card">
      <div class="card-head">
        <div class="title">납기 준수율</div>
      </div>
      <div class="card-body">
        <canvas id="barOnTime"></canvas>
      </div>
    </div>
  </div>

  <!-- 하단 2개 카드 -->
  <div class="row row-2">
    <div class="card">
      <div class="card-head center">
        <div class="title">불량률</div>
      </div>
      <div class="card-body center">
        <canvas id="donutDefect" height="180"></canvas>
      </div>
    </div>

    <div class="card">
      <div class="card-head center">
        <div class="title">원자재 사용량</div>
        <div class="sub small">(단위: 천장, 전분기, 현분기, 목표)</div>
      </div>
      <div class="card-body">
        <canvas id="barMaterial"></canvas>
      </div>
    </div>
  </div>
</section>
</main>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
<script>
/* ---------- 공통 옵션 ---------- */
const gridColor = '#eef2f7';
const tickColor = '#6b7280';
const fontFamily = "'Inter', 'Pretendard',  system-ui, -apple-system";

/* ---------- 생산 달성률 (목표 vs 실적) ---------- */
(() => {
  const el = document.getElementById('barTarget');
  if(!el) return;
  new Chart(el, {
    type: 'bar',
    data: {
      labels: ['목표','실적'],
      datasets: [{
        data: [40, 35],
        backgroundColor: ['#f59e0b', '#10b981'],
        borderRadius: 8,
        barThickness: 38
      }]
    },
    options: {
      plugins: { legend: { display: false }, tooltip: { enabled: true } },
      scales: {
        x: { grid: { display: false }, ticks: { color: tickColor, font: { family: fontFamily } } },
        y: { grid: { color: gridColor }, ticks: { beginAtZero: true, color: tickColor } }
      }
    }
  });
})();

/* ---------- 라인별 가동률 (A/B라인) ---------- */
(() => {
  const el = document.getElementById('barLine');
  if(!el) return;
  new Chart(el, {
    type: 'bar',
    data: {
      labels: ['A라인','B라인'],
      datasets: [{
        label: '가동률',
        data: [95, 87],
        backgroundColor: ['#3b82f6','#f59e0b'],
        borderRadius: 8,
        barThickness: 40
      }]
    },
    options: {
      plugins: { legend: { display: false } },
      scales: {
        x: { grid: { display: false }, ticks: { color: tickColor } },
        y: { grid: { color: gridColor }, ticks: { beginAtZero: true, max: 100, stepSize: 20, color: tickColor } }
      }
    }
  });
})();

/* ---------- 납기 준수율 ---------- */
(() => {
  const el = document.getElementById('barOnTime');
  if(!el) return;
  new Chart(el, {
    type: 'bar',
    data: {
      labels: ['납기'],
      datasets: [{
        label: '준수율',
        data: [96],
        backgroundColor: '#fb923c',
        borderRadius: 8,
        barThickness: 60
      }]
    },
    options: {
      plugins: { legend: { display: false } },
      scales: {
        x: { grid: { display: false }, ticks: { color: tickColor } },
        y: { grid: { color: gridColor }, ticks: { beginAtZero: true, max: 100, stepSize: 20, color: tickColor } }
      }
    }
  });
})();

/* ---------- 불량률 (도넛) ---------- */
(() => {
  const el = document.getElementById('donutDefect');
  if(!el) return;
  new Chart(el, {
    type: 'doughnut',
    data: {
      labels: ['정상','불량'],
      datasets: [{
        data: [98.8, 1.2],
        backgroundColor: ['#0ea5e9','#6d28d9'],
        borderWidth: 0
      }]
    },
    options: {
      cutout: '70%',
      plugins: {
        legend: { position: 'top', labels: { color: tickColor } },
        tooltip: { callbacks: { label: ctx => ctx.label + ' : ' + ctx.parsed + '%' } }
      }
    }
  });
})();

/* ---------- 원자재 사용량 (그룹 바: 전분기/현분기/목표) ---------- */
(() => {
  const el = document.getElementById('barMaterial');
  if(!el) return;
  new Chart(el, {
    type: 'bar',
    data: {
      labels: ['삼성 곡면 패널', '방수수지', '알루미늄 프레임', '내열 접착제', '납기용 지브라'],
      datasets: [
        { label: '전분기', data: [1350, 820, 610, 490, 860], backgroundColor:'#ef4444', borderRadius:6, barThickness: 16 },
        { label: '현분기', data: [1280, 790, 560, 430, 840], backgroundColor:'#0ea5e9', borderRadius:6, barThickness: 16 },
        { label: '목표',   data: [1300, 750, 520, 400, 850], backgroundColor:'#10b981', borderRadius:6, barThickness: 16 }
      ]
    },
    options: {
      plugins: { legend: { position: 'top' } },
      responsive: true,
      scales: {
        x: { stacked: false, grid: { display:false }, ticks: { color: tickColor } },
        y: { stacked: false, grid: { color: gridColor }, ticks: { beginAtZero:true, color: tickColor } }
      }
    }
  });
})();
</script>

<%@ include file="../common/footer.jsp" %>