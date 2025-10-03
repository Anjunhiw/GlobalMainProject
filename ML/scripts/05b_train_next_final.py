
# -*- coding: utf-8 -*-
"""
05b_train_next_final_fix.py  (v3: robust model loader + ffill fix)
- 분기(YYYYQ[1-4])만 사용
- lag/rmean 즉석 생성 (shift 포함)
- 열 축 선택 수정
- 마지막/직전 행 폴백 (+ ffill 경고 해결)
- 모델 아티팩트가 dict로 저장된 경우도 지원 (예: {"pipe": ..., "features": [...], ...})
"""

import re
import json
import time
import joblib
import numpy as np
import pandas as pd
from pathlib import Path
from typing import List, Optional, Tuple, Any

# --- 경로 설정 ---
BASE_DIR = Path(__file__).resolve().parent.parent  # .../ML/scripts -> repo root
DATA_WIDE = BASE_DIR / "data" / "final" / "ml_dataset_wide.csv"
MODELS_DIR = BASE_DIR / "models"
REPORTS_DIR = BASE_DIR / "reports"
REPORTS_DIR.mkdir(parents=True, exist_ok=True)

TARGETS = ["revenue", "op_profit"]
QRE = re.compile(r"^\d{4}Q[1-4]$")

# --- 유틸: period 정렬/증분 ---
def _period_key(s: str):
    s = str(s)
    try:
        y = int(s[:4]); q = int(s[-1])
        return (y, q)
    except Exception:
        return (9999, 9)

def period_next(p: str) -> str:
    s = str(p)
    if not QRE.match(s):
        raise ValueError(f"Invalid quarterly period for period_next: {p}")
    y = int(s[:4]); q = int(s[-1])
    q2 = q + 1
    return f"{y+1}Q1" if q2 == 5 else f"{y}Q{q2}"

# --- 유틸: lag / rmean 피처 즉석 생성 ---
LAG_RE   = re.compile(r"^(?P<base>.+)_lag(?P<n>\d+)$")
RMEAN_RE = re.compile(r"^(?P<base>.+)_rmean(?P<w>\d+)$")

def ensure_features(df: pd.DataFrame, feat_cols: List[str]) -> pd.DataFrame:
    out = df.copy()
    for col in feat_cols:
        if col in out.columns:
            continue
        m1 = LAG_RE.match(col)
        m2 = RMEAN_RE.match(col)
        if m1:
            base = m1.group("base"); n = int(m1.group("n"))
            if base not in out.columns:
                raise KeyError(f"'{base}' 원본 컬럼이 없어 '{col}'를 만들 수 없습니다.")
            out[col] = out[base].shift(n)
        elif m2:
            base = m2.group("base"); w = int(m2.group("w"))
            if base not in out.columns:
                raise KeyError(f"'{base}' 원본 컬럼이 없어 '{col}'를 만들 수 없습니다.")
            out[col] = out[base].rolling(w, min_periods=1).mean().shift(1)
        else:
            # 기타 특수 피처명은 05a 사이드카를 통해서만 지원
            pass
    return out

def build_X_from_tail(df_feat: pd.DataFrame, feat_cols: List[str]) -> Optional[pd.DataFrame]:
    """마지막 행에서 피처 추출; NaN 있으면 직전 행으로 폴백. 실패 시 None"""
    if len(df_feat) == 0:
        return None
    try_rows = [df_feat.tail(1)]
    if len(df_feat) >= 2:
        try_rows.append(df_feat.tail(2).head(1))
    for row in try_rows:
        sub = row.loc[:, feat_cols]  # 열 축 선택
        if not sub.isna().any(axis=1).item():
            return sub
    # 모두 NaN 포함이면 결측 대체(앞 값 채움) 후 재시도
    filled = df_feat.ffill()
    sub2 = filled.tail(1).loc[:, feat_cols]
    if not sub2.isna().any(axis=1).item():
        return sub2
    return None

# --- 피처 목록 사이드카 로더 ---
def load_feat_cols_sidecar(model_path: Path) -> Optional[List[str]]:
    cand = [
        model_path.with_suffix(".features.joblib"),
        model_path.with_suffix(".features.json"),
    ]
    for p in cand:
        if p.exists():
            try:
                if p.suffix == ".joblib":
                    cols = joblib.load(p)
                else:
                    cols = json.loads(p.read_text(encoding="utf-8"))
                if isinstance(cols, list) and all(isinstance(c, str) for c in cols):
                    return cols
            except Exception:
                pass
    return None

