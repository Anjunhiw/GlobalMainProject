<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%request.setAttribute("pageTitle", "대시보드");%>
<%request.setAttribute("active_main", "active");%>
<link rel="stylesheet" href="/css/home.css?v=7">
<%@ include file="header.jsp" %>
<%@ include file="fragments/profileModal.jsp" %>
<main class="container">

	<section class="grid-top">
	  <div class="card big-card">

	    <!-- 탭: 폴더 느낌 제거 -->
		<div class="chart-tabs" role="tablist" aria-label="매출 탭">
		  <button class="chart-tab active" role="tab" aria-selected="true" data-target="monthly">월 매출</button>
		  <button class="chart-tab" role="tab" aria-selected="false" data-target="yearly">연 매출</button>
		</div>

	    <!-- 월 매출 -->
	    <div class="chart monthly active" role="tabpanel" aria-label="월 매출">
	      <div class="barplot">
	        <!-- 각 달: --h-main(파랑), --h-yoy(노랑/호버 시 오른쪽에 표시) -->
	        <div class="col" style="--h-main:52%; --h-yoy:25%;">
	          <div class="stack">
	            <div class="bar main"></div>
	            <div class="bar yoy"></div>
	            <div class="yoy-chip">전년 월 대비</div>
	          </div>
	          <div class="label-month">1월</div>
	        </div>
	        <div class="col" style="--h-main:78%; --h-yoy:18%;"><div class="stack"><div class="bar main"></div><div class="bar yoy"></div><div class="yoy-chip">전년 월 대비</div></div><div class="label-month">2월</div></div>
	        <div class="col" style="--h-main:60%; --h-yoy:12%;"><div class="stack"><div class="bar main"></div><div class="bar yoy"></div><div class="yoy-chip">전년 월 대비</div></div><div class="label-month">3월</div></div>
	        <div class="col" style="--h-main:64%; --h-yoy:20%;"><div class="stack"><div class="bar main"></div><div class="bar yoy"></div><div class="yoy-chip">전년 월 대비</div></div><div class="label-month">4월</div></div>
	        <div class="col" style="--h-main:92%; --h-yoy:30%;"><div class="stack"><div class="bar main"></div><div class="bar yoy"></div><div class="yoy-chip">전년 월 대비</div></div><div class="label-month">5월</div></div>
	        <div class="col" style="--h-main:36%; --h-yoy:10%;"><div class="stack"><div class="bar main"></div><div class="bar yoy"></div><div class="yoy-chip">전년 월 대비</div></div><div class="label-month">6월</div></div>
	        <div class="col" style="--h-main:64%; --h-yoy:16%;"><div class="stack"><div class="bar main"></div><div class="bar yoy"></div><div class="yoy-chip">전년 월 대비</div></div><div class="label-month">7월</div></div>
	        <div class="col" style="--h-main:98%; --h-yoy:28%;"><div class="stack"><div class="bar main"></div><div class="bar yoy"></div><div class="yoy-chip">전년 월 대비</div></div><div class="label-month">8월</div></div>
	        <div class="col" style="--h-main:32%; --h-yoy:9%;"><div class="stack"><div class="bar main"></div><div class="bar yoy"></div><div class="yoy-chip">전년 월 대비</div></div><div class="label-month">9월</div></div>
	        <div class="col" style="--h-main:40%; --h-yoy:14%;"><div class="stack"><div class="bar main"></div><div class="bar yoy"></div><div class="yoy-chip">전년 월 대비</div></div><div class="label-month">10월</div></div>
	        <div class="col" style="--h-main:58%; --h-yoy:22%;"><div class="stack"><div class="bar main"></div><div class="bar yoy"></div><div class="yoy-chip">전년 월 대비</div></div><div class="label-month">11월</div></div>
	        <div class="col" style="--h-main:76%; --h-yoy:26%;"><div class="stack"><div class="bar main"></div><div class="bar yoy"></div><div class="yoy-chip">전년 월 대비</div></div><div class="label-month">12월</div></div>
	      </div>
	    </div>

	    <!-- 연 매출 -->
	    <div class="chart yearly" role="tabpanel" aria-label="연 매출">
	      <div class="barplot">
	        <div class="col" style="--h-main:68%; --h-yoy:30%;">
	          <div class="stack">
	            <div class="bar main"></div>
	            <div class="bar yoy"></div>
	            <div class="yoy-chip">전년 대비</div>
	          </div>
	          <div class="label-month">2021</div>
	        </div>
	        <div class="col" style="--h-main:80%; --h-yoy:35%;">
	          <div class="stack">
	            <div class="bar main"></div>
	            <div class="bar yoy"></div>
	            <div class="yoy-chip">전년 대비</div>
	          </div>
	          <div class="label-month">2022</div>
	        </div>
	        <div class="col" style="--h-main:90%; --h-yoy:40%;">
	          <div class="stack">
	            <div class="bar main"></div>
	            <div class="bar yoy"></div>
	            <div class="yoy-chip">전년 대비</div>
	          </div>
	          <div class="label-month">2023</div>
	        </div>
	      </div>
	    </div>

	    <!-- 범례: 노란색 + 가운데 정렬 -->
	    <div class="legend">
	      <span class="dot"></span> 전년 월 대비
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
			<div class="actions">
			  <button class="action" id="btn-profile-edit" type="button">회원수정</button>
			  <button class="action" type="button">환경설정</button>
			  <button class="action" type="button">메모</button>
			  <button onclick="location.reload()" class="action" type="button">새로고침</button>

			  <form action="/logout" method="post" style="display:inline;">
			    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
			    <button type="submit" class="action">로그아웃</button>
			  </form>
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
<%@ include file="footer.jsp" %>




<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script src="<c:url value='/js/profileModal.js'/>"></script>

<script>
document.addEventListener('DOMContentLoaded', () => {
  // 탭 스위칭 (그대로 유지)
  const tabs = document.querySelectorAll('.chart-tabs .chart-tab');
  const panes = document.querySelectorAll('.chart');
  tabs.forEach(tab => {
    tab.addEventListener('click', () => {
      tabs.forEach(t => { t.classList.remove('active'); t.setAttribute('aria-selected','false'); });
      tab.classList.add('active'); tab.setAttribute('aria-selected','true');
      const target = tab.dataset.target; // 'monthly' | 'yearly'
      panes.forEach(p => p.classList.remove('active'));
      const pane = document.querySelector(`.chart.${target}`);
      if (pane) pane.classList.add('active');
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
</script>
<script src="<c:url value='/js/profileModal.js'/>"></script>

</body>
</html>



