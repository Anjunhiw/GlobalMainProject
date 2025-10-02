# -*- coding: utf-8 -*-
"""
05b_train_next_final.py  (FY 안전 패치 버전)
- 05a에서 저장한 모델(joblib)의 feature 리스트를 읽고,
  df(ml_dataset_wide.csv)에서 필요한 lag/rmean 피처를 즉석 재계산한 뒤
  마지막 '분기(Q)' 관측을 기준으로 다음 분기 1-step 예측.
"""
import re
import joblib
import numpy as np
import pandas as pd
from pathlib import Path

# --- 경로 설정 ---
BASE_DIR = Path(__file__).resolve().parent.parent
DATA_WIDE = BASE_DIR / "data" / "final" / "ml_dataset_wide.csv"
MODELS_DIR = BASE_DIR / "models"
REPORTS_DIR = BASE_DIR / "reports"
REPORTS_DIR.mkdir(parents=True, exist_ok=True)

TARGETS = ["revenue", "op_profit"]

# --- 유틸리티 함수 ---
def _period_sort_key(s: str):
    """'2024Q1' 같은 기간 문자열을 정렬 가능한 튜플로 변환합니다."""
    s = str(s)
    m = re.match(r"^(20\d{2})([QY])([1-4])?$", s)
    if not m: return (9999, 9, 9)
    y, t, q = int(m.group(1)), m.group(2), m.group(3)
    return (y, 0 if t == 'Y' else 1, int(q) if q else 0)

def period_next(p: str) -> str:
    """주어진 기간의 다음 분기를 반환합니다. (예: 2024Q1 -> 2024Q2, 2024Q4 -> 2025Q1)"""
    p = str(p)
    y = int(p[:4])
    if p.endswith("FY"):
        return f"{y+1}Q1"
    q = int(p[-1])
    return f"{y+1}Q1" if q == 4 else f"{y}Q{q+1}"

def load_data() -> pd.DataFrame:
    """예측의 기반이 될 시계열 데이터를 로드하고 시간순으로 정렬합니다."""
    if not DATA_WIDE.exists():
        raise FileNotFoundError(f"[ERROR] 데이터 파일이 없습니다: {DATA_WIDE}")
    df = pd.read_csv(DATA_WIDE)
    if "period" not in df.columns:
        raise ValueError("ml_dataset_wide.csv에 'period' 컬럼이 없습니다.")
    df = df.sort_values("period", key=lambda s: s.map(_period_sort_key)).reset_index(drop=True)
    return df

LAG_RE   = re.compile(r"^(?P<base>.+)_lag(?P<n>\\d+)$")
RMEAN_RE = re.compile(r"^(?P<base>.+)_rmean(?P<w>\\d+)$")

def ensure_features(df: pd.DataFrame, feat_cols: list) -> pd.DataFrame:
    """
    예측에 필요한 피처가 DataFrame에 없으면 동적으로 생성합니다.
    모델이 요구하는 lag, rmean 피처(예: 'revenue_lag1')가 df에 없을 경우,
    피처 이름(revenue)과 파라미터(lag=1)를 파싱하여 원본 'revenue' 컬럼에서 .shift(1)을 적용해 생성합니다.
    """
    out = df.copy()
    for col in feat_cols:
        if col in out.columns: continue
        m1 = LAG_RE.match(col)
        m2 = RMEAN_RE.match(col)
        if m1:
            base = m1.group("base"); n = int(m1.group("n"))
            if base not in out.columns:
                raise KeyError(f"'{base}' 원본 컬럼이 없어 '{col}'를 만들 수 없습니다.")
            out[col] = out[base].shift(n)
        elif m2:
            base = m2.group("base"); w = int(m2.group("w") )
            if base not in out.columns:
                raise KeyError(f"'{base}' 원본 컬럼이 없어 '{col}'를 만들 수 없습니다.")
            out[col] = out[base].rolling(w, min_periods=1).mean().shift(1)
    return out

