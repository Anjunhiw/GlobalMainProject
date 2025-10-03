# -*- coding: utf-8 -*-
"""
03a_ir_dataset_final.py (re-merged & finalized)
- data/raw의 연/통합 산출물(ir_*.csv, ir_*_YYYY.csv)을 모두 수집/병합
- 2025 규격 스키마(category/unit 등)으로 표준화
- 핵심키 중복제거 + period 오름차순 정렬(안전한 2단계 정렬)
- processed/long, processed/wide, master 및 현금흐름 대사 리포트 생성
"""

import pandas as pd
from pathlib import Path
import re
from typing import List

# === (ADD) lineage_group 기반 보조(브리지) 피처 생성 ===
import pandas as pd

def add_lineage_group_features(wide: pd.DataFrame, seg_long: pd.DataFrame) -> pd.DataFrame:
    """
    segments long(열: period, lineage_group, metric, value, ...)에서
    period×lineage_group×metric 합계를 만들고 wide에 period 기준으로 왼쪽조인하여
    *_lg_total 형태의 보조(브리지) 피처를 추가한다.
      - 생성 예: seg_revenue_MX_lg_total, seg_op_VD_DA_lg_total
      - 원본 seg_* 컬럼은 건드리지 않음(추가만).
    """
    need = {"period", "lineage_group", "metric", "value"}
    if not need.issubset(seg_long.columns):
        return wide

    use = seg_long.copy()
    keep_metrics = {"revenue", "op_profit"}
    use = use[use["metric"].isin(keep_metrics)]

    g = (use.groupby(["period", "lineage_group", "metric"], dropna=False)["value"]
            .sum()
            .reset_index())

    def _col(row):
        m = "revenue" if row["metric"] == "revenue" else "op"
        grp = str(row["lineage_group"]).replace("/", "_").replace(" ", "_")
        return f"seg_{m}_{grp}_lg_total"

    g["col"] = g.apply(_col, axis=1)

    # pivot을 위해 집계. "A/B"와 "A B"가 같은 열 이름으로 매핑될 수 있기 때문.
    g = g.groupby(["period", "col"])["value"].sum().reset_index()

    pv = g.pivot(index="period", columns="col", values="value").reset_index()
    out = wide.merge(pv, on="period", how="left")
    return out

BASE = Path(__file__).resolve().parent.parent
RAW  = BASE / "data" / "raw"
OUT  = BASE / "data" / "processed"
OUT_WIDE = OUT / "wide"
OUT_LONG = OUT / "long"
for d in [OUT, OUT_WIDE, OUT_LONG]:
    d.mkdir(parents=True, exist_ok=True)

# 현금흐름 대사 허용 오차 (0.1조 = 1,000억원)
MISMATCH_THRESH = 0.1  # 조원 단위

# ─────────────────────────────────────────────
# 공통 유틸
def norm_period(s):
    """문자열을 2024Q1/2025Q2/2024Y 형태로 표준화."""
    if not isinstance(s, str): 
        return s
    s = s.strip()
    # 2024Q1 / 2025Y 등 표준 케이스
    m = re.match(r"^(20\d{2})([QY])([1-4])?$", s)
    if m:
        return s
    # 2024_1Q, 2024-1Q, 2024 1Q, 1Q '24 등에서 복원
    m2 = re.search(r"(20\d{2})[^0-9a-zA-Z]?([1-4])\s*Q", s, re.I)
    if m2:
        return f"{m2.group(1)}Q{m2.group(2)}"
    m3 = re.search(r"([1-4])\s*Q\s*['’]?\s*(\d{2})", s)
    if m3:
        yy = 2000 + int(m3.group(2))
        return f"{yy}Q{m3.group(1)}"
    return s

def sort_period_key(p):
    """오름차순 정렬 키 (연도→연간/분기→분기번호)."""
    if not isinstance(p, str): 
        return (9999, 9, 9)
    m = re.match(r"^(20\d{2})([QY])([1-4])?$", p)
    if not m:
        return (9999, 9, 9)
    y = int(m.group(1)); t = m.group(2); q = m.group(3)
    return (y, 0 if t == "Y" else 1, int(q) if q else 0)

def standardize_value_column(df: pd.DataFrame) -> pd.DataFrame:
    """value_trillion 또는 value 중 하나를 value로 통일."""
    if df.empty: 
        return df
    cols_lower = {c.lower(): c for c in df.columns}
    if "value" in cols_lower:
        vc = cols_lower["value"]
        if vc != "value":
            df = df.rename(columns={vc: "value"})
    elif "value_trillion" in cols_lower:
        df = df.rename(columns={cols_lower["value_trillion"]:
                                 "value"})
    return df

