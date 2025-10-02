# -*- coding: utf-8 -*-
"""
02b_fetch_odcloudkr_api_final.py
- ODcloud(공공데이터포털 Infuser) API 수집 스크립트
- 반도체/디스플레이 산업 동향(연간) + 소재부품장비 출하지수(월별 wide → long → 분기 집계)
- 패치 내용:
  1) 견고한 .env 로더(따옴표/공백/끝 콤마 자동 제거 + 명시적 경로 로드)
  2) 올바른 엔드포인트: https://api.odcloud.kr/api + .env의 PATH 주입(UDDI 경로)
  3) 페이징 처리(모든 페이지 자동 수집)
  4) 분기 포맷 안전화(Period.astype(str) 사용; %q 미사용)
  5) 월→분기 집계 옵션(mean | eoq) 환경변수로 제어
  6) [v2] API 호출 실패 시 data/backup/의 백업 파일을 사용하도록 Fallback 로직 추가

필요 .env 키 (예시)
-----------------------------------------
ODCLOUDKR_API_KEY=발급키(Decoding)
ODCLOUD_SEMI_PATH=/15051125/v1/uddi:xxxxx-...
ODCLOUD_MPE_SHIP_PATH=/15099630/v1/uddi:yyyyy-...
ODCLOUD_MPE_AGG=mean   # or eoq (선택)
"""

from pathlib import Path
from dotenv import load_dotenv, dotenv_values
import os
import re
import pandas as pd
import requests


# ---------------------------
# 경로/환경 로딩 (견고하게)
# ---------------------------
BASE = Path(__file__).resolve().parent.parent
DATA_DIR = BASE / "data" / "external"
BACKUP_DIR = BASE / "data" / "backup"
DATA_DIR.mkdir(parents=True, exist_ok=True)

ENV_PATH = BASE / ".env"
load_dotenv(dotenv_path=ENV_PATH)
_cfg = dotenv_values(ENV_PATH)

def _clean(v: str | None) -> str | None:
    """
    환경 변수 값을 정리합니다. 입력값이 문자열이 아닐 수 있는 경우를 대비해
    먼저 문자열로 변환한 후, 양끝의 공백, 따옴표, 콤마를 제거합니다.
    """
    if v is None:
        return None
    # 숫자 등 문자열이 아닌 타입이 들어올 경우를 대비해 str()로 변환
    s = str(v)
    s = s.strip().strip("\"'").rstrip(",").strip()
    return s or None

def _env(*names, required=False) -> str | None:
    """시스템 환경변수 또는 .env 파일에서 값을 안전하게 로드합니다."""
    for n in names:
        v = os.getenv(n) or _cfg.get(n)
        v = _clean(v)
        if v:
            return v
    if required:
        raise RuntimeError(f"Missing env: one of {names} in {ENV_PATH}")
    return None

API_KEY         = _env("ODCLOUDKR_API_KEY", required=True)
SEMI_PATH       = _env("ODCLOUD_SEMI_PATH", required=True)
MPE_SHIP_PATH   = _env("ODCLOUD_MPE_SHIP_PATH", required=True)
MPE_AGG_MODE    = (_env("ODCLOUD_MPE_AGG") or "mean").lower()

BASE_URL = "https://api.odcloud.kr/api"


# ---------------------------
# 요청 유틸
# ---------------------------
def _odcloud_get(path: str, page=1, per_page=1000, params=None) -> dict:
    """odcloud API에 GET 요청을 보내는 래퍼(wrapper) 함수입니다."""
    if not path.startswith("/"):
        path = "/" + path
    url = f"{BASE_URL}{path}"
    q = {
        "serviceKey": API_KEY,
        "page": page,
        "perPage": per_page,
        "returnType": "json",
    }
    if params:
        q.update(params)
    try:
        r = requests.get(url, params=q, timeout=30)
        r.raise_for_status()
        js = r.json()
        return js
    except requests.exceptions.RequestException as e:
        print(f"[ERROR] API request failed for {url}: {e}")
        return {{}}

def odcloud_get_all(path: str, per_page=1000, params=None) -> list[dict]:
    """API 응답이 여러 페이지일 경우, 모든 페이지를 순회하며 데이터를 수집합니다."""
    all_rows = []
    page = 1
    while True:
        js = _odcloud_get(path, page=page, per_page=per_page, params=params)
        if not js:
            break # API 요청 실패
        data = js.get("data")
        if data is None:
            data = js if isinstance(js, list) else []
        if not data:
            break
        all_rows.extend(data)
        
        cur = js.get("currentCount", len(data))
        if cur < per_page:
            break
        page += 1
    return all_rows


# ---------------------------
# 변환 유틸
# ---------------------------
def to_numeric_safe(series: pd.Series) -> pd.Series:
    """다양한 비정규 숫자 표현을 안전하게 숫자형으로 변환합니다."""
    return pd.to_numeric(series.astype(str).str.replace(",", ""), errors="coerce")

def make_period_from_quarter_series(q_series: pd.Series) -> pd.Series:
    """pandas의 Period 객체를 'YYYYQn' 형태의 표준 문자열로 변환합니다."""
    return q_series.astype(str)


