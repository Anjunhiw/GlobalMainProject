<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%request.setAttribute("pageTitle", "대시보드");%>
<%request.setAttribute("active_main", "active");%>
<%request.setAttribute("active_mains", "costs");%>
<link rel="stylesheet" href="/css/home.css?v=7">
<style>
/* ===== 캘린더 디자인 개선 ===== */
.calendar {
  width: 100%;
  border-collapse: separate;
  border-spacing: 0;
  background: #f8fafd;
  box-shadow: 0 1px 4px rgba(90,110,130,0.07);
  border-radius: 10px;
  font-size: 15px;
  margin-bottom: 12px;
}
.calendar th, .calendar td {
  width: 14.28%;
  height: 38px;
  text-align: center;
  border: none;
  position: relative;
}
.calendar th {
  background: #eaf0fa;
  color: #5b7cff;
  font-weight: 600;
  border-bottom: 1px solid #e0e6ed;
  letter-spacing: 1px;
}
.calendar td {
  background: #fff;
  color: #222;
  transition: background 0.2s, color 0.2s;
  cursor: pointer;
  border-radius: 6px;
}
.calendar td.today {
  background: #5b7cff;
  color: #fff;
  font-weight: bold;
  box-shadow: 0 2px 8px rgba(91,124,255,0.08);
}
.calendar td.sun, .calendar th.sun {
  color: #f44a4a;
}
.calendar td:hover:not(.today) {
  background: #eaf0fa;
  color: #5b7cff;
}
.calendar-nav {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  margin-bottom: 4px;
}
.cal-title {
  font-size: 1.15em;
  font-weight: 600;
  color: #3a4a6b;
  letter-spacing: 1px;
  padding: 0 8px;
}
.cal-nav-btn {
  background: #eaf0fa;
  border: none;
  color: #5b7cff;
  font-size: 1.3em;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  cursor: pointer;
  transition: background 0.2s, color 0.2s;
}
.cal-nav-btn:hover {
  background: #5b7cff;
  color: #fff;
}
</style>
<%@ include file="../common/header.jsp" %>
<main class="container">
<section class="dashboard-grid">

  <div class="card card-wide">
    <div class="card-header">
      <div class="chart-tabs" role="tablist" aria-label="비용 탭">
        <button type="button" class="chart-tab on" data-target="quarterly" aria-selected="true">분기 비용</button>
        <button type="button" class="chart-tab" data-target="yearly" aria-selected="false">연 비용</button>
      </div>
    </div>
    <!-- 분기 비용 -->
    <div class="chartbox on" id="costs-quarterly" role="tabpanel" aria-label="분기 비용">
      <canvas id="costsQuarterlyChart" height="320"></canvas>
    </div>
    <!-- 연 비용 -->
    <div class="chartbox" id="costs-yearly" role="tabpanel" aria-label="연 비용">
      <canvas id="costsYearlyChart" height="440"></canvas>
    </div>
  </div>

  <!-- 달력 카드 -->
  <div class="card">
    <div class="card-header">
      <div class="calendar-nav">
        <button class="cal-nav-btn" id="prevMonthBtn">‹</button>
        <span class="cal-title" id="calTitle"></span>
        <button class="cal-nav-btn" id="nextMonthBtn">›</button>
      </div>
    </div>
    <div class="card-body">
      <table class="calendar" id="calendar">
        <thead>
          <tr><th>MON</th><th>TUE</th><th>WED</th><th>THU</th><th>FRI</th><th>SAT</th><th class="sun">SUN</th></tr>
        </thead>
        <tbody id="calendarBody"><!-- JS가 채움 --></tbody>
      </table>

      <div class="note-box">
        <h5>안내 (환율, 조회, 메모, 연차 등) 입력</h5>
        <ul class="small">
          <li>사전 신청 원칙: 최소 3일 전까지 신청해야 승인 가능합니다. (긴급 사유는 부서장 승인 필요)</li>
          <li>승인 절차: 신청 후 반드시 부서장 또는 담당자의 승인을 받아야 최종 확정됩니다.</li>
		  <li>중복/인원 제한: 동일 부서 내 동일 일자 중복 신청은 인원 제한이 있을 수 있습니다.</li>
		  <li>반차·조퇴 구분: 오전 반차, 오후 반차, 조퇴 등은 반드시 구분을 명확히 기재해주세요.</li>
		  <li>업무 인수인계: 휴가 전, 담당 업무는 인수인계 후 신청 가능합니다.</li>
		  <li>취소/변경: 이미 승인된 연차라도, 취소/변경 시에는 즉시 담당자에게 통보해야 합니다.</li>
		  <li>연차 소진 확인: 개인별 잔여 연차 일수 확인 후 신청해주시기 바랍니다.</li>
        </ul>
      </div>
	  <div class="inline-input">
	         <input type="text" placeholder="비고/메모 입력" id="memoInput">
	         <button class="btn btn-success" id="memoSave">확인</button>
	       </div>

      <div class="inline-input mt-8">
        <input type="text" placeholder="비용 제목" id="costTitle">
        <input type="number" placeholder="금액" id="costAmount">
        <button class="btn btn-primary" id="costAdd">등록</button>
      </div>
    </div>
  </div>

  <!-- 비용 요약 + 월별 비용표 -->
  <div class="card">
    <div class="card-body">
      <div class="pill-row">
        <div class="pill">
          <div class="pill-title">이번 달 예상 지출 비용</div>
          <div class="pill-value">
            ₩ <fmt:formatNumber value="${thisMonthCost}" type="number"/>
          </div>
        </div>
        <div class="pill pale">
          <div class="pill-title">지난 달 지출 비용</div>
          <div class="pill-value">
            ₩ <fmt:formatNumber value="${lastMonthCost}" type="number"/>
          </div>
        </div>
      </div>

      <div class="table-title">월별 데이터</div>
      <table class="table compact">
        <thead>
          <tr><th>기간</th><th class="right">지출 비용</th></tr>
        </thead>
        <tbody>
          <c:forEach var="row" items="${monthlyCosts}">
            <tr>
              <td>
                <fmt:formatDate value="${row.start}" pattern="yyyy-MM-dd"/>
                &nbsp;~&nbsp;
                <fmt:formatDate value="${row.end}" pattern="yyyy-MM-dd"/>
              </td>
              <td class="right">₩ <fmt:formatNumber value="${row.amount}" type="number"/></td>
            </tr>
          </c:forEach>
          <c:if test="${empty monthlyCosts}">
            <tr><td colspan="2" class="center muted">표시할 데이터가 없습니다.</td></tr>
          </c:if>
        </tbody>
      </table>
    </div>
  </div>
