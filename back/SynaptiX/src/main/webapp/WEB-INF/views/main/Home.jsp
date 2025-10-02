<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%request.setAttribute("pageTitle", "대시보드");%>
<%request.setAttribute("active_main", "active");%>
<%request.setAttribute("active_mains", "sales	");%>
<link rel="stylesheet" href="/css/home.css?v=7">
<%@ include file="../common/header.jsp" %>

<main class="container">

	<section class="grid-top">
	  <div class="card big-card">

	    <!-- 탭: 폴더 느낌 제거 -->
		<div class="chart-tabs" role="tablist" aria-label="매출 탭">
		  <button class="chart-tab active" role="tab" aria-selected="true" data-target="quarterly">분기별 매출</button>
		  <button class="chart-tab" role="tab" aria-selected="false" data-target="yearly">연 매출</button>
		</div>

	    <!-- 분기별 매출 (이전: 월 매출) -->
	    <div class="chart quarterly active" role="tabpanel" aria-label="분기별 매출">
	      <div class="barplot">
	        <c:forEach var="item" items="${monthlySales}">
	          <div class="col" style="--h-main:${item.sales}%; --h-yoy:${item.yoy}%;">
	            <div class="stack">
	              <div class="bar main"></div>
	              <div class="bar yoy"></div>
	              <div class="yoy-chip">전년 분기 대비</div>
	            </div>
	            <div class="label-month">${item.month}분기</div>
	          </div>
	        </c:forEach>
	      </div>
	    </div>

	    <!-- 연 매출 -->
	    <div class="chart yearly" role="tabpanel" aria-label="연 매출">
	      <div class="barplot" id="yearly-barplot">
	        <!-- JS에서 동적으로 생성 -->
	      </div>
	    </div>

	    <!-- 범례: 노란색 + 가운데 정렬 -->
	    <div class="legend">
	      <span class="dot"></span> 전년 분기 대비
	    </div>
	  </div>
	</section>

  <!-- 중간 2열 -->
  <section class="grid-mid">

    <!-- 사용자 카드 -->
	<div class="card profile-card">
	  <div class="user">
	    <!-- 프로필 이미지 -->
	    <div class="avatar">
	      <!-- 나중에 3D 아바타 PNG/SVG 또는 Canvas/WebGL 넣어도 됨 -->
	     <img src="/images/3d-user.png" alt="3D User 이미지" class="avatar-img">
	    </div>

	    <!-- 유저 정보 -->
	    <div class="meta">
			<div style="font-weight:800;">
			  ${user.name}님
			</div>
	    </div>
       </div>

	  <!-- 일정표 -->
	  <div class="schedule">
	    <div class="schedule-title">하루 일정표</div>
	    <div class="schedule-row"><span>09:00 ~ 12:00</span><span class="muted">-</span></div>
	    <div class="schedule-row"><span>12:00 ~ 13:30</span><span class="lunch">점심시간</span></div>
	    <div class="schedule-row"><span>14:00 ~ 16:00</span><span class="muted">-</span></div>
	    <div class="schedule-row"><span>16:00 ~ 18:00</span><span class="muted">-</span></div>
	    <div class="schedule-row"><span>기타</span><span class="muted">-</span></div>
	  </div>
	</div>
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
  </section>

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

</main>
<script src="<c:url value='/js/profileModal.js'/>"></script>




<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script src="<c:url value='/js/profileModal.js'/>"></script>

