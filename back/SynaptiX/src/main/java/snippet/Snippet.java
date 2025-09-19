package snippet;

public class Snippet {
	<div class="card profile-card">
	  <div class="user">
	    <!-- 프로필 이미지 -->
	    <div class="avatar">
	      <!-- 나중에 3D 아바타 PNG/SVG 또는 Canvas/WebGL 넣어도 됨 -->
	      <img src="/images/default-avatar-3d.png" alt="프로필 이미지">
	    </div>
	
	    <!-- 유저 정보 -->
	    <div class="meta">
	      <div class="username">@ XXX님</div>
	      <div class="actions">
	        <button class="action"><i class="icon-edit"></i> 회원수정</button>
	        <button class="action"><i class="icon-setting"></i> 환경설정</button>
	        <button class="action"><i class="icon-memo"></i> 메모</button>
	        <button class="action"><i class="icon-refresh"></i> 새로고침</button>
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
}

