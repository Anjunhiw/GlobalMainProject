# -*- coding: utf-8 -*-
"""
06_visualize_predictions_final.py
- 실제 시계열 데이터와 모델의 예측 결과를 함께 시각화합니다.
- `reports/next_quarter_predictions.csv` 파일의 예측 결과를 사용합니다.
- 생성되는 그래프:
  - 실제값 vs 예측값 시계열 그래프 (매출, 영업이익 각각)
  - 모델별 예측 결과 비교 막대그래프
- 모든 그래프는 `reports/figures` 디렉토리에 저장됩니다.
"""
from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt
import platform

# --- 경로 설정 ---
BASE = Path(__file__).resolve().parent.parent
FINAL = BASE / "data" / "final"
REPORTS = BASE / "reports"
FIG = REPORTS / "figures"
FIG.mkdir(parents=True, exist_ok=True)

# --- 한글 폰트 설정 ---
if platform.system() == 'Windows':
    plt.rc('font', family='Malgun Gothic')
elif platform.system() == 'Darwin':
    plt.rc('font', family='AppleGothic')
else:
    plt.rc('font', family='NanumGothic')
plt.rcParams['axes.unicode_minus'] = False


def load_series() -> pd.DataFrame:
    """실제 시계열 데이터(매출, 영업이익)를 로드합니다."""
    wide = pd.read_csv(FINAL / "ml_dataset_wide.csv")
    if "period" in wide.columns:
        wide["period"] = wide["period"].astype(str)
    ycols = [c for c in ["revenue","op_profit"] if c in wide.columns]
    y = wide[["period"] + ycols].drop_duplicates("period")
    return y

def load_predictions() -> pd.DataFrame:
    """
    저장된 다음 분기 예측 결과(next_quarter_predictions.csv)를 로드하고,
    시각화에 용이한 wide 포맷으로 변환합니다.
    """
    p = REPORTS / "next_quarter_predictions.csv"
    if not p.exists():
        return pd.DataFrame(columns=["period"])
        
    pred = pd.read_csv(p)
    pred["period"] = pred["period_next"].astype(str)
    
    # Long 포맷을 Wide 포맷으로 피벗합니다.
    # (예: target, model 컬럼을 실제 컬럼으로 변환 -> revenue_linear, revenue_rf, ...)
    pv = pred.pivot_table(index="period", columns=["target","model"], values="y_pred", aggfunc="last")
    
    # MultiIndex 컬럼을 단일 컬럼으로 변환합니다. (예: ('revenue', 'linear') -> 'revenue_linear')
    pv.columns = [f"{a}_{b}" for a,b in pv.columns.to_list()]
    pv = pv.reset_index()
    return pv

def plot_actual_vs_pred(y_df: pd.DataFrame, pred_df: pd.DataFrame):
    """실제값과 예측값을 함께 나타내는 시계열 그래프를 생성하고 저장합니다."""
    # 시각화를 위해 period를 인덱스로 설정하고 정렬합니다.
    y = y_df.set_index("period").sort_index()
    if not pred_df.empty:
        pred = pred_df.set_index("period").sort_index()
    else:
        pred = pd.DataFrame(index=y.index.copy())

    for target in ["revenue","op_profit"]:
        plt.figure(figsize=(12, 6))
        # 실제값(Actual) 시계열
        if target in y.columns:
            y[target].plot(marker="o", label=f"실제값_{target}")
        # 모델별 예측값(Predicted) 시계열
        for mdl in ["linear","rf"]:
            col = f"{target}_{mdl}"
            if col in pred.columns:
                pred[col].plot(marker="x", linestyle="--", label=f"예측값_{target}_{mdl}")
        plt.title(f"실제값 vs. 예측값 - {target}", fontsize=16)
        plt.xlabel("기간")
        plt.ylabel("조원 (KRW Trillion)")
        plt.grid(True, alpha=0.3)
        plt.legend()
        out = FIG / f"pred_{target}.png"
        plt.savefig(out, bbox_inches="tight", dpi=160)
        plt.close()
        print(f"그래프 저장: {out}")

def plot_bar_compare(pred_df: pd.DataFrame):
    """가장 최근 예측에 대해 모델별 예측값을 비교하는 막대그래프를 생성합니다."""
    if pred_df.empty:
        return
    pred = pred_df.set_index("period").sort_index()
    last_p = pred.index[-1]
    row = pred.loc[last_p]
    
    # 예측값 컬럼만 필터링
    row = row[[c for c in row.index if "_" in c]]
    
    plt.figure(figsize=(10, 6))
    row.plot(kind="bar", rot=0)
    plt.title(f"모델별 예측 비교 ({last_p})", fontsize=16)
    plt.ylabel("조원 (KRW Trillion)")
    plt.grid(True, axis="y", alpha=0.3)
    out = FIG / f"pred_bar_{last_p}.png"
    plt.savefig(out, bbox_inches="tight", dpi=160)
    plt.close()
    print(f"그래프 저장: {out}")

def main():
    """메인 실행 함수: 데이터를 로드하고, 실제값과 예측값을 비교하는 그래프를 생성합니다."""
    # 1. 실제값과 예측값 로드
    y = load_series()
    pred = load_predictions()
    
    # 2. 데이터 병합 및 저장 (분석용)
    if not pred.empty:
        common = pd.merge(y, pred, on="period", how="outer")
        common.to_csv(REPORTS / "actual_vs_pred_join.csv", index=False)
        print(f"분석용 데이터 저장: {REPORTS/'actual_vs_pred_join.csv'}")
    
    # 3. 시각화 함수 호출
    plot_actual_vs_pred(y, pred)
    plot_bar_compare(pred)

if __name__ == "__main__":
    main()