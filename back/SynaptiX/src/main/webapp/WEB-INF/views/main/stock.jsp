<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%request.setAttribute("pageTitle", "대시보드");%>
<%request.setAttribute("active_main", "active");%>
<%request.setAttribute("active_mains", "stock");%>

<link rel="stylesheet" href="<c:url value='/css/stock-status.css?v=1'/>">

<%@ include file="../common/header.jsp" %>
<main class="container">
<section class="dashboard-grid">

  <!-- 1) 상단 - 오늘 재고 처리 현황 테이블 -->
  <div class="card card-wide">
    <div class="card-header">
      <h4>
        <fmt:formatDate value="<%= new java.util.Date() %>" pattern="MM/dd"/> (오늘)
      </h4>
    </div>
    <div class="card-body">
      <table class="table">
        <thead>
          <tr>
            <th class="left">품목</th>
            <th class="right">오더</th>
            <th class="right">처리건수</th>
            <th class="right">미처리건수</th>
            <th class="right">진행률</th>
            <th class="right">출고 진행률</th>
          </tr>
        </thead>
        <tbody>
          <c:choose>
            <c:when test="${not empty todaySummary}">
              <c:forEach var="row" items="${todaySummary}">
                <tr>
                  <td class="left">${row.name}</td>
                  <td class="right"><fmt:formatNumber value="${row.orderCnt}" type="number"/></td>
                  <td class="right"><fmt:formatNumber value="${row.doneCnt}" type="number"/></td>
                  <td class="right"><fmt:formatNumber value="${row.todoCnt}" type="number"/></td>
                  <td class="right">${row.progress}%</td>
                  <td class="right">${row.shipProgress}%</td>
                </tr>
              </c:forEach>
            </c:when>
            <c:otherwise>
              <!-- 샘플 ROW -->
              <tr><td class="left">삼성 QLED TV</td><td class="right">15,230</td><td class="right">4,260</td><td class="right">10,970</td><td class="right">28%</td><td class="right">65%</td></tr>
              <tr><td class="left">삼성 Lifestyle TV</td><td class="right">7,860</td><td class="right">5,680</td><td class="right">2,180</td><td class="right">72%</td><td class="right">68%</td></tr>
              <tr><td class="left">삼성 포터블 SSD</td><td class="right">23,654</td><td class="right">16,450</td><td class="right">7,204</td><td class="right">70%</td><td class="right">71%</td></tr>
            </c:otherwise>
          </c:choose>
        </tbody>
        <tfoot>
          <tr class="total">
            <td class="left">합계</td>
            <td class="right">
              <c:choose>
                <c:when test="${not empty todaySummaryTotal}">
                  <fmt:formatNumber value="${todaySummaryTotal.orderCnt}" type="number"/>
                </c:when>
                <c:otherwise>46,744</c:otherwise>
              </c:choose>
            </td>
            <td class="right">
              <c:choose>
                <c:when test="${not empty todaySummaryTotal}">
                  <fmt:formatNumber value="${todaySummaryTotal.doneCnt}" type="number"/>
                </c:when>
                <c:otherwise>26,390</c:otherwise>
              </c:choose>
            </td>
            <td class="right">
              <c:choose>
                <c:when test="${not empty todaySummaryTotal}">
                  <fmt:formatNumber value="${todaySummaryTotal.todoCnt}" type="number"/>
                </c:when>
                <c:otherwise>20,354</c:otherwise>
              </c:choose>
            </td>
            <td class="right">56%</td>
            <td class="right"></td>
          </tr>
        </tfoot>
      </table>
    </div>
  </div>

  <div class="grid-2">
    <!-- 2) 좌측 - 입고 현황 + 도넛 차트 -->
    <div class="card">
      <div class="card-header">
        <h4>당일 입고 현황</h4>
      </div>
      <div class="card-body">
        <table class="table compact">
          <thead>
          <tr>
            <th class="left">품목</th>
            <th class="right">예정 입고</th>
            <th class="right">당일 입고</th>
          </tr>
          </thead>
          <tbody>
          <c:choose>
            <c:when test="${not empty inboundSummary}">
              <c:forEach var="r" items="${inboundSummary}">
                <tr>
                  <td class="left">${r.name}</td>
                  <td class="right"><fmt:formatNumber value="${r.plan}" type="number"/></td>
                  <td class="right"><fmt:formatNumber value="${r.done}" type="number"/></td>
                </tr>
              </c:forEach>
            </c:when>
            <c:otherwise>
              <tr><td class="left">삼성 QLED TV</td><td class="right">2,101</td><td class="right">2,093</td></tr>
              <tr><td class="left">삼성 에어컨</td><td class="right">304</td><td class="right">278</td></tr>
              <tr><td class="left">삼성 OLED TV</td><td class="right">125</td><td class="right">98</td></tr>
              <tr><td class="left">노트북 9 Spin</td><td class="right">1,607</td><td class="right">1,163</td></tr>
            </c:otherwise>
          </c:choose>
          </tbody>
        </table>

        <div class="split">
          <div class="mini-table">
            <table class="table compact">
              <thead><tr><th class="left">구분</th><th class="right">오더</th></tr></thead>
              <tbody>
                <tr><td class="left">생산요청 완료(예정)</td><td class="right">85,412</td></tr>
                <tr><td class="left">입고요청대기</td><td class="right">36,451</td></tr>
                <tr><td class="left">입고보류</td><td class="right">64,150</td></tr>
                <tr><td class="left">생산처리 완료 합계</td><td class="right">42,300</td></tr>
              </tbody>
            </table>
          </div>
          <div class="chart-box">
            <canvas id="donutInbound" height="160"></canvas>
          </div>
        </div>
      </div>
    </div>

    <!-- 3) 우측 - 재고/출고 현황 + 출고 추이 -->
    <div class="card">
      <div class="card-header">
        <h4>재고/출고 현황</h4>
      </div>
      <div class="card-body">
        <table class="table compact">
          <thead>
          <tr>
            <th class="left">구분</th>
            <th class="right">현재 재고</th>
            <th class="right">예정 출고</th>
            <th class="right">당일 출고</th>
          </tr>
          </thead>
          <tbody>
            <tr><td class="left">삼성 QLED TV</td><td class="right">694,517</td><td class="right">305,120</td><td class="right">206,121</td></tr>
            <tr><td class="left">삼성 에어컨</td><td class="right">451,354</td><td class="right">204,120</td><td class="right">181,612</td></tr>
            <tr><td class="left">삼성 OLED TV</td><td class="right">56,421</td><td class="right">209,451</td><td class="right">10,951</td></tr>
            <tr><td class="left">노트북 9 Spin</td><td class="right">51,320</td><td class="right">22,300</td><td class="right">9,600</td></tr>
          </tbody>
        </table>

        <div class="chart-box mt-16">
          
          <canvas id="lineShip" height="120"></canvas>
        </div>
      </div>
    </div>
  </div>