def build_X_for_last_row(df_feat: pd.DataFrame, feat_cols: list) -> np.ndarray:
    """
    예측을 위한 입력 벡터(X)를 생성합니다.
    - 가장 최근의 완전한(결측치가 없는) 분기(Q) 데이터를 사용합니다.
    - 최근 데이터부터 역순으로 탐색하여 결측치가 없는 첫 번째 행을 선택합니다.
    - 모든 행에 결측치가 있을 경우, 마지막 행을 기준으로 각 피처의 중앙값(median)으로 결측치를 채워 벡터를 생성합니다.
    """
    if len(df_feat) == 0:
        raise ValueError("예측용 데이터가 비어 있습니다.")
    # 분기(Q) 데이터만 필터링하여 사용
    df_q = df_feat[df_feat["period"].astype(str).str.contains(r"Q[1-4]$")]
    if not df_q.empty:
        df_feat = df_q

    # 아래에서부터(최신순) 결측치가 없는 완전한 행을 탐색
    for i in range(len(df_feat)-1, -1, -1):
        row = df_feat.iloc[i]
        if not row[feat_cols].isna().any():
            return row[feat_cols].values.reshape(1, -1)

    # 완전한 행이 없을 경우: 마지막 행을 기준으로, 결측치는 각 피처의 중앙값으로 대치
    med = df_feat[feat_cols].median(numeric_only=True)
    last = df_feat.tail(1).copy()
    for c in feat_cols:
        if pd.isna(last.iloc[0][c]):
            last.loc[last.index[-1], c] = med.get(c, 0.0)
    last = last.fillna(0.0)
    return last[feat_cols].values

def predict_one(model_path: Path, df_raw: pd.DataFrame) -> dict:
    """하나의 저장된 모델을 로드하여 다음 분기를 예측합니다."""
    # 1. 모델과 피처 리스트 로드
    bundle = joblib.load(model_path)
    model = bundle["model"]
    feat_cols = bundle.get("features", [])
    if not feat_cols:
        raise ValueError(f"[ERROR] 모델에 features 정보가 없습니다: {model_path.name}")
    
    # 2. 예측에 필요한 피처 생성
    df_feat = ensure_features(df_raw, feat_cols)
    
    # 3. 예측에 사용할 입력 데이터(X) 생성
    X = build_X_for_last_row(df_feat, feat_cols)
    
    # 4. 예측 수행
    yhat = float(model.predict(X)[0])
    
    # 5. 예측 대상 기간 계산
    last_period = df_raw["period"].iloc[-1]
    df_q = df_raw[df_raw["period"].astype(str).str.contains(r"Q[1-4]$")]
    base_period = df_q["period"].iloc[-1] if not df_q.empty else last_period
    next_period = period_next(base_period)
    
    return {"period_next": next_period, "y_pred": yhat, "features_used": len(feat_cols)}

def main():
    """메인 실행 함수: 저장된 모델들을 로드하여 다음 분기 실적을 예측하고 결과를 저장합니다."""
    df = load_data()
    results = []
    
    # 각 대상(revenue, op_profit) 및 모델(linear, rf)에 대해 예측 수행
    for tgt in TARGETS:
        for base in ["linear", "rf"]:
            path = MODELS_DIR / f"{tgt}_{base}.joblib"
            if not path.exists():
                print(f"[WARN] 모델 파일을 찾을 수 없습니다: {path.name}")
                continue
            try:
                res = predict_one(path, df)
                res["target"] = tgt; res["model"] = base
                results.append(res)
            except Exception as e:
                print(f"[ERR] 예측 실패: {path.name}: {e}")

    if not results:
        print("[INFO] 생성된 예측 결과가 없습니다. 모델/데이터를 확인하세요."); return

    # 예측 결과를 DataFrame으로 변환하여 CSV 파일로 저장
    out = pd.DataFrame(results)
    out_path = REPORTS_DIR / "next_quarter_predictions.csv"
    out.to_csv(out_path, index=False, encoding="utf-8-sig")
    print(f"\n다음 분기 예측 결과가 저장되었습니다: {out_path}")
    print(out)

if __name__ == "__main__":
    main()
