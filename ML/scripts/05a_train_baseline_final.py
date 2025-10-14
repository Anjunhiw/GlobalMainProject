# -*- coding: utf-8 -*-
"""
05a_train_baseline_final.py (IR 최소 피처 버전 - FY 안전 패치)
- 목표: 데이터 스킵 없이 우선 모델이 학습되도록 보수적으로 구성
- 피처: revenue/op_profit 자체의 lag(1,2), rmean(2)만 사용 (누설 방지 shift)
- 학습 불가 시 자동으로 lag1만 사용하는 fallback
- 수정:
  * period 정렬 키를 FY 안전형으로 교체
  * 학습은 분기(Q)만 사용(FY 제외)
  * cv 평균 계산(dict comprehension)에서 k 미정(NameError) 버그 수정
"""
import json, warnings
from pathlib import Path
from typing import List, Dict
import numpy as np
import pandas as pd
from sklearn.model_selection import TimeSeriesSplit
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline
from sklearn.linear_model import LinearRegression
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_absolute_error, r2_score
import joblib
import re

warnings.filterwarnings("ignore", category=UserWarning)

# --- 경로 및 상수 설정 ---
BASE_DIR = Path(__file__).resolve().parent.parent # ML/
DATA_WIDE = BASE_DIR / "data" / "final" / "ml_dataset_wide.csv"
OUT_DIR   = BASE_DIR / "models";  OUT_DIR.mkdir(parents=True, exist_ok=True)
REPORTS   = BASE_DIR / "reports"; REPORTS.mkdir(parents=True, exist_ok=True)

# --- 모델 설정 ---
TARGETS = ["revenue", "op_profit"] # 예측 대상 변수
EXCLUDE_COLS = ["period"] + TARGETS # 피처에서 제외할 컬럼

# 사용할 Lag 및 Rolling-mean 피처 정의
LAG_FEATURES_WHITELIST = ["revenue", "op_profit"]
LAGS_PRIMARY  = [1, 2]    # 기본적으로 사용할 Lag (1분기 전, 2분기 전)
ROLLS_PRIMARY = [2]     # 기본적으로 사용할 Rolling-mean window (직전 2개 분기 평균)

N_SPLITS = 3 # 시계열 교차 검증(Cross-validation) 폴드 수
SEED = 42    # 재현성을 위한 랜덤 시드

# --- 유틸리티 함수 ---
def sort_period(df: pd.DataFrame) -> pd.DataFrame:
    """데이터프레임을 'period' 컬럼 기준으로 시간 순서에 맞게 정렬합니다."""
    def key(s: str):
        s = str(s)
        m = re.match(r"^(20\\d{2})([QY])([1-4])?$", s)
        if not m: return (9999, 9, 9)
        y, t, q = int(m.group(1)), m.group(2), m.group(3)
        return (y, 0 if t == 'Y' else 1, int(q) if q else 0)
    return df.sort_values("period", key=lambda s: s.map(key)).reset_index(drop=True)

def make_lag_roll(df: pd.DataFrame, cols: List[str], lags: List[int], rolls: List[int]) -> pd.DataFrame:
    """주어진 컬럼에 대해 Lag 및 Rolling-mean 피처를 생성합니다."""
    out = df.copy()
    for c in cols:
        if c not in out.columns: continue
        # Lag 피처 생성 (예: revenue_lag1)
        for L in lags:
            out[f"{c}_lag{L}"] = out[c].shift(L)
        # Rolling-mean 피처 생성 (예: revenue_rmean2)
        for W in rolls:
            out[f"{c}_rmean{W}"] = out[c].rolling(W, min_periods=1).mean().shift(1)
    return out

def tssplit_indices(n_rows: int, n_splits: int):
    """시계열 교차 검증을 위한 인덱스를 생성합니다. 데이터가 적을 경우를 대비한 폴백 로직을 포함합니다."""
    if n_rows < (n_splits + 2):
        # 데이터가 너무 적으면 단일 분할만 수행
        if n_rows <= 2:
            return []
        cut = max(1, n_rows - 1)
        return [(np.arange(cut), np.arange(cut, n_rows))]
    tss = TimeSeriesSplit(n_splits=n_splits)
    dummy = np.arange(n_rows).reshape(-1, 1)
    return list(tss.split(dummy))

def metrics(y_true, y_pred) -> Dict[str, float]:
    """실제값과 예측값으로 모델 성능 지표(MAE, MAPE, R2)를 계산합니다."""
    eps = 1e-8 # 0으로 나누는 것을 방지하기 위한 작은 값
    mae  = float(mean_absolute_error(y_true, y_pred))
    r2   = float(r2_score(y_true, y_pred))
    mape = float(np.mean(np.abs((y_true - y_pred) / (np.abs(y_true) + eps))) * 100.0)
    return {"MAE": mae, "MAPE": mape, "R2": r2}

