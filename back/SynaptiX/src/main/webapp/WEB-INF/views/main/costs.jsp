<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%request.setAttribute("pageTitle", "대시보드");%>
<%request.setAttribute("active_main", "active");%>
<%request.setAttribute("active_mains", "costs");%>
<link rel="stylesheet" href="/css/home.css?v=7">
<%@ include file="../common/header.jsp" %>
<main class="container">
<section class="dashboard-grid">

  <div class="card card-wide">
    <div class="card-header">
      <div class="tab-switch">
		<button class="chart-tab active" role="tab" aria-selected="true" data-target="monthly">월 매출</button>
		  <button class="chart-tab" role="tab" aria-selected="false" data-target="yearly">연 매출</button>
      </div>
    </div>
    <div class="card-body">
      <canvas id="monthlyChart" height="110"></canvas>
      <div class="legend">
        <span><i class="lg lg-bar"></i> 물품 판매량</span>
        <span><i class="lg lg-line"></i> 전년 월 대비</span>
      </div>
    </div>
  </div>

  <!-- 달력 카드 -->
  <div class="card">
    <div class="card-header"><h4 id="calTitle">5월</h4></div>
    <div class="card-body">
      <table class="calendar" id="calendar">
        <thead>
          <tr><th>MON</th><th>TUE</th><th>WED</th><th>THU</th><th>FRI</th><th>SAT</th><th class="sun">SUN</th></tr>
        </thead>
        <tbody><!-- JS가 채움 --></tbody>
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


<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
<script>
  /* =========================
   *  차트 데이터 (서버 바인딩 가능)
   * ========================= */
  const labels = ${labelsJson != null ? labelsJson : "['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월']"};
  const seriesNow  = ${seriesNowJson  != null ? seriesNowJson  : "[12, 8, 3, 18, 22, 15, 23, 17, 10, 25, 9, 14]"};
  const seriesPrev = ${seriesPrevJson != null ? seriesPrevJson : "[8, 6, 4, 9, 12, 11, 19, 14, 12, 13, 10, 11]"};

  /* ===========
   * 월 차트
   * =========== */
  var monthlyCtx = document.getElementById('monthlyChart').getContext('2d');
  var monthlyChart = new Chart(monthlyCtx, {
    type: 'bar',
    data: {
      labels: labels,
      datasets: [
        { label: '올핸 판매량', data: seriesNow,  backgroundColor: '#5b7cff', borderRadius: 6, barThickness: 24 },
        { label: '전년 월 대비', data: seriesPrev, type: 'line', borderColor: '#f4a63a', tension: 0.35, pointRadius: 3, fill: false }
      ]
    },
    options: {
      plugins: { legend: { display: false } },
      scales: {
        x: { grid: { display: false } },
        y: { grid: { color: '#f1f5f9' }, ticks: { beginAtZero: true, precision: 0 } }
      }
    }
  });

  /* =========================
   *  탭(월/연) 버튼 동작 (데모)
   * ========================= */
  document.querySelectorAll('.tab-switch .chart-tab').forEach(function(btn){
    btn.addEventListener('click', function(){
      document.querySelectorAll('.tab-switch .chart-tab').forEach(function(b){ b.classList.remove('active'); });
      btn.classList.add('active');
      // 필요 시 여기서 데이터 교체하여 차트 업데이트
      // monthlyChart.data.datasets[0].data = ...
      // monthlyChart.update();
    });
  });

  /* =========================
   *  달력 렌더링 (이번 달)
   * ========================= */
  (function renderCalendar(){
    var today = new Date();
    var y = today.getFullYear();
    var m = today.getMonth(); // 0~11
    var first = new Date(y, m, 1);
    var last  = new Date(y, m + 1, 0);

    // 월(월요일) 시작 기준 오프셋: (일=0 → 6, 월=1 → 0, ...)
    var startOffset = (first.getDay() + 6) % 7;
    var total = startOffset + last.getDate();
    var rows = Math.ceil(total / 7);

    var titleEl = document.getElementById('calTitle');
    if (titleEl) {
      titleEl.innerText = (m + 1) + '월';
    }

    var tbody = document.querySelector('#calendar tbody');
    if (!tbody) return;

    var html = '';
    var day = 1 - startOffset;
    for (var r = 0; r < rows; r++) {
      html += '<tr>';
      for (var c = 0; c < 7; c++, day++) {
        if (day < 1 || day > last.getDate()) {
          html += '<td class="muted"> </td>';
        } else {
          html += '<td>' + day + '</td>';
        }
      }
      html += '</tr>';
    }
    tbody.innerHTML = html;
  })();

  /* =========================
   *  메모/비용 버튼 (데모)
   * ========================= */
  var memoBtn = document.getElementById('memoSave');
  if (memoBtn) {
    memoBtn.addEventListener('click', function () {
      var memoInput = document.getElementById('memoInput');
      var text = memoInput ? memoInput.value : '';
      alert('메모 저장(샘플) : ' + text);
    });
  }

  var costBtn = document.getElementById('costAdd');
  if (costBtn) {
    costBtn.addEventListener('click', function () {
      var tEl = document.getElementById('costTitle');
      var aEl = document.getElementById('costAmount');
      var t = tEl ? tEl.value : '';
      var a = aEl ? aEl.value : '';
      if (!t || !a) {
        alert('제목/금액을 입력하세요.');
        return;
      }
      var formatted = Number(a).toLocaleString();
      alert('등록(샘플)\n제목: ' + t + '\n금액: ₩' + formatted);
    });
  }
</script>

<%@ include file="../common/footer.jsp" %>