</section>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
<script>
  // ===== 도넛(입고 분포) =====
  (function(){
    const ctx = document.getElementById('donutInbound');
    if(!ctx) return;
    new Chart(ctx, {
      type: 'doughnut',
      data: {
        labels: ['입고완료', '입고대기', '입고보류', '기타'],
        datasets: [{
          data: [38.5, 27.4, 16, 18.1],
          backgroundColor: ['#5b7cff', '#9dc0ff', '#ffd166', '#ef476f']
        }]
      },
      options: {
        plugins: { legend: { position: 'bottom' } },
        cutout: '60%'
      }
    });
  })();

  // ===== 라인(월간 입/출고 추이) =====
  (function () {
    const el = document.getElementById('lineShip');
    if (!el) return;

    const ctx = el.getContext?.('2d') || el;

    new Chart(ctx, {
      type: 'line',
      data: {
        labels: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'],
        datasets: [
          {
            label: '입고',
            data: [8,10,9,12,14,13,16,15,14,18,17,20],
            borderColor: '#f4a63a',
            tension: .35,
            pointRadius: 3,
            fill: false
          },
          {
            label: '출고',
            data: [7,8,8,10,12,12,15,13,14,16,15,19],
            borderColor: '#5b7cff',
            tension: .35,
            pointRadius: 3,
            fill: false
          }
        ]
      },
      options: {
        responsive: true,
        plugins: {
          legend: { position: 'bottom' }
        },
        scales: {
          x: {
            grid: { display: false }
          },
          y: {
            grid: { color: '#f1f5f9' },
            ticks: { beginAtZero: true, precision: 0 },
            // 🔻 여기만 추가/수정하면 됩니다
            title: {
              display: true,
              text: '총 입/출고 관리현황(월간/건수)',
              rotation: 0,         // ← 가로로 눕히기
              align: 'center',
              color: '#374151',
              font: { size: 12, weight: '600' },
              padding: { top: 10, bottom: 10 }
            }
          }
        }
      }
    });
  })();

</script>






<%@ include file="../common/footer.jsp" %>