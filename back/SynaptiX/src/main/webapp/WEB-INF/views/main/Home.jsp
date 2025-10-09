<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%request.setAttribute("pageTitle", "대시보드");%>
<%request.setAttribute("active_main", "active");%>
<%request.setAttribute("active_mains", "sales");%>
<link rel="stylesheet" href="/css/home.css?v=7">
<%@ include file="../common/header.jsp" %>

<main class="container">

	<section class="grid-top">
		<div class="card card-wide">
		  <div class="card-header">
	
		    <div class="chart-tabs" role="tablist" aria-label="매출 탭">
		      <button type="button" class="chart-tab on" data-target="quarterly" aria-selected="true">분기 매출</button>
		      <button type="button" class="chart-tab" data-target="yearly"  aria-selected="false">연 매출</button>
		    </div>
		  </div>

		  <!-- 분기 매출 -->
		  <div class="chartbox on" id="sales-quarterly" role="tabpanel" aria-label="분기 매출">
		    <canvas id="salesQuarterlyChart" height="320"></canvas>
		  </div>

		  <!-- 연 매출 -->
		  <div class="chartbox" id="sales-yearly" role="tabpanel" aria-label="연 매출">
		    <canvas id="salesYearlyChart" height="440"></canvas>
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
// ===== 차트 옵션 및 생성 함수: 최상단에 선언 =====
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
            return ctx.dataset.label + ': ' + Number(v).toLocaleString();
          }
        }
      }
    },
    scales:{
      x:{grid:{display:false},ticks:{color:'#8A93A3'}},
      y:{
        beginAtZero:true, grid:{color:'#EEF1F7'}, ticks:{color:'#8A93A3', precision:0, maxTicksLimit:10},
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
          label:'전년 분기 대비',
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

// 2022, 2023년 분기별 매출총이익 DART API에서 받아와 차트에 반영 (누적값 → 실제 분기값, 전년 대비 증감률 포함)
(function(){
  const quarters = [
    { code: "11013", name: "1분기" },
    { code: "11012", name: "2분기" },
    { code: "11014", name: "3분기" },
    { code: "11011", name: "4분기" }
  ];
  let quarterLabels = quarters.map(q => q.name);
  let cumulativeSales2022 = [0, 0, 0, 0]; // 2022년 누적값
  let cumulativeSales2023 = [0, 0, 0, 0]; // 2023년 누적값
  let cumulativeSales2024 = [0, 0, 0, 0]; // 2024년 누적값
  let quarterSales2023 = [0, 0, 0, 0];    // 2023년 실제 분기별 값
  let quarterSales2024 = [0, 0, 0, 0];    // 2024년 실제 분기별 값
  let quarterYoY = [0, 0, 0, 0];          // 전년 대비 증감률(%)

  // 2022, 2023년 분기별 매출총이익 누적값 받아오기
  Promise.all([
    // 2023년
    ...quarters.map((q, idx) =>
      fetch('/home/dart/data?bsnsYear=2023&reprtCode=' + q.code)
        .then(res => res.json())
        .then(data => {
          if (data.list && Array.isArray(data.list)) {
            let item = data.list.find(i => i.account_nm === "매출총이익");
            if (item && item.thstrm_amount) {
              cumulativeSales2023[idx] = parseFloat(item.thstrm_amount.replace(/,/g, ''));
            }
          }
        })
        .catch(() => { cumulativeSales2023[idx] = 0; })
    ),
    // 2024년
    ...quarters.map((q, idx) =>
      fetch('/home/dart/data?bsnsYear=2024&reprtCode=' + q.code)
        .then(res => res.json())
        .then(data => {
          if (data.list && Array.isArray(data.list)) {
            let item = data.list.find(i => i.account_nm === "매출총이익");
            if (item && item.thstrm_amount) {
              cumulativeSales2024[idx] = parseFloat(item.thstrm_amount.replace(/,/g, ''));
            }
          }
        })
        .catch(() => { cumulativeSales2024[idx] = 0; })
    )
  ]).then(() => {
    // 누적값 → 실제 분기별 값으로 변환 (1~3분기는 그대로, 4분기만 누적값에서 1~3분기 빼기)
    for (let i = 0; i < 3; i++) {
      quarterSales2023[i] = cumulativeSales2023[i];
      quarterSales2024[i] = cumulativeSales2024[i];
    }
    quarterSales2023[3] = cumulativeSales2023[3] - cumulativeSales2023[2] - cumulativeSales2023[1] - cumulativeSales2023[0];
    quarterSales2024[3] = cumulativeSales2024[3] - cumulativeSales2024[2] - cumulativeSales2024[1] - cumulativeSales2024[0];

    // 데이터 확인용 콘솔 출력
    console.log('quarterSales2023:', quarterSales2023);
    console.log('quarterSales2024:', quarterSales2024);

    // 전년분기대비 그래프에 전년도 값(quarterSales2023) 사용
    var quarterlyChart = makeBarLineChart(
      document.getElementById('salesQuarterlyChart'), quarterLabels, quarterSales2024, quarterSales2023, ''
    );
    // 탭 전환
    var tabs = document.querySelectorAll('.chart-tab');
    function showTab(key){
      document.getElementById('sales-quarterly').classList.toggle('on', key==='quarterly');
      document.getElementById('sales-yearly').classList.toggle('on',  key==='yearly');
      tabs.forEach(function(t){
        var on = (t.dataset.target===key);
        t.classList.toggle('on', on);
        t.setAttribute('aria-selected', on ? 'true' : 'false');
      });
      setTimeout(function(){
        if(key==='quarterly') {
          quarterlyChart.resize();
        } else {
          yearlyChart.resize();
        }
      }, 30);
    }
    tabs.forEach(function(btn){
      btn.addEventListener('click', function(){ showTab(btn.dataset.target); });
    });
  });

  // 연 매출 차트: 2020~2024 데이터로 변경
  var yearLabels  = ['2020','2021','2022','2023','2024'];
  var yearSales   = [0, 0, 0, 0, 0];  // 2020~2024 연 매출 데이터 (API에서 받아올 값)
  var yearYoY     = [0, 0, 0, 0, 0];  // 2020~2024 전년 대비 증감(지표값, 필요시 계산)

  // 2020~2024 연 매출 데이터 API 호출 및 차트 반영
  Promise.all([
    ...[2020,2021,2022,2023,2024].map((year, idx) =>
      fetch('/home/dart/data?bsnsYear=' + year + '&reprtCode=11011')
        .then(res => res.json())
        .then(data => {
          if (data.list && Array.isArray(data.list)) {
            let item = data.list.find(i => i.account_nm === "매출총이익");
            if (item && item.thstrm_amount) {
              yearSales[idx] = parseFloat(item.thstrm_amount.replace(/,/g, ''));
            }
          }
        })
        .catch(() => { yearSales[idx] = 0; })
    )
  ]).then(() => {
    // 필요시 증감률 계산 (주석처리)
    // for (let i = 1; i < yearSales.length; i++) {
    //   if (yearSales[i-1] > 0) {
    //     yearYoY[i] = ((yearSales[i] - yearSales[i-1]) / yearSales[i-1]) * 100;
    //   } else {
    //     yearYoY[i] = 0;
    //   }
    // }
    // 데이터 확인용 콘솔 출력
    console.log('yearSales:', yearSales);
    // 연 매출 차트 생성 (전년도분기 그래프 제거, 바 그래프만 표시)
    yearlyChart = new Chart(
      document.getElementById('salesYearlyChart').getContext('2d'), {
        type: 'bar',
        data: {
          labels: yearLabels,
          datasets: [
            {
              label: '매출',
              data: yearSales,
              backgroundColor: '#5b7cff',
              borderRadius: 6,
              barThickness: 26
            }
          ]
        },
        options: makeOptions('')
      }
    );
  });
})();

// DART API 데이터 프론트 콘솔 출력 (2019~2023 각 분기별 매출총이익, 정렬된 순서로 출력)
function fetchDartData(bsnsYear, reprtCode, quarterName) {
  let url = '/home/dart/data?bsnsYear=' + bsnsYear + '&reprtCode=' + reprtCode;
  return fetch(url)
    .then(res => res.json())
    .then(data => {
      let result = {
        year: bsnsYear,
        quarter: quarterName,
        reprtCode: reprtCode,
        item: null,
        raw: data
      };
      if (data.list && Array.isArray(data.list)) {
        data.list.forEach(item => {
          if (item.account_nm === "매출총이익") {
            result.item = item;
          }
        });
      }
      return result;
    })
    .catch(err => {
      return {
        year: bsnsYear,
        quarter: quarterName,
        reprtCode: reprtCode,
        item: null,
        error: err
      };
    });
}

// 2019~2023년 각 분기 반복 호출, 결과 정렬 후 출력
(function(){
  const quarters = [
    { code: "11013", name: "1분기" },
    { code: "11012", name: "2분기" },
    { code: "11014", name: "3분기" },
    { code: "11011", name: "4분기" }
  ];
  let promises = [];
  for (let year = 2019; year <= 2023; year++) {
    quarters.forEach(q => {
      promises.push(fetchDartData(year.toString(), q.code, q.name));
    });
  }
  Promise.all(promises).then(results => {
    // 연도 오름차순, 분기 순서대로 정렬
    results.sort((a, b) => {
      if (a.year !== b.year) return a.year - b.year;
      return quarters.findIndex(q => q.name === a.quarter) - quarters.findIndex(q => q.name === b.quarter);
    });
    results.forEach(r => {
      if (r.item) {
        console.log(`[${r.year} ${r.quarter} 매출총이익]`, r.item);
      } else if (r.error) {
        console.error(`[DART API 오류 ${r.year} ${r.quarter}]`, r.error);
      } else {
        console.log(`[${r.year} ${r.quarter}] 매출총이익 데이터 없음`, r.raw);
      }
    });
  });
})();
</script>


<%@ include file="../common/footer.jsp" %>