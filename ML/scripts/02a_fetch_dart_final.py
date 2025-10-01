# -*- coding: utf-8 -*-
"""
02a_fetch_dart_final.py  (stable on older OpenDartReader)
v3 변경점
- 2013~2025 전체 분기(Q1~Q4) 자동 루프
- 원시 DART API 우선 사용 + OpenDartReader 폴백(구버전 호환, fs_div 인자 미사용)
- 계정명 유연 매칭(공백·붙여쓰기 차이 허용)
- 누적(연누적/반기/9개월/연간) -> 분기값 변환
- 출력: data/external/dart_quarter_single_accounts.csv  (단위: 원)

필요 .env:
OPENDART_API_KEY=여기에키
# (선택) 삼성전자 corp_code 고정: OPENDART_CORP_CODE=00126380
"""

from __future__ import annotations
import os, re, io, zipfile, time, requests
from pathlib import Path
import pandas as pd
from dotenv import load_dotenv, dotenv_values

# --------------------------- 
# 경로/환경
# --------------------------- 
HERE = Path(__file__).resolve().parent
BASE = HERE.parent
EXT  = BASE / "data" / "external"
EXT.mkdir(parents=True, exist_ok=True)

ENV_PATH = BASE / ".env"
load_dotenv(ENV_PATH)
_cfg = dotenv_values(ENV_PATH)

def _clean(v: str|None) -> str|None:
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

def env_get(*names, required=False):
    for n in names:
        v = os.getenv(n) or _cfg.get(n)
        v = _clean(v)
        if v: return v
    if required:
        raise RuntimeError(f"Missing env: one of {names} in {ENV_PATH}")
    return None

API_KEY = env_get("OPENDART_API_KEY", "DART_API_KEY", required=True)
OVERRIDE_CORP_CODE = env_get("OPENDART_CORP_CODE")  # optional

# --------------------------- 
# 파라미터
# --------------------------- 
def build_periods(y0=2013, y1=2025):
    return [f"{y}Q{q}" for y in range(y0, y1+1) for q in (1,2,3,4)]

# 데이터를 수집할 전체 기간 목록
TARGET_PERIODS = build_periods(2013, 2025)

REPRT_FOR = {"Q1":"11013", "Q2":"11012", "Q3":"11014", "Q4":"11011"}
API_URL   = "https://opendart.fss.or.kr/api/fnlttSinglAcntAll.json"

# 표준 계정 (복수 표기를 하나로 매핑)
ACCT_MAP = {
    # DART 재무제표는 보고서/시기에 따라 계정명이 미세하게 다를 수 있습니다.
    # (예: '매출액' vs '수익(매출액)'). 이 딕셔너리는 여러 표기법을
    # 하나의 표준 키(예: 'revenue')로 매핑하여 후속 처리 로직을 단순화합니다.
    # PL
    "revenue":    ["매출액", "수익(매출액)"],
    "op_profit":  ["영업이익"],
    # CF
    "cfo":        ["영업활동으로 인한 현금흐름", "영업활동현금흐름", "영업활동으로인한현금흐름"],
    "cfi":        ["투자활동으로 인한 현금흐름", "투자활동현금흐름", "투자활동으로인한현금흐름"],
    "cff":        ["재무활동으로 인한 현금흐름", "재무활동현금흐름", "재무활동으로인한현금흐름"],
    "cash_change":["현금및현금성자산의 순증가(감소)", "현금및현금성자산의 증감", "현금및현금성자산의 순증감"],
    "cash_begin": ["기초의 현금및현금성자산", "기초 현금및현금성자산"],
    "cash_end":   ["기말의 현금및현금성자산", "기말 현금및현금성자산"],
    # BS (참고)
    "assets_total": ["자산총계"],
    "ar":           ["매출채권"],
    "inventory":    ["재고자산"],
    "investments":  ["투자자산"],
    "cash":         ["현금및현금성자산", "현금및현금성자산등"],
}

# --------------------------- 
# 헬퍼
# --------------------------- 
def year_quarter(period: str) -> tuple[int,int]:
    """'YYYYQn' 형식의 문자열에서 연도와 분기를 튜플로 반환합니다."""
    m = re.match(r"^(\d{4})Q([1-4])$", period)
    if not m: raise ValueError(f"Invalid period: {period}")
    return int(m.group(1)), int(m.group(2))

