// /static/js/profileModal.js
document.addEventListener('DOMContentLoaded', () => {
  const modal    = document.getElementById('profile-modal');
  const btnOpen  = document.getElementById('btn-profile-edit');
  const btnClose = document.getElementById('btn-profile-close');
  const btnCancel = document.getElementById('btn-cancel');

  // 열기
  if (btnOpen && modal) {
    btnOpen.addEventListener('click', () => {
      // 둘 중 하나 선택 (일관되게 사용)
      // modal.style.display = 'flex';
      modal.classList.add('show');
    });
  }

  // 닫기들
  const closeModal = () => {
    // modal.style.display = 'none';
    modal.classList.remove('show');
  };

  if (btnClose && modal) btnClose.addEventListener('click', closeModal);
  if (btnCancel && modal) btnCancel.addEventListener('click', closeModal);

  // 배경 클릭 닫기
  if (modal) {
    modal.addEventListener('click', (e) => {
      if (e.target === modal) closeModal();
    });
  }
});
