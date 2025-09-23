
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%request.setAttribute("pageTitle", "대시보드");%>
<%request.setAttribute("active_main", "active");%>
<link rel="stylesheet" href="/css/home.css?v=7">
<%@ include file="../common/header.jsp" %>
<%@ include file="../fragments/profileModal.jsp" %>



<html lang="ko">
<body>

<section class="dashboard-grid">
  <!-- 월 매출/비용 차트 카드 -->
  <div class="card card-wide">
    <div class="card-header">
      <div class="tab-switch">
        <button class="tab on" data-series="sales">월 매출</button>
        <button class="tab" data-series="yearly">연 매출</button>
      </div>
    </div>
    <div class="card-body">
      <canvas id="monthlyChart" height="110"></canvas>
      <div class="legend">
        <span><i class="lg lg-bar"></i> 올핸 판매량</span>
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
          <tr><th>MON</th><th>TUE</th><th>WED</th><th>THU</th><th>FRI</th><th>SAT</th><th>SUN</th></tr>
        </thead>
        <tbody><!-- JS가 채움 --></tbody>
      </table>

      <div class="note-box">
        <h5>안내 (환율, 조회, 메모 등) 입력</h5>
        <ul class="small">
          <li>샘플 안내문. 필요에 맞게 교체하세요.</li>
          <li>최근 변경사항, 공지, 확정 일정 등을 띄울 수 있습니다.</li>
        </ul>

        <div class="inline-input">
          <input type="text" placeholder="비고/메모 입력" id="memoInput">
          <button class="btn btn-success" id="memoSave">확인</button>
        </div>
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

</body>

</html>



<!-- ===== Scripts ===== -->
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
<script>
  // ---- 차트 데이터 (서버 값 바인딩 가능) ----
  const labels = ${labelsJson != null ? labelsJson : "['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월']"};
  const seriesNow  = ${seriesNowJson  != null ? seriesNowJson  : "[12, 8, 3, 18, 22, 15, 23, 17, 10, 25, 9, 14]"};
  const seriesPrev = ${seriesPrevJson != null ? seriesPrevJson : "[8, 6, 4, 9, 12, 11, 19, 14, 12, 13, 10, 11]"};

  const ctx = document.getElementById('monthlyChart').getContext('2d');
  const monthlyChart = new Chart(ctx, {
    type: 'bar',
    data: {
      labels,
      datasets: [
        {label:'올핸 판매량', data: seriesNow,  backgroundColor:'#5b7cff', borderRadius:6, barThickness:24},
        {label:'전년 월 대비', data: seriesPrev, type:'line', borderColor:'#f4a63a', tension:.35, pointRadius:3, fill:false}
      ]
    },
    options: {
      plugins: { legend: { display:false }},
      scales: {
        x: { grid: { display:false }},
        y: { grid: { color:'#f1f5f9' }, ticks:{ beginAtZero:true, precision:0 } }
      }
    }
  });

  // 탭(월/연)
  document.querySelectorAll('.tab-switch .tab').forEach(btn=>{
    btn.addEventListener('click', ()=>{
      document.querySelectorAll('.tab-switch .tab').forEach(b=>b.classList.remove('on'));
      btn.classList.add('on');
      // 실제 전환 로직은 필요 시 데이터 교체
    });
  });

  // ---- 달력 그리기 (이번달 기준) ----
  (function renderCalendar(){
    const today = new Date();
    const y = today.getFullYear(), m = today.getMonth(); // 0-based
    const first = new Date(y, m, 1);
    const last  = new Date(y, m+1, 0);
    const startOffset = (first.getDay() + 6) % 7; // 월=0 기준
    const total = startOffset + last.getDate();
    const rows = Math.ceil(total / 7);
    document.getElementById('calTitle').innerText = (m+1) + '월';

    const tbody = document.querySelector('#calendar tbody');
    let html = '';
    let day = 1 - startOffset;
    for(let r=0; r<rows; r++){
      html += '<tr>';
      for(let c=0;c<7;c++, day++){
        if(day < 1 || day > last.getDate()) html += '<td class="muted"> </td>';
        else html += `<td>${day}</td>`;
      }
      html += '</tr>';
    }
    tbody.innerHTML = html;
  })();

  // 메모/비용 버튼 (데모)
  document.getElementById('memoSave')?.addEventListener('click', ()=> {
    alert('메모 저장(샘플) : ' + document.getElementById('memoInput').value);
  });
  document.getElementById('costAdd')?.addEventListener('click', ()=> {
    const t = document.getElementById('costTitle').value;
    const a = document.getElementById('costAmount').value;
    if(!t || !a) return alert('제목/금액을 입력하세요.');
    alert(`등록(샘플)\n제목: ${t}\n금액: ₩${Number(a).toLocaleString()}`);
  });
</script>