def clean_str_cols(df: pd.DataFrame) -> pd.DataFrame:
    """문자열 컬럼 공백 정리."""
    for c in df.columns:
        if df[c].dtype == object:
            df[c] = df[c].astype(str).str.replace(r"\s+", " ", regex=True).str.strip()
    return df

def drop_cols(df: pd.DataFrame, cols: List[str]) -> pd.DataFrame:
    """불필요한 컬럼을 제거합니다."""
    keep = [c for c in df.columns if c not in cols]
    return df[keep]

# ─────────────────────────────────────────────
# 로더(패밀리 단위: 통합 + 연도별)
def _read_csv(path: Path, expect_cols=None) -> pd.DataFrame:
    if not path.exists():
        return pd.DataFrame(columns=expect_cols or [])
    df = pd.read_csv(path)
    return clean_str_cols(df)

def load_family(prefix: str) -> pd.DataFrame:
    """
    RAW 디렉토리에서 prefix로 시작하는 모든 CSV 파일(예: ir_quarter_2022.csv, ir_quarter.csv)을 읽어 병합합니다.
    - 연도별 파일과 통합 파일을 모두 로드하여 합친 후 중복을 제거합니다.
    - 스키마를 표준화하고(예: value 컬럼 통일) 불필요한 컬럼을 제거합니다.
    """
    files = list(RAW.glob(f"{prefix}_*.csv")) + [RAW / f"{prefix}.csv"]
    files = [p for p in files if p.exists()]
    if not files:
        print(f"[WARN] not found: {prefix}*")
        return pd.DataFrame()

    frames = []
    for p in sorted(set(files)):
        try:
            df = _read_csv(p)
            if not df.empty:
                frames.append(df)
        except Exception as e:
            print(f"[WARN] failed to read {p.name}: {e}")

    if not frames:
        return pd.DataFrame()

    df = pd.concat(frames, ignore_index=True, sort=False)
    df = standardize_value_column(clean_str_cols(df))
    if "category" not in df.columns and prefix in ("ir_balance", "ir_cashflow"):
        cat = "balance" if prefix == "ir_balance" else "cashflow"
        df = df.assign(category=cat)
    if "unit" not in df.columns and prefix in ("ir_balance", "ir_cashflow", "ir_segments"):
        df = df.assign(unit="조원")

    drop_candidates = [c for c in ["file", "page", "source"] if c in df.columns]
    if drop_candidates:
        df = drop_cols(df, drop_candidates)

    if "period" in df.columns:
        df["period"] = df["period"].map(norm_period)
        df = df[~df["period"].astype(str).str.match(r"^20\d{2}Y$")].copy()

    subset = []
    if prefix == "ir_quarter":
        subset = [c for c in ["period", "metric"] if c in df.columns]
    elif prefix == "ir_segments":
        seg_key = "segment_code" if "segment_code" in df.columns else ("segment" if "segment" in df.columns else None)
        subset = [c for c in ["period", seg_key, "metric"] if c and c in df.columns]
    else:
        subset = [c for c in ["period", "metric"] if c in df.columns]
    if subset:
        df = df.drop_duplicates(subset=subset).reset_index(drop=True)

    if "period" in df.columns:
        other = []
        if prefix == "ir_segments":
            other = [c for c in ["segment", "metric"] if c in df.columns]
        elif prefix in ("ir_balance", "ir_cashflow", "ir_quarter"):
            other = [c for c in ["metric"] if c in df.columns]
        if other:
            df = df.sort_values(by=other).reset_index(drop=True)
        df = df.sort_values(by="period", key=lambda s: s.map(sort_period_key)).reset_index(drop=True)

    return df

# ─────────────────────────────────────────────
# Wide 변환
def build_quarter_wide(dfq: pd.DataFrame) -> pd.DataFrame:
    """분기별 실적(long) 데이터를 wide 포맷으로 변환합니다."""
    if dfq.empty:
        return pd.DataFrame(columns=["period","revenue","op_profit"])
    dfq = standardize_value_column(dfq)
    need = {"period","metric","value"}
    if not need.issubset(dfq.columns):
        print("[WARN] quarter schema mismatch:", dfq.columns.tolist())
        return pd.DataFrame(columns=["period","revenue","op_profit"])
    use = dfq[["period","metric","value"]].copy()
    piv = use.pivot_table(index="period", columns="metric", values="value", aggfunc="first").reset_index()
    piv.columns = [str(c) for c in piv.columns]
    for k in ["revenue","op_profit"]:
        if k not in piv.columns: piv[k] = pd.NA
    piv = piv[["period","revenue","op_profit"]]
    return piv.sort_values("period", key=lambda s: s.map(sort_period_key))