</section>


<!-- 기존 모든 <script> 태그 주석 처리 -->
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
<script>
// ===== 차트 옵션 및 생성 함수: Home.jsp와 동일하게 선언 =====
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
          label:'비용',
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

// ===== DART API 판관비 데이터 받아와서 차트 생성 및 탭 전환 =====
(function(){
  const quarters = [
    { code: "11013", name: "1분기" },
    { code: "11012", name: "2분기" },
    { code: "11014", name: "3분기" },
    { code: "11011", name: "4분기" }
  ];
  let quarterLabels = quarters.map(q => q.name);
  let cumulativeCosts2023 = [0, 0, 0, 0];
  let cumulativeCosts2024 = [0, 0, 0, 0];
  let quarterCosts2023 = [0, 0, 0, 0];
  let quarterCosts2024 = [0, 0, 0, 0];
  let quarterlyChart = null;
  let yearlyChart = null;

  Promise.all([
    // 2023년 분기별
    ...quarters.map((q, idx) =>
      fetch('/home/dart/data?bsnsYear=2023&reprtCode=' + q.code)
        .then(res => res.json())
        .then(data => {
          if (data.list && Array.isArray(data.list)) {
            let item = data.list.find(i => i.account_nm === "판매비와관리비");
            if (item && item.thstrm_amount) {
              cumulativeCosts2023[idx] = parseFloat(item.thstrm_amount.replace(/,/g, ''));
            }
          }
        })
        .catch(() => { cumulativeCosts2023[idx] = 0; })
    ),
    // 2024년 분기별
    ...quarters.map((q, idx) =>
      fetch('/home/dart/data?bsnsYear=2024&reprtCode=' + q.code)
        .then(res => res.json())
        .then(data => {
          if (data.list && Array.isArray(data.list)) {
            let item = data.list.find(i => i.account_nm === "판매비와관리비");
            if (item && item.thstrm_amount) {
              cumulativeCosts2024[idx] = parseFloat(item.thstrm_amount.replace(/,/g, ''));
            }
          }
        })
        .catch(() => { cumulativeCosts2024[idx] = 0; })
    )
  ]).then(() => {
    for (let i = 0; i < 3; i++) {
      quarterCosts2023[i] = cumulativeCosts2023[i];
      quarterCosts2024[i] = cumulativeCosts2024[i];
    }
    quarterCosts2023[3] = cumulativeCosts2023[3] - cumulativeCosts2023[2] - cumulativeCosts2023[1] - cumulativeCosts2023[0];
    quarterCosts2024[3] = cumulativeCosts2024[3] - cumulativeCosts2024[2] - cumulativeCosts2024[1] - cumulativeCosts2024[0];
    // 데이터 확인용 콘솔 출력
    console.log('2023년 분기별 판매비와관리비:', quarterCosts2023);
    console.log('2024년 분기별 판매비와관리비:', quarterCosts2024);
    // 차트 생성 (데이터 준비된 후)
    quarterlyChart = makeBarLineChart(
      document.getElementById('costsQuarterlyChart'),
      quarterLabels,
      quarterCosts2024,
      quarterCosts2023,
      ''
    );
    // 연비용(2020~2024) 판관비 데이터 처리 및 차트 생성
    var yearLabels = ['2020','2021','2022','2023','2024'];
    var yearCosts = [0, 0, 0, 0, 0];
    Promise.all([
      ...[2020,2021,2022,2023,2024].map((year, idx) =>
        fetch('/home/dart/data?bsnsYear=' + year + '&reprtCode=11011')
          .then(res => res.json())
          .then(data => {
            if (data.list && Array.isArray(data.list)) {
              let item = data.list.find(i => i.account_nm === "판매비와관리비");
              if (item && item.thstrm_amount) {
                yearCosts[idx] = parseFloat(item.thstrm_amount.replace(/,/g, ''));
              }
            }
          })
          .catch(() => { yearCosts[idx] = 0; })
      )
    ]).then(() => {
      // 데이터 확인용 콘솔 출력
      console.log('2020~2024년 연간 판관비:', yearCosts);
      // 연비용 차트 생성 (Home.jsp와 동일하게)
      yearlyChart = new Chart(
        document.getElementById('costsYearlyChart').getContext('2d'), {
          type: 'bar',
          data: {
            labels: yearLabels,
            datasets: [
              {
                label: '비용',
                data: yearCosts,
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
    // 탭 전환 기능 (Home.jsp와 동일)
    var tabs = document.querySelectorAll('.chart-tab');
    function showTab(key){
      document.getElementById('costs-quarterly').classList.toggle('on', key==='quarterly');
      document.getElementById('costs-yearly').classList.toggle('on',  key==='yearly');
      tabs.forEach(function(t){
        var on = (t.dataset.target===key);
        t.classList.toggle('on', on);
        t.setAttribute('aria-selected', on ? 'true' : 'false');
      });
      setTimeout(function(){
        if(key==='quarterly' && quarterlyChart) {
          quarterlyChart.resize();
        }
        if(key==='yearly' && yearlyChart) {
          yearlyChart.resize();
        }
      }, 30);
    }
    tabs.forEach(function(btn){
      btn.addEventListener('click', function(){ showTab(btn.dataset.target); });
    });
  });
})();

// ===== 캘린더 기능 추가 =====
(function(){
  const calendarBody = document.getElementById('calendarBody');
  const calTitle = document.getElementById('calTitle');
  const prevBtn = document.getElementById('prevMonthBtn');
  const nextBtn = document.getElementById('nextMonthBtn');

  let today = new Date();
  let currentYear = today.getFullYear();
  let currentMonth = today.getMonth(); // 0-indexed

  function renderCalendar(year, month) {
    // month: 0-indexed
    calTitle.textContent = year + '년 ' + (month+1) + '월';
    calendarBody.innerHTML = '';
    let firstDay = new Date(year, month, 1);
    let lastDay = new Date(year, month+1, 0);
    let startDay = firstDay.getDay(); // 0: Sunday, 1: Monday, ...
    // Adjust startDay to Monday=0, Sunday=6
    startDay = (startDay === 0) ? 6 : startDay - 1;
    let totalDays = lastDay.getDate();
    let row = document.createElement('tr');
    // Fill empty cells before first day
    for(let i=0; i<startDay; i++) {
      let cell = document.createElement('td');
      row.appendChild(cell);
    }
    for(let date=1; date<=totalDays; date++) {
      let cell = document.createElement('td');
      cell.textContent = date;
      // Highlight today
      if(year === today.getFullYear() && month === today.getMonth() && date === today.getDate()) {
        cell.classList.add('today');
      }
      // Sunday class
      let cellDay = (startDay + date - 1) % 7;
      if(cellDay === 6) cell.classList.add('sun');
      row.appendChild(cell);
      if(cellDay === 6 && date !== totalDays) {
        calendarBody.appendChild(row);
        row = document.createElement('tr');
      }
    }
    // Fill empty cells after last day
    let lastCellDay = (startDay + totalDays - 1) % 7;
    if(lastCellDay !== 6) {
      for(let i=lastCellDay+1; i<=6; i++) {
        let cell = document.createElement('td');
        row.appendChild(cell);
      }
    }
    calendarBody.appendChild(row);
  }

  function changeMonth(diff) {
    currentMonth += diff;
    if(currentMonth < 0) {
      currentMonth = 11;
      currentYear--;
    } else if(currentMonth > 11) {
      currentMonth = 0;
      currentYear++;
    }
    renderCalendar(currentYear, currentMonth);
  }

  prevBtn.addEventListener('click', function(){ changeMonth(-1); });
  nextBtn.addEventListener('click', function(){ changeMonth(1); });

  renderCalendar(currentYear, currentMonth);
})();
</script>

<%@ include file="../common/footer.jsp" %>