<script>
document.addEventListener('DOMContentLoaded', () => {
  // 탭 스위칭 (방어 코드 포함)
  const tabs = document.querySelectorAll('.chart-tabs .chart-tab');
  const panes = document.querySelectorAll('.chart');
  tabs.forEach(tab => {
    tab.addEventListener('click', () => {
      const target = tab.dataset.target;
      // quarterly, yearly만 허용
      if (target === 'quarterly' || target === 'yearly') {
        const pane = document.querySelector(`.chart.${target}`);
        if (pane) {
          panes.forEach(p => p.classList.remove('active'));
          pane.classList.add('active');
        }
        tabs.forEach(t => { t.classList.remove('active'); t.setAttribute('aria-selected','false'); });
        tab.classList.add('active'); tab.setAttribute('aria-selected','true');
      }
    });
  });

  // === 모달 ===
  const modal   = document.getElementById('profile-modal');
  const btnOpen = document.getElementById('btn-profile-edit');   // 홈 카드의 "회원수정" 버튼
  const btnClose = document.getElementById('btn-profile-close');  // X 버튼
  const btnCancel = document.getElementById('btn-cancel');        // 취소 버튼

  if (btnOpen && modal) {
    btnOpen.addEventListener('click', () => modal.classList.add('show'));
  }
  if (btnClose && modal) {
    btnClose.addEventListener('click', () => modal.classList.remove('show'));
  }
  if (btnCancel && modal) {
    btnCancel.addEventListener('click', () => modal.classList.remove('show'));
  }
  // 배경 클릭 시 닫기
  if (modal) {
    modal.addEventListener('click', (e) => {
      if (e.target === modal) modal.classList.remove('show');
    });
  }
});

// DART API에서 2020~2024년 연매출 데이터 받아서 차트에 표시
const yearlyBarplot = document.getElementById('yearly-barplot');
const years = [2020, 2021, 2022, 2023, 2024];
Promise.all(years.map(year =>
  fetch(`/api/dart/finance?year=${year}`)
    .then(res => res.json())
    .then(data => {
      // 매출액 데이터만 추출
      const sales = data.list.find(item => item.account_nm === "매출액");
      return { year, sales };
    })
)).then(results => {
  results.forEach((item, idx) => {
    // sales 값이 없으면 0 처리
    const salesValue = item.sales ? item.sales.amount : 0;
    // 막대 높이(%) 계산 (예시: 최대값 기준)
    const maxSales = Math.max(...results.map(r => r.sales ? r.sales.amount : 0));
    const height = maxSales ? (salesValue / maxSales * 100) : 0;
    // DOM 생성
    const col = document.createElement('div');
    col.className = 'col';
    col.style.setProperty('--h-main', `${height}%`);
    col.innerHTML = `
      <div class=\"stack\">
        <div class=\"bar main\"></div>
        <div class=\"yoy-chip\">매출액</div>
      </div>
      <div class=\"label-month\">${item.year}</div>
    `;
    yearlyBarplot.appendChild(col);
  });
});

// DART API에서 받아온 매출액 데이터 콘솔 출력 (2020~2024)
const yearsForConsole = [2020, 2021, 2022, 2023, 2024];
Promise.all(yearsForConsole.map(year =>
  fetch(`/api/dart/finance?year=${year}`)
    .then(res => res.json())
    .then(data => {
      const sales = data.list.filter(item => item.account_nm === "매출액");
      return { year, sales };
    })
)).then(results => {
  console.log('연도별 매출액 데이터:', results);
});

// 2024년 분기별 매출액 콘솔 출력 (quarter, requested_code 값 명확하게, 디버그용 전체 객체도 출력)
const quarterCodes = [
  { quarter: '1', code: '11013' },
  { quarter: '2', code: '11012' },
  { quarter: '3', code: '11014' },
  { quarter: '4', code: '11011' }
];
Promise.all(quarterCodes.map(q =>
  fetch(`/api/dart/finance?year=2024&reprt_code=${q.code}`)
    .then(res => res.json())
    .then(data => {
      const sales = data.list.find(item => item.account_nm === "매출액");
      // 디버그: q, sales, data 모두 출력
      return {
        quarter: q.quarter,
        requested_code: q.code,
        response_code: sales ? sales.reprt_code : '없음',
        amount: sales ? sales.thstrm_amount : '데이터 없음',
        salesObj: sales,
        requestObj: q,
        rawData: data
      };
    })
)).then(results => {
  results.forEach(item => {
    console.log(`2024년 ${item.quarter}분기 (요청 reprt_code=${item.requested_code}, 응답 reprt_code=${item.response_code}) 매출액:`, item.amount);
    console.log('requestObj:', item.requestObj);
    console.log('salesObj:', item.salesObj);
    console.log('rawData:', item.rawData);
  });
});
</script>
<script src="<c:url value='/js/profileModal.js'/>"></script>
<%@ include file="../common/footer.jsp" %>