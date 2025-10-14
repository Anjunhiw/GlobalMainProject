# -*- coding: utf-8 -*-
"""
03b_build_ml_dataset_final.py  (lineage_group 지원 확장판)
- IR(03a: processed), DART(02a: external), 공공데이터(02b: external)를 period 기준 병합
- 결과: data/final/ml_dataset_wide.csv, data/final/ml_dataset_long.csv
- 추가: 03a 결과에 _lg_total 컬럼이 없으면, ir_long에서 lineage_group×metric 합계를 재구성해 wide에 병합
"""

from __future__ import annotations
from pathlib import Path
import pandas as pd

BASE  = Path(__file__).resolve().parent.parent
PROC  = BASE / "data" / "processed"
EXT   = BASE / "data" / "external"
FINAL = BASE / "data" / "final"
BACKUP = BASE / "data" / "backup"
FINAL.mkdir(parents=True, exist_ok=True)

# ---------- 공통 유틸 ----------
def read_csv_safe(p: Path, **kwargs) -> pd.DataFrame:
    """CSV 파일을 안전하게 읽어 DataFrame으로 반환합니다. 파일이 없으면 backup에서 찾고, 그래도 없으면 빈 DataFrame을 반환합니다."""
    if not p.exists():
        backup_p = BACKUP / p.name
        if backup_p.exists():
            print(f"[INFO] '{p.name}' not found, using backup.")
            p = backup_p
        else:
            print(f"[WARN] not found: {p} (no backup available)")
            return pd.DataFrame()
    try:
        return pd.read_csv(p, **kwargs)
    except Exception as e:
        print(f"[WARN] failed to read {p}: {e}")
        return pd.DataFrame()

def normalize_long_columns(df: pd.DataFrame) -> pd.DataFrame:
    """
    다양한 형태의 데이터프레임을 표준 Long 포맷('period', 'series', 'value')으로 정규화합니다.
    - 'period', 'series', 'value' 컬럼이 없는 경우, 일반적인 후보군(예: '분기', 'metric')에서 찾아 개명합니다.
    - Wide 포맷으로 추정될 경우, 'period'를 id로 하여 Long 포맷으로 변환(melt)합니다.
    """
    if df.empty:
        return df
    df = df.copy()
    # 1. 'period' 컬럼 정규화
    if "period" not in df.columns:
        cand = [c for c in ["period","분기"] if c in df.columns]
        if cand:
            df = df.rename(columns={cand[0]:"period"})
        else: # 'period' 컬럼을 찾을 수 없으면 처리 불가
            return pd.DataFrame(columns=["period","series","value"])
    df["period"] = df["period"].astype(str)
    
    # 2. 'series' 컬럼 정규화
    if "series" not in df.columns:
        cand = [c for c in ["series","metric","account","name","item"] if c in df.columns]
        if cand:
            df = df.rename(columns={cand[0]:"series"})
        else:
            # 'series' 후보가 없으면 wide 포맷으로 간주하고 melt 수행
            non_num = ["period"]
            value_candidates = [c for c in df.columns if c not in non_num]
            if value_candidates:
                df = df.melt(id_vars="period", var_name="series", value_name="value")
            else:
                return pd.DataFrame(columns=["period","series","value"])
                
    # 3. 'value' 컬럼 정규화
    if "value" not in df.columns:
        cand = [c for c in ["value","value_trillion","val","amount","value_jo"] if c in df.columns]
        if cand:
            df = df.rename(columns={cand[0]:"value"})
        else: # 그래도 없으면 남은 컬럼 중 첫 번째를 value로 간주
            others = [c for c in df.columns if c not in ["period","series"]]
            if not others:
                return pd.DataFrame(columns=["period","series","value"])
            df = df.rename(columns={others[0]:"value"})
            
    # 4. 'value'를 숫자형으로 변환
    with pd.option_context("mode.use_inf_as_na", True):
        df["value"] = pd.to_numeric(df["value"], errors="coerce")
        
    return df[["period","series","value"]]

