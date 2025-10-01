<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%request.setAttribute("pageTitle", "대시보드");%>
<%request.setAttribute("active_main", "active");%>
<%request.setAttribute("active_mains", "sales	");%>
<link rel="stylesheet" href="/css/home.css?v=7">
<%@ include file="../common/header.jsp" %>

<main class="container">

	<section class="grid-top">
		<div class="card card-wide">
		  <div class="card-header">
	
		    <div class="chart-tabs" role="tablist" aria-label="매출 탭">
		      <button type="button" class="chart-tab on" data-target="monthly" aria-selected="true">월 매출</button>
		      <button type="button" class="chart-tab" data-target="yearly"  aria-selected="false">연 매출</button>
		    </div>
		  </div>

		  <!-- 월 매출 -->
		  <div class="chartbox on" id="sales-monthly" role="tabpanel" aria-label="월 매출">
		    <canvas id="salesMonthlyChart" ></canvas>
		  </div>

		  <!-- 연 매출 -->
		  <div class="chartbox" id="sales-yearly" role="tabpanel" aria-label="연 매출">
		    <canvas id="salesYearlyChart"></canvas>
		  </div>
		</div>



	
	
  <!-- 중간 2열 -->
  <section class="grid-mid">

  
    <!-- 실시간 매출 현황 -->
    <div class="card linecard">
      <div class="title">
        <div>실시간 매출 현황</div>
        <div class="small">10시 ~ 13시대 변화</div>
      </div>
      <div class="total">123,900원</div>
      <div class="chart-wrap">
        <svg id="line" viewBox="0 0 500 180" preserveAspectRatio="none">
          <defs>
            <linearGradient id="grad1" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stop-color="#8aa6ff" stop-opacity="0.45"/>
              <stop offset="100%" stop-color="#8aa6ff" stop-opacity="0"/>
            </linearGradient>
          </defs>
          <path class="area" d="M0,150 L80,120 L180,140 L300,80 L420,120 L500,100 L500,180 L0,180 Z"></path>
          <path class="stroke" d="M0,150 L80,120 L180,140 L300,80 L420,120 L500,100"></path>
          <circle class="dot" cx="80" cy="120" r="4"></circle>
          <circle class="dot" cx="180" cy="140" r="4"></circle>
          <circle class="dot" cx="300" cy="80" r="4"></circle>
          <circle class="dot" cx="420" cy="120" r="4"></circle>
          <circle class="dot" cx="500" cy="100" r="4"></circle>
        </svg>
      </div>
    </div>


  <!-- 알림 -->
  <section class="alerts card">
    <div class="head">
      <div class="bell">
        <svg viewBox="0 0 24 24" fill="currentColor">
          <path d="M12 2a6 6 0 00-6 6v3.09c0 .42-.17.82-.46 1.12L4 14h16l-1.54-1.79c-.29-.3-.46-.7-.46-1.12V8a6 6 0 00-6-6z"/>
          <path d="M15 17a3 3 0 11-6 0h6z" opacity=".7"/>
        </svg>
      </div>
      <div style="font-weight:800;">알림 <span class="small">(판매 알림, 정비 등)</span></div>
    </div>
    <div class="hr"></div>
    <div class="list">
      <div class="item"><div class="small">2025.09.01</div><div class="type warn">오류</div><div>******************</div></div>
      <div class="item"><div class="small">2025.08.28</div><div class="type warn">오류</div><div>******************</div></div>
      <div class="item"><div class="small">2025.08.28</div><div class="type info">알림</div><div>실시간 매출현황 변동</div></div>
      <div class="item"><div class="small">2025.08.27</div><div class="type info">알림</div><div>******************</div></div>
      <div class="item"><div class="small">2025.08.25</div><div class="type warn">오류</div><div>******************</div></div>
      <div class="item"><div class="small">2025.08.25</div><div class="type warn">오류</div><div>******************</div></div>
   
	  </div>
  </section>
  </section>

</main>







<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
<script>
(function(){
  // ===== 데이터(예시) — 서버 값으로 교체만 하면 됩니다. =====
  var monthLabels = ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'];
  var monthSales  = [12.1, 7.8, 2.9, 17.6, 21.8, 14.9, 22.0, 16.7, 9.6, 24.9, 8.8, 13.9]; // 막대: 월 매출
  var monthYoY    = [7.4, 5.3, 3.7, 8.5, 12.0, 10.8, 18.8, 14.2, 11.6, 12.7, 9.9, 10.7];   // 라인: 전년 월 대비

  var yearLabels  = ['2021','2022','2023'];
  var yearSales   = [180, 210, 248];  // 막대: 연 매출(억원 예시)
  var yearYoY     = [10, 12.5, 14.8]; // 라인: 전년 대비 증감(지표값)

  // 공통 옵션(JSP 안전: 문자열 더하기)
  function makeOptions(yTitle){
    return {
      responsive:true, maintainAspectRatio:false,
      layout:{padding:{top:6,left:8,right:12,bottom:0}},
      plugins:{
        legend:{display:true,position:'bottom',labels:{boxWidth:18,boxHeight:8}},
        tooltip:{
          callbacks:{
            label:function(ctx){
              var v = ctx.parsed.y || 0;
              // 단위 표기는 상황에 맞게 교체
              return ctx.dataset.label + ': ' + Number(v).toLocaleString();
            }
          }
        }
      },
      scales:{
        x:{grid:{display:false},ticks:{color:'#8A93A3'}},
        y:{
          beginAtZero:true, grid:{color:'#EEF1F7'}, ticks:{color:'#8A93A3', precision:0},
          title: yTitle ? {display:true,text:yTitle,color:'#8A93A3'} : undefined
        }
      }
    };
  }

  function makeBarLineChart(canvas, labels, barData, lineData, yTitle){
    var ctx = canvas.getContext('2d');
    return new Chart(ctx, {
      type:'bar',
      data:{
        labels: labels,
        datasets:[
          {
            type:'bar',
            label:'매출',
            data: barData,
            backgroundColor:'#5b7cff',
            borderRadius:6,
            barThickness:26
          },
          {
            type:'line',
            label:'전년 월 대비',
            data: lineData,
            borderColor:'#f4a63a',
            pointBackgroundColor:'#f4a63a',
            pointRadius:3,
            tension:.35,
            fill:false
          }
        ]
      },
      options: makeOptions(yTitle)
    });
  }

  // 차트 인스턴스
  var monthlyChart = makeBarLineChart(
    document.getElementById('salesMonthlyChart'), monthLabels, monthSales, monthYoY, ''
  );
  var yearlyChart = makeBarLineChart(
    document.getElementById('salesYearlyChart'), yearLabels, yearSales, yearYoY, ''
  );

  // 탭 전환
  var tabs = document.querySelectorAll('.chart-tab');
  function showTab(key){
    document.getElementById('sales-monthly').classList.toggle('on', key==='monthly');
    document.getElementById('sales-yearly').classList.toggle('on',  key==='yearly');
    tabs.forEach(function(t){
      var on = (t.dataset.target===key);
      t.classList.toggle('on', on);
      t.setAttribute('aria-selected', on ? 'true' : 'false');
    });
    setTimeout(function(){
      if(key==='monthly') monthlyChart.resize(); else yearlyChart.resize();
    }, 30);
  }
  tabs.forEach(function(btn){
    btn.addEventListener('click', function(){ showTab(btn.dataset.target); });
  });
})();
</script>


<%@ include file="../common/footer.jsp" %>