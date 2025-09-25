<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%request.setAttribute("pageTitle", "대시보드");%>
<%request.setAttribute("active_main", "active");%>
<%request.setAttribute("active_mains", "hr");%>
<link rel="stylesheet" href="/css/home.css?v=7">
<link rel="stylesheet" href="<c:url value='/css/hr.css?v=1'/>">

<%@ include file="../common/header.jsp" %>
<main class="container">
<section class="hr-wrap">
  <!-- 총 인력 현황 -->
  <div class="card card-wide">
    <div class="card-head">
      <div>
        <div class="title">총 인력 현황</div>
        <div class="sub">조회기간 2024-03 ~ 2025-05</div>
      </div>
      <div class="summary">
        <div class="big">3,200 <span class="unit">명</span></div>
        <div class="muted">전년 대비 <b class="pos">+4.9%</b> (150명 증가)</div>
      </div>
    </div>
    <div class="card-body">
      <canvas id="barHeadcount" height="110"></canvas>
    </div>
  </div>

  <div class="row">
    <!-- 인력구성 (정규/비정규/파견 등) -->
    <div class="card">
      <div class="card-head">
        <div class="title">인력구성</div>
        <div class="legend">
          <span class="dot blue"></span>정규직
          <span class="dot orange"></span>비정규직
          <span class="dot gray"></span>파견직
        </div>
      </div>
      <div class="card-body grid-2">
        <div class="note">
          정규직 점유율이 <b class="hi">70%</b>로 가장 높음
        </div>
        <canvas id="donutEmpType" height="140"></canvas>
      </div>
    </div>

    <!-- 구성원 성별 -->
    <div class="card">
      <div class="card-head">
        <div class="title">구성원</div>
        <div class="legend">
          <span class="dot indigo"></span>남성
          <span class="dot pink"></span>여성
        </div>
      </div>
      <div class="card-body grid-2">
        <div class="note">
          남성 비율이 <b class="hi">20%</b> 더 높으며,<br/>
          구성원 평균 연령 <b>36.8세</b>
        </div>
        <canvas id="donutGender" height="140"></canvas>
      </div>
    </div>
  </div>

  <!-- 급여 요약 -->
  <div class="row">
    <div class="card">
      <div class="card-head">
        <div class="title">월간 급여 요약</div>
        <div class="sub">최근 6개월</div>
      </div>
      <div class="card-body">
        <canvas id="linePayroll" height="110"></canvas>
      </div>
    </div>

    <div class="card">
      <div class="card-head">
        <div class="title">급여 통계(스냅샷)</div>
      </div>
      <div class="card-body">
        <table class="stat">
          <tbody>
            <tr><th>총 급여(월)</th><td>₩ 4,830,000,000</td></tr>
            <tr><th>평균 급여(월)</th><td>₩ 3,210,000</td></tr>
            <tr><th>중위 급여(월)</th><td>₩ 3,000,000</td></tr>
            <tr><th>수당 비중</th><td>11.4%</td></tr>
            <tr><th>OT 비중</th><td>6.8%</td></tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</section>
</main>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
<script>
  // 막대: 인력 추이
  (function(){
    const el = document.getElementById('barHeadcount'); if(!el) return;
    new Chart(el, {
      type:'bar',
      data:{
        labels:['24/03','24/04','24/05','24/06','24/07','24/08','24/09','24/10','24/11','24/12','25/01','02','03','04','05'],
        datasets:[
          {label:'남성', data:[2950,3050,3060,3070,3085,3095,3210,3230,3130,3140,3165,3170,3180,3190,3210], backgroundColor:'#5b7cff', borderRadius:6, barThickness:14},
          {label:'여성', data:[50,60,70,80,85,95,100,110,200,210,235,250,300,310,320], backgroundColor:'#b330b5', borderRadius:6, barThickness:14}
        ]
      },
      options:{
        plugins:{ legend:{display:false}},
        scales:{ x:{grid:{display:false}}, y:{grid:{color:'#eef2f7'}, ticks:{beginAtZero:true}}}
      }
    });
  })();

  // 도넛: 고용형태
  (function(){
    const el = document.getElementById('donutEmpType'); if(!el) return;
    new Chart(el, {
      type:'doughnut',
      data:{
        labels:['정규직','비정규직','파견직'],
        datasets:[{
          data:[70,20,10],
          backgroundColor:['#2b6ef6','#ff9f43','#cbd5e1'],
          borderWidth:0
        }]
      },
      options:{
        cutout:'64%',
        plugins:{ legend:{display:false}}
      }
    });
  })();

  // 도넛: 성별
  (function(){
    const el = document.getElementById('donutGender'); if(!el) return;
    new Chart(el, {
      type:'doughnut',
      data:{
        labels:['남성','여성'],
        datasets:[{
          data:[60,40],
          backgroundColor:['#4f46e5','#f43f5e'],
          borderWidth:0
        }]
      },
      options:{ cutout:'64%', plugins:{legend:{display:false}} }
    });
  })();

  // 선형: 월간 급여(최근 6개월)
  (function(){
    const el = document.getElementById('linePayroll'); if(!el) return;
    new Chart(el, {
      type:'line',
      data:{
        labels:['12월','01월','02월','03월','04월','05월'],
        datasets:[{
          label:'총 급여(억원)',
          data:[45.0, 46.2, 46.7, 47.1, 47.8, 48.3],
          borderColor:'#16a34a',
          backgroundColor:'rgba(22,163,74,.10)',
          tension:.35, pointRadius:3, fill:true
        }]
      },
      options:{
        plugins:{ legend:{display:false}},
        scales:{ x:{grid:{display:false}}, y:{grid:{color:'#eef2f7'}, ticks:{beginAtZero:false}}}
      }
    });
  })();
</script>




<%@ include file="../common/footer.jsp" %>