# ---------- 데이터 소스별 블록 빌더 ----------
def build_ir_blocks() -> tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame]:
    """Processed 디렉토리에서 IR 관련 데이터셋(wide, long, cashflow-reconciliation)을 로드합니다."""
    ir_wide = read_csv_safe(PROC / "ir_wide_master.csv")
    ir_long = read_csv_safe(PROC / "ir_long_master.csv")
    ir_cfrec= read_csv_safe(PROC / "ir_cashflow_recon.csv")

    for df in (ir_wide, ir_long, ir_cfrec):
        if not df.empty and "period" in df.columns:
            df["period"] = df["period"].astype(str)
    return ir_wide, ir_long, ir_cfrec

def build_lineage_from_long(ir_long: pd.DataFrame) -> pd.DataFrame:
    """
    ir_long 데이터에서 lineage_group별, metric별 합계를 계산하여 wide 포맷의 브리지 피처를 생성합니다.
    결과 컬럼 예: seg_revenue_MX_lg_total, seg_op_VD_DA_lg_total
    """
    need = {"period","lineage_group","metric","value"}
    if ir_long.empty or not need.issubset(ir_long.columns):
        return pd.DataFrame()
    use = ir_long[ir_long["metric"].isin(["revenue","op_profit"])].copy()
    if use.empty:
        return pd.DataFrame()
    g = (use.groupby(["period","lineage_group","metric"], dropna=False)["value"]
            .sum().reset_index())
    def _col(row):
        m = "revenue" if row["metric"]=="revenue" else "op"
        grp = str(row["lineage_group"]).replace("/","_").replace(" ","_")
        return f"seg_{m}_{grp}_lg_total"
    g["col"] = g.apply(_col, axis=1)
    pv = g.pivot(index="period", columns="col", values="value").reset_index()
    return pv

def build_dart_block() -> tuple[pd.DataFrame, pd.DataFrame]:
    """External 디렉토리에서 DART 재무 데이터를 로드하고 wide, long 포맷으로 가공합니다."""
    dart = read_csv_safe(EXT / "dart_quarter_single_accounts.csv")
    if dart.empty:
        return pd.DataFrame(), pd.DataFrame()
    dart["period"] = dart["period"].astype(str)
    if "value" in dart.columns:
        dart["value_jo"] = dart["value"].astype(float) / 1_000_000_000_000.0
    else:
        print("[WARN] dart missing 'value' column")
        dart["value_jo"] = pd.NA

    if {"period","account","value_jo"} <= set(dart.columns):
        dart_w = (dart.pivot_table(index="period", columns="account", values="value_jo", aggfunc="first")
                       .rename(columns=lambda c: f"dart_{c}")
                       .reset_index())
    else:
        dart_w = pd.DataFrame()

    dart_l = dart.copy()
    if "account" in dart_l.columns:
        dart_l["series"] = "dart_" + dart_l["account"].astype(str)
    else:
        dart_l["series"] = "dart_value"
    dart_l = dart_l[["period","series","value_jo"]].rename(columns={"value_jo":"value"})
    return dart_w, dart_l

def build_public_block() -> tuple[pd.DataFrame, pd.DataFrame]:
    """External 디렉토리에서 공공 데이터를 로드하고 wide, long 포맷으로 가공합니다."""
    pub_q = read_csv_safe(EXT / "public_quarter_series.csv")
    if pub_q.empty:
        return pd.DataFrame(), pd.DataFrame()
    pub_q["period"] = pub_q["period"].astype(str)

    if {"period","series","value"} <= set(pub_q.columns):
        pub_w = pub_q.pivot_table(index="period", columns="series", values="value", aggfunc="first").reset_index()
        pub_l = pub_q[["period","series","value"]].copy()
    else:
        pub_w = pub_q.copy()
        pub_l = pub_q.melt(id_vars="period", var_name="series", value_name="value")

    if not pub_w.empty:
        pub_w = pub_w.rename(columns={c: f"pub_{c}" for c in pub_w.columns if c != "period"})
    if not pub_l.empty:
        pub_l["series"] = "pub_" + pub_l["series"].astype(str)
    return pub_w, pub_l