def build_segments_wide(dfs: pd.DataFrame) -> pd.DataFrame:
    """부문별 실적(long) 데이터를 wide 포맷으로 변환합니다."""
    if dfs.empty:
        return pd.DataFrame(columns=["period"])
    dfs = standardize_value_column(dfs)
    if "segment" not in dfs.columns:
        if "segment_code" in dfs.columns:
            dfs = dfs.rename(columns={"segment_code": "segment"})
        elif "segment_name_en" in dfs.columns:
            dfs = dfs.rename(columns={"segment_name_en": "segment"})

    need = {"period","segment","metric","value"}
    if not need.issubset(dfs.columns):
        print("[WARN] segments schema mismatch:", dfs.columns.tolist())
        return pd.DataFrame(columns=["period"])
    use = dfs[["period","segment","metric","value"]].copy()
    rev = use[use["metric"].str.lower()=="revenue"][[ "period","segment","value"]].copy()
    op  = use[use["metric"].str.lower().isin(["op_profit","op","operating_profit"])] [[ "period","segment","value"]].copy()
    rev_p = rev.pivot_table(index="period", columns="segment", values="value", aggfunc="first").add_prefix("seg_revenue_")
    op_p  = op.pivot_table(index="period", columns="segment", values="value", aggfunc="first").add_prefix("seg_op_")
    out = pd.concat([rev_p, op_p], axis=1).reset_index()
    out.columns = [str(c) for c in out.columns]
    return out.sort_values("period", key=lambda s: s.map(sort_period_key))

def build_balance_wide(dfb: pd.DataFrame) -> pd.DataFrame:
    """재무상태표(long) 데이터를 wide 포맷으로 변환합니다."""
    if dfb.empty:
        return pd.DataFrame(columns=["period"])
    dfb = standardize_value_column(dfb)
    use = dfb.copy()
    if "category" in use.columns:
        use = use[use["category"].astype(str).str.lower()=="balance"]
    need = {"period","metric","value"}
    if not need.issubset(use.columns):
        print("[WARN] balance schema mismatch:", use.columns.tolist())
        return pd.DataFrame(columns=["period"])
    piv = use.pivot_table(index="period", columns="metric", values="value", aggfunc="first").reset_index()
    piv.columns = ["period"] + [f"bal_{{c}}" for c in piv.columns[1:]]
    return piv.sort_values("period", key=lambda s: s.map(sort_period_key))

def build_cashflow_wide(dfc: pd.DataFrame) -> pd.DataFrame:
    """현금흐름표(long) 데이터를 wide 포맷으로 변환합니다."""
    if dfc.empty:
        return pd.DataFrame(columns=["period"])
    dfc = standardize_value_column(dfc)
    use = dfc.copy()
    if "category" in use.columns:
        use = use[use["category"].astype(str).str.lower()=="cashflow"]
    need = {"period","metric","value"}
    if not need.issubset(use.columns):
        print("[WARN] cashflow schema mismatch:", dfc.columns.tolist())
        return pd.DataFrame(columns=["period"])
    piv = use.pivot_table(index="period", columns="metric", values="value", aggfunc="first").reset_index()
    piv.columns = ["period"] + [f"cf_{{c}}" for c in piv.columns[1:]]
    return piv.sort_values("period", key=lambda s: s.map(sort_period_key))