def pick_amount(val):
    """
    DART API가 반환하는 문자열 형태의 금액을 float 숫자로 변환합니다.
    - 천단위 콤마(,)를 제거합니다.
    - 괄호로 둘러싸인 값(예: "(567)")은 음수로 처리합니다.
    - 변환할 수 없는 값은 None을 반환합니다.
    """
    if val is None: return None
    s = str(val).replace(",", "").strip()
    neg = s.startswith("(") and s.endswith(")")
    if neg: s = s[1:-1]
    try:
        x = float(s)
        return -x if neg else x
    except (ValueError, TypeError):
        return None

def normalize_accounts(items: list[dict]):
    """API 응답에서 필요한 계정만 필터링하고 표준 키와 함께 반환합니다."""
    # DART API 응답(items)에서 ACCT_MAP에 정의된 계정들만 필터링
    out = []
    for it in items:
        nm = (it.get("account_nm") or "").strip()
        # 공백 유무 차이를 무시하기 위해 공백 제거 후 비교
        nm_comp = re.sub(r"\s+", "", nm)
        for key, names in ACCT_MAP.items():
            if any(re.sub(r"\s+", "", n) in nm_comp for n in names):
                out.append((key, it))
                break
    return out

def accumulate_to_quarter(df_acc: pd.DataFrame) -> pd.DataFrame:
    """
    DART의 누적 실적 데이터를 분기별 실적으로 변환합니다.
    - Q1: 그대로 사용
    - Q2: H1(반기) 누적 - Q1
    - Q3: 9M(3분기) 누적 - H1(반기) 누적
    - Q4: FY(연간) 누적 - 9M(3분기) 누적
    """
    if df_acc.empty:
        return df_acc
    piv = df_acc.pivot_table(index="account", columns="period", values="value", aggfunc="first")
    out = pd.DataFrame(index=piv.index)

    def col(c):
        return piv[c] if c in piv.columns else pd.Series(index=piv.index, dtype="float64")

    yrs = sorted({int(p[:4]) for p in piv.columns if re.match(r"^\d{4}Q[1-4]$", p)})
    for y in yrs:
        q1, q2, q3, q4 = f"{y}Q1", f"{y}Q2", f"{y}Q3", f"{y}Q4"
        if q1 in piv: out[q1] = col(q1)
        if q2 in piv: out[q2] = col(q2) - out.get(q1, 0)
        if q3 in piv: out[q3] = col(q3) - (out.get(q1, 0) + out.get(q2, 0))
        if q4 in piv:
            s = out.get(q1,0) + out.get(q2,0) + out.get(q3,0)
            out[q4] = col(q4) - s

    out = out.reset_index().melt(id_vars="account", var_name="period", value_name="value")
    out = out.dropna(subset=["value"])
    return out

# --------------------------- 
# corp_code 해석 (삼성전자)
# --------------------------- 
def resolve_corp_code() -> str|None:
    """'삼성전자'의 DART 법인 고유번호(corp_code)를 안정적으로 찾습니다."""
    # 1. .env 파일에 명시적으로 지정된 값을 최우선으로 사용합니다.
    if OVERRIDE_CORP_CODE:
        return OVERRIDE_CORP_CODE
    
    # 2. `OpenDartReader` 라이브러리를 통해 조회합니다.
    try:
        from OpenDartReader import OpenDartReader
        odr = OpenDartReader(API_KEY)
        code = odr.find_corp_code("삼성전자")
        if code:
            return code
    except Exception:
        pass

    # 3. DART 전체 법인 목록을 직접 다운로드하여 파싱합니다 (Fallback).
    try:
        url = "https://opendart.fss.or.kr/api/corpCode.xml"
        r = requests.get(url, params={"crtfc_key": API_KEY}, timeout=30)
        r.raise_for_status()
        zf = zipfile.ZipFile(io.BytesIO(r.content))
        with zf.open("CORPCODE.xml") as f:
            xml = f.read().decode("utf-8", errors="ignore")
        for code, name in re.findall(
            r"<list>\s*<corp_code>(.*?)</corp_code>\s*<corp_name>(.*?)</corp_name>.*?</list>",
            xml, flags=re.S):
            if name.strip() == "삼성전자":
                return code.strip()
    except Exception:
        pass
    return None