# ---------- 병합 로직 ----------
def make_wide_master(ir_wide, ir_long, dart_w, pub_w, ir_cfrec) -> pd.DataFrame:
    """모든 wide 포맷 데이터를 병합하여 최종 ML용 wide 데이터셋을 생성합니다."""
    # 1. 기본 병합: IR, DART, 공공 데이터를 'period' 기준으로 outer join 합니다.
    wide = None
    for block in [ir_wide, dart_w, pub_w]:
        if block is None or block.empty:
            continue
        wide = block if wide is None else wide.merge(block, on="period", how="outer")

    if wide is None:
        wide = pd.DataFrame(columns=["period"])

    # 2. Lineage group 피처 보강: wide 데이터에 lineage_group 피처가 없으면 long 데이터에서 생성하여 병합합니다.
    has_lg = any(str(c).endswith("_lg_total") for c in (ir_wide.columns if not ir_wide.empty else []))
    if not has_lg and ir_long is not None and not ir_long.empty:
        lg_w = build_lineage_from_long(ir_long)
        if not lg_w.empty:
            print(f"[INFO] add lineage_group totals from ir_long: {len([c for c in lg_w.columns if c!='period'])} cols")
            wide = wide.merge(lg_w, on="period", how="left")

    # 3. IR 현금흐름 대사 결과 병합 (선택 사항)
    if not wide.empty and ir_cfrec is not None and not ir_cfrec.empty:
        cols_to_add = [c for c in ["cf_mismatch","cf_diff","cf_note"] if c in ir_cfrec.columns]
        if cols_to_add:
            wide = wide.merge(ir_cfrec[["period"] + cols_to_add].drop_duplicates("period"),
                              on="period", how="left")
    return wide

def make_long_master(ir_long, dart_l, pub_l) -> pd.DataFrame:
    """모든 long 포맷 데이터를 병합하여 최종 long 데이터셋을 생성합니다."""
    frames = []
    if ir_long is not None and not ir_long.empty:
        frames.append(normalize_long_columns(ir_long))
    if dart_l is not None and not dart_l.empty:
        frames.append(normalize_long_columns(dart_l))
    if pub_l is not None and not pub_l.empty:
        frames.append(normalize_long_columns(pub_l))
    if not frames:
        return pd.DataFrame(columns=["period","series","value"])
    long = pd.concat(frames, ignore_index=True)
    long = long.dropna(subset=["period","series"]).drop_duplicates(subset=["period","series"], keep="last")
    return long

# ---------- 메인 실행 함수 ----------
def main():
    """모든 데이터 소스를 로드, 가공, 병합하여 최종 ML 데이터셋(wide, long)을 생성하고 저장합니다."""
    # 1. 각 데이터 소스(IR, DART, Public)에서 데이터 블록을 빌드합니다.
    ir_wide, ir_long, ir_cfrec = build_ir_blocks()
    dart_w, dart_l = build_dart_block()
    pub_w,  pub_l  = build_public_block()

    # 2. Wide/Long 마스터 데이터셋을 생성합니다.
    wide = make_wide_master(ir_wide, ir_long, dart_w, pub_w, ir_cfrec)
    long = make_long_master(ir_long, dart_l, pub_l)

    # 3. 최종 데이터셋을 파일로 저장합니다.
    out_w = FINAL / "ml_dataset_wide.csv"
    out_l = FINAL / "ml_dataset_long.csv"
    wide.to_csv(out_w, index=False)
    long.to_csv(out_l, index=False)

    print(f"Saved: {out_w} (rows={len(wide)})")
    print(f"Saved: {out_l} (rows={len(long)})")

    # 간단한 결과 요약 로그 출력
    for col in ["revenue","op_profit","dart_cfo","dart_cfi","dart_cff"]:
        if col in wide.columns:
            print(f"[INFO] wide missing count {col}: {wide[col].isna().sum()}")

if __name__ == "__main__":
    main()