def train_for_target(df: pd.DataFrame, target: str) -> Dict[str, dict]:
    """특정 대상 변수(target)에 대한 모델을 학습하고 평가합니다."""
    print(f"\n[INFO] === '{target}' 모델 학습 시작 ===")
    base_cols = [c for c in LAG_FEATURES_WHITELIST if c in df.columns]
    if not base_cols:
        print(f"[WARN] '{target}': 사용할 수 있는 기본 컬럼이 없습니다. 건너뜁니다.")
        return {}

    # 1. 피처 생성: Lag, Rolling-mean 피처를 만듭니다.
    work = make_lag_roll(df, base_cols, LAGS_PRIMARY, ROLLS_PRIMARY)
    feat_cols = [c for c in work.columns if any(c.startswith(b) for b in base_cols) and c not in EXCLUDE_COLS]
    use = work[["period"] + feat_cols + [target]].dropna().reset_index(drop=True)

    # 2. 폴백(Fallback) 로직: 데이터가 너무 적으면 더 간단한 피처(lag1)만 사용하여 다시 시도합니다.
    if len(use) < 8:
        print(f"[WARN] '{target}': 1차 피처로는 행이 {len(use)}개입니다. lag1만으로 축소 시도합니다.")
        work = make_lag_roll(df, base_cols, [1], [])
        feat_cols = [c for c in work.columns if any(c.startswith(b) for b in base_cols) and c not in EXCLUDE_COLS]
        use = work[["period"] + feat_cols + [target]].dropna().reset_index(drop=True)

    if len(use) == 0:
        print(f"[WARN] 피처 생성 후 데이터가 너무 적어(0개) {target} 모델 학습을 건너뜁니다.")
        return {}

    X = use[feat_cols].values
    y = use[target].values

    # 3. 모델 정의: Linear Regression과 Random Forest 두 가지 모델을 사용합니다.
    models = {
        "linear": Pipeline([("scaler", StandardScaler()), ("reg", LinearRegression())]),
        "rf": RandomForestRegressor(n_estimators=400, random_state=SEED, n_jobs=-1)
    }

    splits = tssplit_indices(len(use), N_SPLITS)
    report = {}

    # 4. 모델 학습 및 교차 검증
    for name, model in models.items():
        fold_ms, oof_rows = [], []

        if not splits:
            # 데이터가 너무 적어 교차 검증이 불가능한 경우, 전체 데이터로 학습하고 평가합니다.
            model.fit(X, y)
            yhat = model.predict(X)
            fold_ms.append(metrics(y, yhat))
            oof_rows.append(pd.DataFrame({"period": use["period"], "y_true": y, "y_pred": yhat}))
        else:
            # 시계열 교차 검증 수행
            for tr, va in splits:
                model.fit(X[tr], y[tr])
                p = model.predict(X[va])
                m = metrics(y[va], p)
                fold_ms.append(m)
                oof_rows.append(pd.DataFrame({"period": use.loc[va, "period"].values, "y_true": y[va], "y_pred": p}))

        # 5. 결과 집계 및 저장
        avg = {k: float(np.mean([mm[k] for mm in fold_ms])) for k in fold_ms[0].keys()} if fold_ms else {}
        oof_df = pd.concat(oof_rows, ignore_index=True) if oof_rows else pd.DataFrame()

        report[name] = {"cv_avg": avg, "rows_used": int(len(use)), "features": feat_cols}

        # 전체 데이터로 모델 재학습 후 저장
        model.fit(X, y)
        tag = f"{target}_{name}"
        joblib.dump({"model": model, "features": feat_cols, "rows": use["period"].tolist()}, OUT_DIR / f"{tag}.joblib")
        
        # Out-of-fold 예측 결과 및 성능 지표 저장
        oof_df.to_csv(REPORTS / f"oof_{tag}.csv", index=False, encoding="utf-8-sig")
        with open(REPORTS / f"metrics_{tag}.json", "w", encoding="utf-8") as f:
            json.dump(report[name], f, ensure_ascii=False, indent=2)

    print(f"  -> '{target}' 모델 학습 완료. CV 결과 요약: {json.dumps(report, ensure_ascii=False)}")
    return report

def main():
    """메인 실행 함수: 데이터를 로드하고, 각 대상 변수에 대해 모델을 학습시킨 후 결과를 저장합니다."""
    if not DATA_WIDE.exists():
        raise FileNotFoundError(f"{DATA_WIDE} 가 없습니다. 03b_build_ml_dataset_final 이후를 먼저 실행하세요.")
    df = pd.read_csv(DATA_WIDE)
    if "period" not in df.columns:
        raise ValueError("ml_dataset_wide.csv 에 'period' 컬럼이 없습니다.")
    
    # 데이터를 시간순으로 정렬하고, 학습에는 분기(Q) 데이터만 사용합니다.
    df = sort_period(df)
    df = df[~df['period'].astype(str).str.endswith('Y')].reset_index(drop=True)

    if not any(c in df.columns for c in TARGETS):
        raise ValueError("학습 대상 컬럼(revenue, op_profit)이 데이터에 없습니다.")

    all_reports = {}
    for tgt in TARGETS:
        if tgt not in df.columns:
            print(f"[WARN] '{tgt}' 컬럼이 없어 건너뜁니다."); all_reports[tgt] = {}; continue
        all_reports[tgt] = train_for_target(df, tgt)

    # 최종 리포트 저장
    with open(REPORTS / "summary_metrics.json", "w", encoding="utf-8") as f:
        json.dump(all_reports, f, ensure_ascii=False, indent=2)
    print(f"\n[SUCCESS] 모든 모델 학습 완료. 모델 저장: {OUT_DIR}, 리포트 저장: {REPORTS}")

if __name__ == "__main__":
    main()