# --- 모델 로더 (dict 아티팩트 지원) ---
def extract_estimator(obj: Any) -> Optional[Any]:
    """obj에서 predict 가능한 추정기를 찾아 반환."""
    if hasattr(obj, "predict"):
        return obj
    if isinstance(obj, dict):
        # 우선순위 키 후보
        for k in ["pipe", "model", "estimator", "best_estimator_", "sk_model"]:
            v = obj.get(k)
            if hasattr(v, "predict"):
                return v
    return None

def extract_features(obj: Any) -> Optional[List[str]]:
    """obj(dict)에 포함된 피처 목록을 추출."""
    if isinstance(obj, dict):
        for k in ["features", "feat_cols", "feature_names"]:
            v = obj.get(k)
            if isinstance(v, list) and all(isinstance(c, str) for c in v):
                return v
    return None

SAFE_FALLBACK_FEATS = ["revenue_lag1", "op_profit_lag1"]

def main():
    if not DATA_WIDE.exists():
        raise FileNotFoundError(f"[ERROR] 데이터 파일이 없습니다: {DATA_WIDE}")
    if not MODELS_DIR.exists():
        raise FileNotFoundError(f"[ERROR] 모델 폴더가 없습니다: {MODELS_DIR}")

    raw = pd.read_csv(DATA_WIDE)
    if "period" not in raw.columns:
        raise ValueError("ml_dataset_wide.csv에 'period' 컬럼이 없습니다.")

    # --- 분기만 사용 (연간 YYYY'Y' 제거)
    df = raw[raw["period"].astype(str).str.match(QRE)].copy()
    if df.empty:
        raise RuntimeError("분기(YYYYQ[1-4]) 데이터가 없습니다.")
    df = df.sort_values("period", key=lambda s: s.map(_period_key)).reset_index(drop=True)

    last_period = str(df["period"].iloc[-1])
    nxt_period  = period_next(last_period)

    out_rows = []
    for target in TARGETS:
        # revenue_.joblib (백워드 호환) + revenue_*.joblib
        model_files = sorted(MODELS_DIR.glob(f"{target}_.joblib")) + sorted(MODELS_DIR.glob(f"{target}_*.joblib"))
        if not model_files:
            print(f"[WARN] 모델 없음: {target}*.joblib")
            continue

        for mp in model_files:
            model_name = mp.stem  # e.g., revenue_linear
            try:
                obj = joblib.load(mp)
                est = extract_estimator(obj)
                if est is None:
                    raise TypeError("로드된 객체에서 예측 가능한 모델을 찾을 수 없습니다.")

                # 피처 목록: 사이드카 > 아티팩트 내장 > 기본값
                feat_cols = load_feat_cols_sidecar(mp) or extract_features(obj) or SAFE_FALLBACK_FEATS

                # 필요한 lag/rmean 즉석 생성
                df_feat = ensure_features(df, feat_cols)

                # 입력 X 구성
                sub = build_X_from_tail(df_feat, feat_cols)
                if sub is None:
                    raise RuntimeError(f"입력 행 구성 실패 (결측 과다) - {model_name}")

                X = sub.values  # (1, n_features)
                yhat = float(est.predict(X)[0])

                out_rows.append({
                    "model": model_name,
                    "target": target,
                    "period": last_period,
                    "next_period": nxt_period,
                    "prediction": yhat,
                    "features_used": ",".join(feat_cols),
                    "created_at": time.strftime("%Y-%m-%d %H:%M:%S"),
                })
                print(f"[OK] {model_name} -> {target} {nxt_period}: {yhat:.4f}")
            except Exception as e:
                print(f"[ERR] 예측 실패: {mp.name}: {e}")

    if not out_rows:
        print("[INFO] 생성된 예측 결과가 없습니다. 모델/데이터를 확인하세요.")
        return

    out_df = pd.DataFrame(out_rows)
    out_csv = REPORTS_DIR / "next_quarter_predictions.csv"
    if out_csv.exists():
        base = pd.read_csv(out_csv)
        out_df = pd.concat([base, out_df], ignore_index=True)

    out_df.to_csv(out_csv, index=False, encoding="utf-8-sig")
    print(f"[SAVED] 예측 결과: {out_csv} (rows={len(out_df)})")

if __name__ == "__main__":
    main()