# ---------------------------
# 1) 반도체/디스플레이 산업 동향 (연간)
# ---------------------------
def fetch_semicon_display():
    """반도체/디스플레이 산업 동향 데이터를 수집하고 전처리하여 CSV로 저장합니다."""
    rows = odcloud_get_all(SEMI_PATH, per_page=1000)
    df = pd.DataFrame(rows)
    out_path = DATA_DIR / "public_semicon_display.csv"

    if df.empty:
        print("[WARN] Semicon/Display API returned no data. Attempting to use backup file.")
        backup_path = BACKUP_DIR / "public_semicon_display.csv"
        if backup_path.exists():
            df = pd.read_csv(backup_path)
            df.to_csv(out_path, index=False, encoding="utf-8-sig")
            print(f"Saved from backup: {out_path} (rows={len(df)})")
            return df
        else:
            print(f"[WARN] Backup file not found. Saved empty: {out_path}")
            df.to_csv(out_path, index=False, encoding="utf-8-sig")
            return df

    if "연도" in df.columns:
        df = df.rename(columns={"연도": "year"})
    
    for c in df.columns:
        if c == "year":
            continue
        df[c] = to_numeric_safe(df[c])

    df = df.sort_values("year")
    df.to_csv(out_path, index=False, encoding="utf-8-sig")
    print(f"Saved: {out_path} (rows={len(df)})")
    return df


# ---------------------------
# 2) 소재부품장비 출하지수 (월별 wide → long → 분기 집계)
# ---------------------------
def fetch_mpe_shipments():
    """소재부품장비 출하지수 데이터를 수집하고 월별->분기별 데이터로 가공하여 저장합니다."""
    rows = odcloud_get_all(MPE_SHIP_PATH, per_page=2000)
    df = pd.DataFrame(rows)
    
    mo_out = DATA_DIR / "public_mpe_shipments_monthly.csv"
    q_out  = DATA_DIR / "public_quarter_series.csv"

    if df.empty:
        print("[WARN] MPE Shipments API returned no data. Attempting to use backup files.")
        backup_monthly_path = BACKUP_DIR / "public_mpe_shipments_monthly.csv"
        backup_quarterly_path = BACKUP_DIR / "public_quarter_series.csv"
        
        if backup_monthly_path.exists() and backup_quarterly_path.exists():
            long_df = pd.read_csv(backup_monthly_path)
            q_df = pd.read_csv(backup_quarterly_path)
            
            long_df.to_csv(mo_out, index=False, encoding="utf-8-sig")
            q_df.to_csv(q_out, index=False, encoding="utf-8-sig")
            
            print(f"Saved from backup: {mo_out} (rows={len(long_df)})")
            print(f"Saved from backup: {q_out} (rows={len(q_df)})")
            return long_df, q_df
        else:
            print("[WARN] Backup files not found. Saving empty files.")
            df.to_csv(mo_out, index=False, encoding="utf-8-sig")
            pd.DataFrame(columns=["period", "mpe_shipments_index"]).to_csv(q_out, index=False, encoding="utf-8-sig")
            print(f"Saved: {mo_out} (rows=0)")
            print(f"Saved: {q_out} (rows=0)")
            return df, pd.DataFrame()

    # 1. Wide to Long 변환
    patt_num6 = re.compile(r".*(\d{6})$")
    date_cols = [c for c in df.columns if patt_num6.match(str(c))]
    id_cols = [c for c in df.columns if c not in date_cols]
    long = df.melt(id_vars=id_cols, value_vars=date_cols, var_name="metric", value_name="value")

    # 2. 날짜 정보 파싱
    long["yyyymm"] = long["metric"].str.extract(r"(\d{6})", expand=False)
    long["value"] = to_numeric_safe(long["value"])
    long["year"] = long["yyyymm"].str[:4].astype(int)
    long["month"] = long["yyyymm"].str[4:6].astype(int)
    long["date"] = pd.to_datetime(long["year"].astype(str) + "-" + long["month"].astype(str) + "-01")
    long["quarter"] = long["date"].dt.to_period("Q")

    # 3. 월별 데이터를 분기 데이터로 집계
    if MPE_AGG_MODE == "eoq":
        long["yyyymm_int"] = long["yyyymm"].astype(int)
        q = long.sort_values("yyyymm_int").groupby("quarter", as_index=False).tail(1)[["quarter", "value"]]
    else:
        q = long.groupby("quarter", as_index=False)["value"].mean()

    # 4. 최종 분기 데이터프레임 생성
    q["period"] = make_period_from_quarter_series(q["quarter"])
    q = q[["period", "value"]].rename(columns={"value": "mpe_shipments_index"})

    # 월별/분기별 데이터 저장
    long.to_csv(mo_out, index=False, encoding="utf-8-sig")
    q.to_csv(q_out, index=False, encoding="utf-8-sig")
    print(f"Saved: {mo_out} (rows={len(long)})")
    print(f"Saved: {q_out} (rows={len(q)})")

    return long, q


def main():
    """메인 실행 함수. 반도체/디스플레이 산업 동향과 소재부품장비 출하지수 데이터를 수집하여 저장합니다."""
    fetch_semicon_display()
    fetch_mpe_shipments()


if __name__ == "__main__":
    main()
