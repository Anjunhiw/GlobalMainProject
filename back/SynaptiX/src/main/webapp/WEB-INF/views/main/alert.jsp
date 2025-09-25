<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%request.setAttribute("pageTitle", "대시보드");%>
<%request.setAttribute("active_main", "active");%>
<%request.setAttribute("active_mains", "alert");%>
<link rel="stylesheet" href="/css/home.css?v=7">
<link rel="stylesheet" href="<c:url value='/css/alerts.css?v=1'/>">
<%@ include file="../common/header.jsp" %>
<main class="container">
<section class="alerts-wrap">
  <!-- 알림 4종 -->
  <div class="row row-4">
    <div class="note-card">
      <div class="note-head">
        <div class="title">인력 변동 관련 알림</div>
        <span class="badge">!</span>
      </div>
      <ul class="note-list">
        <li>특정 부서 퇴사율이 평균보다 높음</li>
        <li>부서 A 승진 프로모션 공고 예정</li>
        <li>비정규직 계약 만료 예정자 알림</li>
        <li>신규 입사자 교육일정 확인 요청</li>
        <li>부서 이동 인원 검증</li>
        <li>신규 채용 지원자 데이터 업데이트</li>
        <li>평균 근속연수 5년 미만 부서</li>
      </ul>
    </div>

    <div class="note-card">
      <div class="note-head">
        <div class="title">급여/비용 관련 알림</div>
        <span class="badge">!</span>
      </div>
      <ul class="note-list">
        <li>이번 달 총 급여 추정 대비 10% 이상 변동</li>
        <li>식대/교통비 비중 전월 대비 +15% 조회</li>
        <li>부서별 추가 수당(OT) 30%감소</li>
        <li>성과급 지급 예정 공지</li>
        <li>급여 전표 처리 마감일 임박</li>
        <li>교육/훈련 예산 소진율 80% 달성</li>
      </ul>
    </div>

    <div class="note-card">
      <div class="note-head">
        <div class="title">인사 이벤트 알림</div>
        <span class="badge">!</span>
      </div>
      <ul class="note-list">
        <li>승진/인사 발령 공지</li>
        <li>부서 간 인사 이동</li>
        <li>휴가/복귀자 등록 예정</li>
        <li>부서 인사평가 항목 공지</li>
        <li>상/하반기 보너스 지급 예정일 안내</li>
      </ul>
    </div>

    <div class="note-card">
      <div class="note-head">
        <div class="title">이상치/위험 알림</div>
        <span class="badge">!</span>
      </div>
      <ul class="note-list">
        <li>퇴직률 초과 경고</li>
        <li>특정 부서 OT 집계 집중</li>
        <li>연말 정산 오류 감지</li>
        <li>교육자격증 획득/만료 알림</li>
        <li>특정 수당 과다 지급</li>
        <li>개인 인보이스 집중</li>
      </ul>
    </div>
  </div>

<div class="section row">
    <div class="row row-2">
    <div class="card kpi-card">
      <div class="kpi-grid">
        <div class="tile pink">
          <div class="tile-row">
            <div class="meta">
              <div class="t-title">출고처리</div>
              <div class="t-num" id="kpiProc">651건</div>
            </div>
            <div class="ico">
              <!-- paper-plane -->
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <path d="M22 2L11 13" stroke-linecap="round" stroke-linejoin="round"/>
                <path d="M22 2L15 22l-4-9-9-4 20-7z" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
            </div>
          </div>
        </div>

        <!-- 출고지연 -->
        <div class="tile amber">
          <div class="tile-row">
            <div class="meta">
              <div class="t-title">출고지연</div>
              <div class="t-num" id="kpiDelay">130건</div>
            </div>
            <div class="ico">
              <!-- alert-triangle -->
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/>
                <line x1="12" y1="9" x2="12" y2="13"/>
                <line x1="12" y1="17" x2="12" y2="17"/>
              </svg>
            </div>
          </div>
        </div>

        <!-- 출고중 -->
        <div class="tile violet">
          <div class="tile-row">
            <div class="meta">
              <div class="t-title">출고중</div>
              <div class="t-num" id="kpiProgress">211건</div>
            </div>
            <div class="ico">
              <!-- truck -->
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <rect x="1" y="3" width="13" height="13" rx="2" ry="2"/>
                <path d="M16 8h3l4 4v4h-7z"/>
                <circle cx="5.5" cy="18.5" r="1.5"/>
                <circle cx="18.5" cy="18.5" r="1.5"/>
              </svg>
            </div>
          </div>
        </div>

        <!-- 출고완료 -->
        <div class="tile indigo">
          <div class="tile-row">
            <div class="meta">
              <div class="t-title">출고완료</div>
              <div class="t-num" id="kpiDone">221건</div>
            </div>
            <div class="ico">
              <!-- check-circle -->
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <circle cx="12" cy="12" r="9"/>
                <path d="M9 12l2 2 4-4" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
            </div>
          </div>
        </div>
      </div>
    </div> 	

	<!-- 오류/알림 -->
	<div class="card list-card">
	  <div class="list-head">
	    <h4 class="title">오류/알림</h4>
	    <span class="badge">!</span>
	  </div>

	  <ul class="timeline" id="timeline">
	  </ul>
	</div>
	</div>
	</div>
  </div>
</section>
</main>
<script>
	const timelineData = [ 
	{ type: '오류', date: '2025-09-25', message: '시스템 오류가 발생했습니다.' },
	{ type: '알림', date: '2025-09-24', message: '정기 점검이 예정되어 있습니다.' }, 
	{ type: '기타', date: '2025-09-23', message: '새로운 기능이 추가되었습니다.' }, 
	{ type: '오류', date: '2025-09-22', message: '데이터베이스 연결 실패.' }, 
	{ type: '알림', date: '2025-09-21', message: '사용자 비밀번호 변경 안내.' }, 
	{ type: '기타', date: '2025-09-20', message: '관리자에 의해 설정이 변경되었습니다.' }, 
	{ type: '오류', date: '2025-09-19', message: '파일 업로드 오류가 발생했습니다.' }, 
	{ type: '알림', date: '2025-09-18', message: '새로운 공지사항이 등록되었습니다.' }, 
	{ type: '기타', date: '2025-09-17', message: '테스트 메시지입니다.' } 
	];

	function renderTimeline() {
		console.log(timelineData);
	  const timeline = document.getElementById('timeline');
	  if (!timeline) return;
	  timeline.innerHTML = '';
	  if (timelineData.length === 0) {
	    timeline.innerHTML = '<li class="t-item"><span class="msg">표시할 알림이 없습니다.</span></li>';
	    return;
	  }
	  timelineData.forEach(item => {
	    const dotClass = item.type === '오류' ? 'red' : (item.type === '알림' ? 'blue' : 'gray');
	    const tagClass = item.type === '오류' ? 'danger' : (item.type === '알림' ? 'info' : 'muted');
		console.log(item.date)
	    const li = document.createElement('li');
	    li.className = 't-item';
	    li.innerHTML = `
	      <div class="left">
	        <div class="dot \${dotClass}"></div>
	        <div class="date">\${item.date}</div>
	      </div>
	      <div class="right">
	        <span class="tag \${tagClass}">${item.type}</span>
	        <span class="msg">\${item.message}</span>
	      </div>`;
	    timeline.appendChild(li);
	  });
	}
	// 페이지 로드 시 렌더
	window.addEventListener('DOMContentLoaded', renderTimeline);
</script>






<%@ include file="../common/footer.jsp" %>