# --------------------------- 
# DART 원시 API 호출
# --------------------------- 
def call_dart(corp_code: str, year: int, reprt_code: str, fs_div="CFS", retry=2, sleep=0.4):
    """DART API를 호출하고, 실패 시 재시도합니다."""
    params = {
        "crtfc_key": API_KEY,
        "corp_code": corp_code,
        "bsns_year": str(year),
        "reprt_code": reprt_code,
        "fs_div": fs_div,
    }
    for i in range(retry+1):
        try:
            r = requests.get(API_URL, params=params, timeout=30)
            r.raise_for_status()
            js = r.json()
            return js
        except Exception as e:
            if i == retry:
                print(f"[ERR] call_dart fail y={year}, reprt={reprt_code}: {e}")
                return None
            time.sleep(sleep + 0.2*i)

def fetch_accounts_via_api(corp_code: str, period: str) -> list[dict]:
    """DART 원시 API를 통해 특정 기간의 재무제표 데이터를 가져옵니다."""
    y, q = year_quarter(period)
    js = call_dart(corp_code, y, REPRT_FOR[f"Q{q}"], fs_div="CFS")
    if not js or js.get("status") != "000":
        msg = js.get("message") if js else "no response"
        print(f"[WARN] API fail {period}: {msg}")
        return []
    return js.get("list") or []

# --------------------------- 
# OpenDartReader 폴백 (구버전 호환: fs_div 인자 사용 안 함)
# --------------------------- 
def fetch_accounts_via_odr(period: str) -> list[dict]:
    """
    원시 API 호출 실패 시 `OpenDartReader` 라이브러리를 통해 데이터를 가져오는 Fallback 함수입니다.
    """
    try:
        from OpenDartReader import OpenDartReader
        odr = OpenDartReader(API_KEY)
        y, q = year_quarter(period)
        df = odr.finstate("삼성전자", y, reprt_code=REPRT_FOR[f"Q{q}"])
        if df is None or len(df) == 0:
            print(f"[WARN] ODR empty {period}")
            return []
        # DataFrame을 원시 API와 동일한 list[dict] 형식으로 변환
        out = []
        for _, row in df.iterrows():
            out.append({
                "account_nm": row.get("account_nm"),
                "thstrm_amount": row.get("thstrm_amount"),
            })
        return out
    except Exception as e:
        print(f"[WARN] ODR error {period}: {e}")
        return []

# --------------------------- 
# 실행
# --------------------------- 
def main():
    """메인 실행 함수"""
    corp_code = resolve_corp_code()
    if not corp_code:
        raise SystemExit("[FATAL] 삼성전자 corp_code 해석 실패 (.env OPENDART_CORP_CODE=00126380 권장)")

    # 1. 모든 기간에 대해 DART에서 누적 실적 데이터 수집
    rows_acc = []
    for p in TARGET_PERIODS:
        print(f"[INFO] Fetch {p} ...")
        items = fetch_accounts_via_api(corp_code, p)
        # 원시 API 실패 시 OpenDartReader로 Fallback
        if not items:
            items = fetch_accounts_via_odr(p)
        if not items:
            print(f"[WARN] no rows for {p}")
            continue

        for key, it in normalize_accounts(items):
            amt = pick_amount(it.get("thstrm_amount"))
            if amt is None:
                continue
            rows_acc.append({"period": p, "account": key, "value": amt})

        time.sleep(0.25)  # DART API 호출 제한(rate limit) 방지

    if not rows_acc:
        print("[WARN] no data fetched")
        return

    df_acc = pd.DataFrame(rows_acc)

    # 2. 수집된 데이터를 분기별 실적으로 변환
    # 손익계산서(PL), 현금흐름표(CF) 항목은 '흐름(flow)' 데이터이므로 누적값을 분기값으로 변환
    flow_keys = ["revenue","op_profit","cfo","cfi","cff"]
    df_flow_q = accumulate_to_quarter(df_acc[df_acc["account"].isin(flow_keys)].copy())

    # 재무상태표(BS) 항목은 특정 시점의 '잔액(stock)' 데이터이므로 변환 없이 그대로 사용
    stock_keys = ["assets_total","ar","inventory","investments","cash","cash_begin","cash_end","cash_change"]
    df_stock = df_acc[df_acc["account"].isin(stock_keys)].copy()[["period","account","value"]]

    # 3. 분기별 흐름 데이터와 잔액 데이터를 합쳐서 최종 파일로 저장
    out = pd.concat([df_flow_q, df_stock], ignore_index=True)
    out_path = EXT / "dart_quarter_single_accounts.csv"
    out.to_csv(out_path, index=False, encoding="utf-8-sig")
    print(f"Saved: {out_path} (rows={len(out)})")
    print("NOTE) 금액단위: 원. (IR 조원 단위와 합칠 때 /1e12 스케일링)")

if __name__ == "__main__":
    main()