# ─────────────────────────────────────────────
def main():
    """
    raw 디렉토리의 모든 IR 관련 CSV 파일을 로드하여 병합하고 표준화합니다.
    - Long 포맷 데이터셋 생성 및 저장
    - Wide 포맷 데이터셋 생성 및 저장
    - 모든 Wide 포맷 데이터를 병합한 마스터 데이터셋 생성
    - 모든 Long 포맷 데이터를 병합한 마스터 데이터셋 생성
    - 현금흐름표 데이터의 일관성을 검증하는 대사(reconciliation) 리포트 생성
    """
    # (A) raw 산출물 패밀리 로딩(연도별 + 통합 자동 병합)
    q_long = load_family("ir_quarter")
    s_long = load_family("ir_segments")
    b_long = load_family("ir_balance")
    c_long = load_family("ir_cashflow")

    # (A-1) processed/long 저장
    if not q_long.empty: q_long.to_csv(OUT_LONG/"ir_quarter_long.csv", index=False, encoding="utf-8-sig")
    if not s_long.empty: s_long.to_csv(OUT_LONG/"ir_segments_long.csv", index=False, encoding="utf-8-sig")
    if not b_long.empty: b_long.to_csv(OUT_LONG/"ir_balance_long.csv", index=False, encoding="utf-8-sig")
    if not c_long.empty: c_long.to_csv(OUT_LONG/"ir_cashflow_long.csv", index=False, encoding="utf-8-sig")

    # (B) wide 생성
    q_wide = build_quarter_wide(q_long)
    s_wide = build_segments_wide(s_long)
    if 's_long' in locals() and not s_long.empty:
        s_wide = add_lineage_group_features(s_wide, seg_long=s_long)

    b_wide = build_balance_wide(b_long)
    c_wide = build_cashflow_wide(c_long)

    # (B-1) processed/wide 저장
    if not q_wide.empty: q_wide.to_csv(OUT_WIDE/"ir_quarter_wide.csv", index=False, encoding="utf-8-sig")
    if not s_wide.empty: s_wide.to_csv(OUT_WIDE/"ir_segments_wide.csv", index=False, encoding="utf-8-sig")
    if not b_wide.empty: b_wide.to_csv(OUT_WIDE/"ir_balance_wide.csv", index=False, encoding="utf-8-sig")
    if not c_wide.empty: c_wide.to_csv(OUT_WIDE/"ir_cashflow_wide.csv", index=False, encoding="utf-8-sig")

    # (C) wide master (outer join)
    wide_master = q_wide.copy()
    for dfw in [s_wide, b_wide, c_wide]:
        if not dfw.empty:
            wide_master = wide_master.merge(dfw, on="period", how="outer")
    wide_master = wide_master.sort_values("period", key=lambda s: s.map(sort_period_key))
    wide_master.to_csv(OUT/"ir_wide_master.csv", index=False, encoding="utf-8-sig")
    print(f"Saved: {OUT/'ir_wide_master.csv'} (rows={len(wide_master)})")

    # (D) long master (원본 보존 통합)
    def tag(df, name):
        if df.empty: return df
        x = df.copy(); x["dataset"] = name
        return x
    long_master = pd.concat([
        tag(q_long, "quarter"),
        tag(s_long, "segments"),
        tag(b_long, "balance"),
        tag(c_long, "cashflow"),
    ], ignore_index=True, sort=False)
    if "period" in long_master.columns:
        long_master = long_master.sort_values("period", key=lambda s: s.map(sort_period_key))
    long_master.to_csv(OUT/"ir_long_master.csv", index=False, encoding="utf-8-sig")
    print(f"Saved: {OUT/'ir_long_master.csv'} (rows={len(long_master)})")

    # (E) 요약현금흐름 대사(조원 단위)
    # 현금흐름표의 주요 항목들이 서로 일치하는지 검증합니다.
    # 예: 영업활동 + 투자활동 + 재무활동 현금흐름 = 현금의 증감
    reco_cols = ["period","cf_cfo","cf_cfi","cf_cff","cf_cash_begin","cf_cash_end","cf_cash_change","cf_net_cash"]
    have_cols = [c for c in reco_cols if c in wide_master.columns]
    if have_cols:
        reco = wide_master[have_cols].copy()
        
        # 계산1: 활동 현금흐름의 합 (영업+투자+재무)
        reco["sum_flows"] = reco[[c for c in ["cf_cfo", "cf_cfi", "cf_cff"] if c in reco.columns]].fillna(0).sum(axis=1)
        
        # 검증1: 활동 현금흐름 합계와 공시된 '현금의 증감'이 일치하는지 확인
        reco["diff_change"] = reco.get("cf_cash_change", 0) - reco["sum_flows"]
        reco["abs_diff_change"] = reco["diff_change"].abs()

        # 검증2: 기초 현금과 기말 현금의 차이가 활동 현금흐름 합계와 일치하는지 확인
        reco["delta_from_balance"] = reco.get("cf_cash_end", 0) - reco.get("cf_cash_begin", 0)
        reco["diff_balance"] = reco["delta_from_balance"] - reco["sum_flows"]
        reco["abs_diff_balance"] = reco["diff_balance"].abs()

        # 불일치 여부 플래그: 허용 오차(0.1조원)를 초과하는 경우
        reco["mismatch_flag"] = reco["abs_diff_change"] > MISMATCH_THRESH
        reco["mismatch_note"] = reco["mismatch_flag"].apply(
            lambda x: "scope/rounding (IR summary)" if x else ""
        )

        def largest_component(row):
            parts = {
                "cfo": abs(row.get("cf_cfo", 0) or 0),
                "cfi": abs(row.get("cf_cfi", 0) or 0),
                "cff": abs(row.get("cf_cff", 0) or 0),
            }
            return max(parts, key=parts.get) if parts else ""
        reco["largest_flow_component"] = reco.apply(largest_component, axis=1)

        reco = reco.sort_values("period", key=lambda s: s.map(sort_period_key))
        reco.to_csv(OUT/"ir_cashflow_recon.csv", index=False, encoding="utf-8-sig")
        print(f"Saved: {OUT/'ir_cashflow_recon.csv'} (rows={len(reco)})")

        n_bad = int(reco["mismatch_flag"].sum())
        if n_bad:
            print(f"[WARN] Cashflow change mismatch in {n_bad} rows (>{MISMATCH_THRESH}조)")
        else:
            print("[OK] Cashflow change reconciliation passed")

if __name__ == "__main__":
    main()