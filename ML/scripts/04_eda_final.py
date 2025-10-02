# -*- coding: utf-8 -*-
"""
04_eda_final.py
- 최종 생성된 ML 데이터셋(ml_dataset_wide.csv)을 사용하여 기초적인 탐색적 데이터 분석(EDA)을 수행합니다.
- 주요 분석 내용:
  - 결측치(Missing Values) 시각화
  - 기초 통계량 확인
  - 피처 간 상관관계 분석
  - 주요 재무 지표(매출, 영업이익) 시계열 추세 시각화
- 모든 시각화 결과는 reports/figures/ 디렉토리에 이미지 파일로 저장됩니다.
"""
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import platform
from pathlib import Path
import re as _re_period

# --- 경로 설정 ---
BASE_DIR = Path(__file__).resolve().parent.parent
REPORTS_DIR = BASE_DIR / "reports" / "figures"
REPORTS_DIR.mkdir(parents=True, exist_ok=True)
DATA_PATH = BASE_DIR / "data" / "final" / "ml_dataset_wide.csv"

# --- 시각화 설정 ---
# OS에 따라 적절한 한글 폰트를 설정하여 그래프의 한글 깨짐을 방지합니다.
if platform.system() == 'Windows':
    plt.rc('font', family='Malgun Gothic')
elif platform.system() == 'Darwin': # Mac OS
    plt.rc('font', family='AppleGothic')
else: # Linux
    # Linux에서는 나눔고딕 폰트 설치가 필요할 수 있습니다.
    # (e.g., sudo apt-get install fonts-nanum*)
    plt.rc('font', family='NanumGothic')

# 마이너스 기호가 깨지는 현상을 방지합니다.
plt.rcParams['axes.unicode_minus'] = False

# --- 데이터 로드 ---
try:
    wide = pd.read_csv(DATA_PATH)
    print(f"데이터 로드 완료: {DATA_PATH} (shape: {wide.shape})")
except FileNotFoundError:
    print(f"[ERROR] 데이터 파일을 찾을 수 없습니다: {DATA_PATH}")
    exit()

# --- 정렬을 위한 პერიოდ 키 함수 ---
def _period_key(s: str):
    """'2024Q1', '2024FY' 같은 문자열을 정렬 가능한 튜플로 변환합니다."""
    s = str(s)
    m = _re_period.match(r'^(20\d{2})([QY])([1-4])?$', s)
    if not m:
        return (9999, 9, 9)
    y, t, q = int(m.group(1)), m.group(2), m.group(3)
    return (y, 0 if t == 'Y' else 1, int(q) if q else 0)

# =============================
# 1. 결측치 분석
# =============================
print("\n=== 1. 결측치 현황 ===")
missing_values = wide.isna().sum()
print(missing_values[missing_values > 0].sort_values(ascending=False))

# 결측치 히트맵: 데이터셋 전체의 결측 패턴을 시각적으로 파악하여 데이터 품질을 진단합니다.
plt.figure(figsize=(18, 10))
wide_sorted_for_hm = wide.sort_values('period', key=lambda s: s.map(_period_key))
sns.heatmap(wide_sorted_for_hm.set_index('period').isna(), cbar=False, cmap='viridis')
plt.title("피처별 결측치 분포 (Heatmap)", fontsize=16)
plt.xlabel("피처")
plt.ylabel("기간")
plt.tight_layout()
plt.savefig(REPORTS_DIR / "missing_values_heatmap.png")
plt.show()
print(f"결측치 히트맵 저장: {REPORTS_DIR / 'missing_values_heatmap.png'}")

# =============================
# 2. 기초 통계
# =============================
print("\n=== 2. 기초 통계량 ===")
# 각 피처의 분포(평균, 표준편차, 사분위수 등)를 확인하여 데이터의 스케일과 이상치 존재 가능성을 파악합니다.
print(wide.describe().T)

# =============================
# 3. 상관관계 분석
# =============================
print("\n=== 3. 상관관계 분석 ===")
# 상관관계 히트맵: 피처 간의 선형 관계를 시각화하여 다중공선성 문제나 예측에 유용한 피처를 탐색합니다.
plt.figure(figsize=(20, 15))
# 'period'는 숫자형이 아니므로 상관계수 계산에서 제외합니다.
corr_matrix = wide.drop(columns=['period']).corr(numeric_only=True)
sns.heatmap(corr_matrix, cmap="coolwarm", annot=False) # annot=True는 셀에 숫자 표시
plt.title("피처 간 상관관계 행렬", fontsize=18)
plt.tight_layout()
plt.savefig(REPORTS_DIR / "feature_correlation_heatmap.png")
plt.show()
print(f"상관관계 히트맵 저장: {REPORTS_DIR / 'feature_correlation_heatmap.png'}")

# 주요 재무 변수 간 Pair Plot: 산점도와 히스토그램을 통해 주요 변수들 간의 관계와 각 변수의 분포를 동시에 확인합니다.
pairplot_cols = ["revenue", "op_profit", "dart_cfo", "dart_cfi", "dart_cff"]
# wide 데이터프레임에 있는 컬럼만 선택
pairplot_cols_exist = [col for col in pairplot_cols if col in wide.columns]
if pairplot_cols_exist:
    pairplot_fig = sns.pairplot(wide[pairplot_cols_exist].dropna())
    pairplot_fig.fig.suptitle("주요 변수 간 Pair Plot", y=1.02, fontsize=16)
    plt.tight_layout()
    plt.savefig(REPORTS_DIR / "main_features_pairplot.png")
    plt.show()
    print(f"Pair Plot 저장: {REPORTS_DIR / 'main_features_pairplot.png'}")

# =============================
# 4. 시계열 추세
# =============================
print("\n=== 4. 시계열 추세 분석 ===")
# 시계열 그래프를 올바르게 그리기 위해 'period'를 기준으로 데이터를 정렬합니다.
wide_sorted = wide.sort_values('period', key=lambda s: s.map(_period_key)).copy()

# 매출액과 영업이익의 시계열 추세를 시각화하여 계절성, 추세, 주기적 변동 등을 파악합니다.
fig, ax = plt.subplots(2, 1, figsize=(16, 10), sharex=True)

# 매출액(revenue) 추이
if "revenue" in wide_sorted.columns:
    wide_sorted.plot(x="period", y="revenue", marker="o", ax=ax[0])
    ax[0].set_title("분기별 매출액 추이", fontsize=14)
    ax[0].set_ylabel("매출액 (조원)")
    ax[0].grid(True, linestyle='--' , alpha=0.6)

# 영업이익(op_profit) 추이
if "op_profit" in wide_sorted.columns:
    wide_sorted.plot(x="period", y="op_profit", marker="o", color='orange', ax=ax[1])
    ax[1].set_title("분기별 영업이익 추이", fontsize=14)
    ax[1].set_xlabel("분기")
    ax[1].set_ylabel("영업이익 (조원)")
    ax[1].grid(True, linestyle='--' , alpha=0.6)

# x축의 기간 레이블이 겹치지 않도록 45도 회전합니다.
plt.xticks(rotation=45, ha='right')
plt.tight_layout()
plt.savefig(REPORTS_DIR / "timeseries_trends.png")
plt.show()
print(f"시계열 추세 그래프 저장: {REPORTS_DIR / 'timeseries_trends.png'}")

print("\nEDA 완료. 모든 결과는 'reports/figures' 폴더에 저장되었습니다.")