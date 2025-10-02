# -*- coding: utf-8 -*-
"""
01_parse_ir_2020_final.py
삼성전자 2020년 IR PDF 문서에서 주요 재무 데이터를 추출합니다.

이 스크립트는 재무 보고서가 포함된 PDF 파일을 처리하여 분기별 손익계산서,
재무상태표, 현금흐름표, 사업 부문별 실적 데이터를 추출합니다.
문서에 나타나는 다양한 숫자 형식, 단위(억원/조원), 테이블 구조 등
일관성 없는 서식들을 처리하는 기능이 포함되어 있습니다.

주요 기능:
- v14의 안정적인 메트릭 매핑과 v16의 정확한 숫자 처리(Decimal) 방식을 통합하고, 2019년 데이터를 포함합니다.
- 정규식 오류(예: 불균형 괄호)를 해결하고 값 추출 정규식(VAL_RE)을 개선합니다.
- 단위(억원/조원)를 감지하고 Decimal을 사용하여 일관된 스케일링 및 반올림(소수점 4자리)을 유지합니다.
- 재무상태표(자산/부채/자본)의 영문 메트릭 이름을 유지하고 누락된 데이터 문제를 해결합니다.
- 안정성을 위해 현금흐름 데이터의 텍스트 기반 파싱을 개선하고, 2019년 데이터를 포함합니다.
- 세그먼트 데이터의 텍스트 기반 파싱을 우선적으로 사용하며, 매출과 영업이익 섹션을 명확히 구분하고,
  Decimal을 사용하여 2019년 데이터를 처리합니다.
- 세그먼트 파싱 중 텍스트에서 분기 헤더를 추출하여 누락된 2019년 데이터 문제를 해결합니다.
- 테이블에 2019년 분기/연말 열이 있는 경우 이를 매핑하고 저장합니다.
- 데이터 출처를 나타내는 'source' 열을 추가합니다(예: "2020_1Q_conference_kor.pdf#p05").

출력 (data/raw 폴더):
- ir_quarter_2020.csv: 분기별 손익계산서 데이터 (period, metric, value, category, unit, source).
- ir_balance_2020.csv: 재무상태표 데이터 (period, metric, value, category, unit, source).
- ir_cashflow_2020.csv: 현금흐름표 데이터 (period, metric, value, category, unit, source).
- ir_segments_2020.csv: 부문별 실적 데이터 (period, segment_code, segment_name_en, lineage_group, metric, value, scope, unit, source).
"""
from __future__ import annotations
import re
from pathlib import Path
import pdfplumber
import pandas as pd
import numpy as np
from decimal import Decimal, ROUND_HALF_UP, InvalidOperation

# ---------------- 경로 설정 ----------------
YEAR = 2020
HERE = Path(__file__).resolve()
BASE = HERE.parents[1]                 # .../GMP_ML
RAW  = BASE / "data" / "raw"
OUTS = {
    "quarter":  RAW / f"ir_quarter_{YEAR}.csv",
    "balance":  RAW / f"ir_balance_{YEAR}.csv",
    "cashflow": RAW / f"ir_cashflow_{YEAR}.csv",
    "segments": RAW / f"ir_segments_{YEAR}.csv",
}
DEBUG = RAW / "debug"
DEBUG.mkdir(parents=True, exist_ok=True)
PDFS = sorted(RAW.glob(f"{YEAR}_*Q_conference_kor.pdf"))

# ---------------- 디버깅 도우미 (평탄화된 .txt 전용) ----------------
def dbg_write(name: str, text: str):
    """디버깅 목적으로 텍스트를 파일에 씁니다."""
    try:
        (DEBUG / f"{name}.txt").write_text(text or "", encoding="utf-8")
    except Exception:
        pass

# ---------------- 정규식/포맷 유틸리티 ----------------
def clean_text(x):
    """입력된 텍스트에서 개행문자를 공백으로 변환하고 양쪽 공백을 제거합니다."""
    return x.replace("\n", " ").strip() if isinstance(x, str) else x

def normalize_quarter_raw(s: str) -> str:
    """분기 문자열을 정규화합니다. (예: 여러 공백을 하나로, ’를 '로)"""
    if not isinstance(s, str): return ""
    return re.sub(r"\s+", " ", s.replace("’", "'")).strip()

def parse_period_from_raw(raw: str|None) -> str|None:
    """다양한 형식의 원시 기간 문자열을 'YYYYQX' 또는 'YYYYFY' 형식으로 파싱합니다."""
    s = str(raw or "")
    s2 = re.sub(r"\s+", "", s)
    m = re.search(r"([1-4])Q[’']?(\d{2})", s2)             # 예: 1Q '20
    if m: return f"20{m.group(2)}Q{m.group(1)}"
    m = re.search(r"[’'](\d{2})년([1-4])분기(?:말)?", s2)    # 예: '20년1분기(말)
    if m: return f"20{m.group(1)}Q{m.group(2)}"
    m = re.search(r"[’'](\d{2})년말", s2)                   # 예: '19년말 -> Q4
    if m: return f"20{m.group(1)}Q4"
    m = re.search(r"[’']?(\d{2})년", s2)                   # 예: '21년 -> 2021FY
    if m: return f"20{m.group(1)}FY"
    return None

# ---------------- 헤더 처리 도우미 ----------------
def _dedup_columns(cols):
    """컬럼 목록에 중복된 이름이 있을 경우, '.1', '.2' 등을 붙여 고유하게 만듭니다."""
    seen = {}
    out = []
    for c in cols:
        c2 = clean_text(c) if c is not None else ""
        if not c2:
            c2 = f"unnamed_{len(out)}"
        if c2 in seen:
            seen[c2] += 1
            out.append(f"{c2}.{seen[c2]}")
        else:
            seen[c2] = 0
            out.append(c2)
    return out

def _ensure_account_series(df: pd.DataFrame):
    """'account' 컬럼이 DataFrame(중복 열) 형태일 경우, 첫 번째 열만 사용하도록 보장합니다."""
    if isinstance(df.get("account"), pd.DataFrame):
        df["account"] = df["account"].iloc[:, 0]
    return df

# ---------------- 단위 감지 ----------------
UNIT_PATTERNS = [
    (re.compile(r"단위\s*[:：]?\s*조\s*원", re.I), ("조원", Decimal("1"))),
    (re.compile(r"단위\s*[:：]?\s*억\s*원", re.I), ("조원", Decimal("0.0001"))),
]

def detect_unit_scale(text: str) -> tuple[str, Decimal]:
    """텍스트에서 '조원' 또는 '억원' 단위를 감지하고, '조원' 기준으로 스케일링 값을 반환합니다."""
    t = re.sub(r"\s+", "", text or "")
    for pat, res in UNIT_PATTERNS:
        if pat.search(t):
            return res
    # 단위가 명시되지 않은 경우, 보수적으로 '억원'으로 간주하여 '조원'으로 환산합니다.
    return ("조원", Decimal("0.0001"))

# ---------------- 앵커 (기준점) ----------------
# 각 재무제표 테이블을 찾기 위한 기준점(앵커) 텍스트 패턴 목록입니다.
ANCHORS = {
    "quarter":  [r"전사\s*손익\s*분석", r"손익계산서", r"연결\s*손익계산서"],
    "balance":  [r"[\s*별첨\s*1\s*]?\s*요약\s*재무상태", r"재무상태표", r"연결\s*재무상태표"],
    "cashflow": [r"[\s*별첨\s*2\s*]?\s*요약\s*현금흐름", r"현금흐름표", r"연결\s*현금흐름표"],
    "segments": [
        r"사업군별\s*매출\s*및\s*영업이익",
        r"부문별\s*실적",
        r"사업부문별\s*실적",
        r"사업부문별\s*매출\s*및\s*영업이익",
        r"사업부문\s*실적",
        r"사업부문\s*매출",
        r"세그먼트",
    ],
}

# ---------------- 보고서 기반 세그먼트 번역 ----------------
SEG_KO_PATTERNS = [
    (r"^\s*ce\s*부문\s*.*$", "CE", "Consumer Electronics", "Consumer&Mobile"),
    (r"^\s*im\s*부문\s*.*$", "IM", "IT & Mobile communications", "Consumer&Mobile"),
    (r"^\s*ds\s*부문\s*.*$", "DS", "Device Solutions", "Semiconductor"),
    (r"^\s*dp\s*부문\s*.*$", "DP", "Display Panel", "Display"),
    (r"^\s*sdc\s*.*$",      "SDC", "Samsung Display", "Display"),
    (r"^\s*harman\s*.*$",   "Harman", "Harman", "Harman"),
    (r"^\s*총(액|합|계)\s*.*$", "Total", "Total", "Total"),
    # 2022년 이후 보고서와의 호환성을 위해 추가된 패턴입니다.
    (r"^\s*dx\s*.*$", "DX", "Device eXperience", "Consumer&Mobile"),
    (r"^\s*mx\s*.*$", "MX", "Mobile eXperience", "Consumer&Mobile"),
    (r"^\s*network(s)?\s*.*$", "Network", "Network", "Consumer&Mobile"),
]
# [GM] SEG_KO_PATTERNS: 세그먼트 이름 뒤에 숫자 등 추가 텍스트가 오는 경우에도 매칭되도록 정규식 패턴을 수정했습니다.
# 이전에는 라인 전체가 정확히 일치해야 해서 파싱 오류가 발생할 수 있었습니다.

def translate_segment_as_reported(s: str):
    """보고서에 기재된 한글 세그먼트 이름을 표준 코드, 영문명, 상위 그룹으로 변환합니다."""
    raw = (s or "").strip()
    base = raw.lower().replace(" ", "")
    for pat, code, name_en, lineage in SEG_KO_PATTERNS:
        if re.match(pat, raw, flags=re.IGNORECASE) or re.match(pat, base, flags=re.IGNORECASE):
            return code, name_en, lineage
    return None, None, None

# ---------------- 도우미 함수 ----------------
VAL_RE = re.compile(r"(?:△|\()?-?[\d,.]+\)?")  # 예: (1,234), -1,234, 1234, 12.34, △123
# [GM] VAL_RE: 소수점(.), 음수 기호(△), 괄호로 둘러싸인 음수 등을 포함한 숫자 값을 정확히 파싱하도록 수정했습니다.
# 이전 버전은 소수점을 잘못 분리하여 값을 잘못 추출하는 경우가 있었습니다.

CF_LABEL_PATTERNS = [
    (re.compile(r"영업\s*활동.*현금\s*흐름", re.I), "영업활동으로 인한 현금흐름"),
    (re.compile(r"투자\s*활동.*현금\s*흐름", re.I), "투자활동으로 인한 현금흐름"),
    (re.compile(r"재무\s*활동.*현금\s*흐름", re.I), "재무활동으로 인한 현금흐름"),
    (re.compile(r"기초\s*현금", re.I),           "기초현금 ※"),
    (re.compile(r"기말\s*현금", re.I),           "기말현금 ※"),
    (re.compile(r"현금\s*증감", re.I),           "현금증감"),
]

# 각 재무제표 항목의 한글 이름을 표준 영문 메트릭으로 매핑합니다.
QUARTER_METRIC_MAP = {
    '매출액': 'revenue',
    '영업이익': 'op_profit',
    '법인세차감전이익': 'income_before_tax',
    '순이익': 'net_profit',
    '지배기업 소유주지분 순이익': 'net_profit_controlling',
}

BALANCE_METRIC_MAP = { # v14의 매핑을 사용하여 더 엄격하게 제어합니다.
    "자산": "assets", "자산총계": "assets", "자산계": "assets", "자산합계": "assets",
    "부채": "liabilities", "부채총계": "liabilities",
    "자본": "equity", "자본총계": "equity",
}

CF_METRIC_MAP = {
    "영업활동으로 인한 현금흐름": "cfo",
    "투자활동으로 인한 현금흐름": "cfi",
    "재무활동으로 인한 현금흐름": "cff",
    "기초현금 ※": "cash_begin",
    "기말현금 ※": "cash_end",
    "현금증감": "cash_change",
}

SEGMENT_METRIC_MAP = {
    'Revenue': 'revenue',
    'Operating Profit': 'op_profit',
}

# Decimal 도우미
FOUR_DP = Decimal('0.0001') # 소수점 4자리까지 정확도를 유지하기 위한 설정입니다.

def _to_decimal(s: str) -> Decimal | None:
    """문자열을 Decimal 객체로 변환합니다. 쉼표, '△', 괄호 음수 표현을 처리합니다."""
    if s is None: return None
    t = str(s).strip().replace(",", "").replace("△", "-")
    if t.startswith("(") and t.endswith(")"): t = "-" + t[1:-1]
    try:
        return Decimal(t)
    except (InvalidOperation, ValueError, TypeError):
        return None

def _round4(x: Decimal | float | int) -> float:
    """숫자 값을 소수점 4자리까지 반올림합니다."""
    try:
        d = Decimal(str(x))
        return float(d.quantize(FOUR_DP, rounding=ROUND_HALF_UP))
    except Exception:
        try:
            return float(round(float(x), 4))
        except Exception:
            return np.nan

def _match_cf_label(text: str) -> str | None:
    """현금흐름표의 다양한 레이블 표현을 표준화된 하나의 형태로 찾습니다."""
    base = (text or "").replace("\n", " ")
    for pat, canon in CF_LABEL_PATTERNS:
        if pat.search(base): return canon
    return None

def _find_quarter_headers_in_text(text: str) -> list[str]:
    """텍스트에서 "1Q '20", "'20년 1분기" 등 다양한 형식의 분기 헤더를 찾아 리스트로 반환합니다."""
    t = re.sub(r"\s+", " ", text or "")
    qs = []
    qs += [f"{m.group(1)}Q '{m.group(2)}" for m in re.finditer(r"([1-4])Q\s*[’'](\d{2})", t)]
    qs += [f"{m.group(2)}Q '{m.group(1)}" for m in re.finditer(r"[’'](\d{2})년\s*([1-4])분기", t)]
    qs += [f"4Q '{m.group(1)}"            for m in re.finditer(r"[’'](\d{2})년말", t)]
    seen=set(); out=[]
    for q in qs:
        if q not in seen: # 중복된 헤더는 추가하지 않습니다.
            out.append(q); seen.add(q)
    return out # 찾은 모든 고유 헤더를 반환합니다.

# ---------------- 테이블 탐색 ----------------

def find_page_and_tables_any(pdf, patterns: list[str], q: str, kind: str):
    """
    PDF 내에서 특정 테이블을 포함하는 페이지와 테이블을 찾습니다.
    먼저 앵커 패턴으로 페이지를 찾고, 실패 시 '구분' 헤더가 있는 테이블을 찾는 폴백 로직을 사용합니다.
    """
    for idx, page in enumerate(pdf.pages):
        text = page.extract_text() or ""
        dbg_write(f"{YEAR}_Q{q}_p{idx:02d}_text", text)
        text_norm = re.sub(r"\s+", " ", text)
        if any(re.search(p, text_norm, flags=re.IGNORECASE) for p in patterns):
            tables = page.extract_tables() or []
            if tables:
                dbg_write(f"{YEAR}_Q{q}_anchor_{kind}", f"page={idx} tables={len(tables)}")
                return idx, page, tables
            else: # 앵커는 찾았지만 테이블이 없는 경우, 같은 페이지에서 테이블을 다시 찾으려 시도합니다.
                dbg_write(f"{YEAR}_Q{q}_anchor_no_table_{kind}", f"page={idx}")
                return idx, page, [] # 페이지는 반환하되, 테이블은 비어있는 상태로 반환합니다.
    # 폴백 로직: 전체 페이지에서 '구분'을 포함하는 첫 번째 테이블을 찾습니다.
    for idx, page in enumerate(pdf.pages):
        tables = page.extract_tables() or []
        for t in tables:
            if t and t[0]:
                hdr = " ".join([str(clean_text(h)) for h in t[0]])
                if "구분" in hdr:
                    dbg_write(f"{YEAR}_Q{q}_fallback_{kind}", f"page={idx}")
                    return idx, page, [t]
    dbg_write(f"{YEAR}_Q{q}_no_{kind}", "no anchor/fallback match")
    return None, None, []

# ---------------- 파서 ----------------

def parse_income_statement_text(page_text: str, source: str):
    """
    분기별 손익계산서 텍스트 파서 (테이블 파싱 실패 시 폴백).
    페이지 텍스트에서 직접 여러 분기 데이터를 동시에 처리합니다.
    """
    if not page_text: return pd.DataFrame()
    lines = [ln for ln in page_text.split("\n") if ln.strip()]
    header_line = next((ln for ln in lines if ("(단위:" in ln and ("Q '" in ln or "Q ’" in ln))), "")
    if not header_line: return pd.DataFrame()

    header_quarters = _find_quarter_headers_in_text(header_line) # 견고한 헤더 찾기 함수 사용
    if not header_quarters: return pd.DataFrame()
    header_periods = [parse_period_from_raw(normalize_quarter_raw(q)) for q in header_quarters]
    header_periods = [p for p in header_periods if p is not None] # None 기간 필터링

    results = []
    for line in lines:
        for ko_name, en_name in QUARTER_METRIC_MAP.items():
            if line.strip().startswith(ko_name):
                nums = [m.group(0) for m in VAL_RE.finditer(line)]
                for i, v in enumerate(nums[:len(header_periods)]):
                    val = _to_decimal(v)
                    if val is None: continue
                    results.append({"period": header_periods[i], "metric": en_name, "value_dec": val, "source": source})
                break
    if not results: return pd.DataFrame()

    unit_label, scale = detect_unit_scale(page_text)
    out = pd.DataFrame(results)
    out["value"] = out["value_dec"].apply(lambda d: _round4(d * scale))
    out["category"] = "quarter"
    out["unit"] = unit_label
    return out[["period","metric","value","category","unit","source"]].dropna(subset=["period"]).reset_index(drop=True)

def map_balance_metric(s: str) -> str | None: # v14의 로직을 사용하여 재무상태표 메트릭을 매핑합니다.
    """'자산총계', '자산계' 등을 '자산'으로 정규화하여 표준 메트릭을 찾습니다."""
    key = re.sub(r"\s+", "", str(s or ""))
    key = key.replace("총계", "").replace("계", "")
    return BALANCE_METRIC_MAP.get(key, None) # 매핑되지 않으면 None을 반환합니다.

def parse_financial_statement_tables(tables, label, page_text: str, source: str|None=None):
    """
    범용 재무제표 테이블 파서 (손익계산서, 재무상태표, 현금흐름표용).
    'label' 인자에 따라 적절한 메트릭 맵을 적용하고 단위를 스케일링합니다.
    """
    if not tables or not tables[0]: return pd.DataFrame()
    df = pd.DataFrame(tables[0])
    if df.empty: return pd.DataFrame()

    hdr_idx = pick_header_row(df)
    if hdr_idx is None or hdr_idx >= len(df): return pd.DataFrame()

    headers = [clean_text(h) if h is not None else f"unnamed_{i}" for i, h in enumerate(df.iloc[hdr_idx])]
    df.columns = _dedup_columns(headers)
    df = df.iloc[hdr_idx + 1:].reset_index(drop=True)

    acct_col = next((col for col in df.columns if isinstance(col, str) and re.search(r"구\s*분", col)), df.columns[0])
    df = df.rename(columns={acct_col: "account"}).copy()
    df = _ensure_account_series(df)
    df["account"] = df["account"].astype(str).str.strip()
    df = df[df["account"].ne("")]

    id_vars = ["account"]
    value_vars = [c for c in df.columns if c not in id_vars]
    out = pd.melt(df, id_vars=id_vars, value_vars=value_vars, var_name="quarter_raw", value_name="value")

    out["quarter_raw"] = out["quarter_raw"].astype(str).map(normalize_quarter_raw)
    out["period"] = out["quarter_raw"].apply(parse_period_from_raw)

    out["value_str"] = out["value"].astype(str).str.extract(r"(\(?-?[\d,]+\)?)" if VAL_RE.pattern.startswith(r"\(") else r"(-?[\d,]+\.?\d*)")[0] # 추출 정규식 조정
    out["value_dec"] = out["value_str"].apply(_to_decimal)
    out = out.dropna(subset=["value_dec","period"]).copy()

    # 메트릭 매핑 적용
    if label == "B/S": # 재무상태표 특별 처리
        out["metric"] = out["account"].apply(map_balance_metric)
        out = out.dropna(subset=["metric"]) # 매핑 실패 행 제거
    elif label == "P/L":
        out["metric"] = out["account"].map(QUARTER_METRIC_MAP).fillna(out["account"])
        out = out[out["metric"].isin(QUARTER_METRIC_MAP.values())] # 매핑된 메트릭만 유지
    elif label == "C/F":
        out["metric"] = out["account"].apply(lambda s: CF_METRIC_MAP.get(_match_cf_label(str(s)) or "", None))
        out = out.dropna(subset=["metric"]) # 매핑 실패 행 제거
    else:
        out["metric"] = out["account"] # 특정 매핑이 없으면 계정 이름 그대로 사용

    unit_label, scale = detect_unit_scale(page_text)
    out["value"] = out["value_dec"].apply(lambda d: _round4(d * scale))
    if label == "B/S":
        out["category"] = "balance"
    else:
        out["category"] = label.lower().replace("/", "_")
    out["unit"] = unit_label
    if source:
        out["source"] = source
    else:
        out["source"] = ""
    return out[["period", "category", "metric", "value", "unit", "source"]].sort_values(["period","metric"]).reset_index(drop=True)


def parse_net_cash_panel(txt: str, periods: list[str], fname: str, page_no: int | None = None) -> list[dict]:
    """
    '순현금' 패널에서 'net_cash' 행을 생성합니다. 자체적으로 단위를 스케일링합니다.
    - '순현금', '순 현금', '순현금 현황', 'Net cash' 등 다양한 표현에 대응합니다.
    - `periods` 길이에 맞춰 숫자를 매핑합니다.
    - 괄호/△ 음수 표현은 `_to_decimal` 함수에 위임합니다.
    - '%' 값은 무시합니다.
    """
    rows: list[dict] = []
    if not txt or not periods:
        return rows
    # 단위 스케일(억원/조원) 추출
    unit_label, scale = detect_unit_scale(txt)

    whole = txt.replace(" ", "")
    if ("순현금" not in whole) and ("netcash" not in txt.lower().replace(" ", "")):
        return rows

    for raw in txt.splitlines():
        line = raw.strip()
        if not line:
            continue
        s = line.replace(" ", "").lower()
        if ("순현금" not in s) and ("netcash" not in s):
            continue
        nums = [m.group(0) for m in VAL_RE.finditer(line)]
        nums = [t for t in nums if "%" not in t]
        if len(nums) < len(periods):
            continue
        vals = []
        for x in nums[-len(periods):]:
            d = _to_decimal(x)
            if d is None:
                vals.append(None)
            else:
                vals.append(_round4(d * scale))
        for per, v in zip(periods, vals):
            if v is None:
                continue
            rows.append({
                "period": per,
                "metric": "net_cash",
                "value": v,
                "category": "cashflow",
                "unit": unit_label,
                "source": fname,
                "page": (page_no + 1) if isinstance(page_no, int) else None
            })
        break
    return rows
def parse_cashflow_statement_text(page_text: str, source: str):
    """현금흐름표 텍스트 기반 파서 (v14 기반 개선)"""
    rows = []

    # 2020년 4분기 현금흐름표는 헤더 형식이 다름: '20년 4분기, '20년, '19년
    if "2020_4Q" in source:
        headers = ["2020Q4", "2020FY", "2019FY"]
        # 하드코딩된 헤더는 이미 올바른 형식이므로 추가 파싱이 필요 없습니다.
        periods = headers
    else:
        headers = _find_quarter_headers_in_text(page_text)
        periods = [parse_period_from_raw(normalize_quarter_raw(h)) for h in headers]

    ncol = len(periods)
    if ncol == 0: return pd.DataFrame()

    unit_label, scale = detect_unit_scale(page_text)

    for ln in [ln.strip() for ln in (page_text or "").splitlines() if ln.strip()]:
        canon = _match_cf_label(ln)
        if not canon: continue
        nums = [m.group(0) for m in VAL_RE.finditer(ln)]
        
        if ncol and len(nums) >= ncol:
            nums = nums[-ncol:] # 마지막 ncol개의 숫자만 사용합니다.
            for per, v in zip(periods, nums):
                if per is None: continue
                val = _to_decimal(v)
                if val is None: continue
                rows.append({
                    "period": per,
                    "metric": CF_METRIC_MAP.get(canon, None),
                    "value_dec": val,
                    "category": "cashflow",
                    "unit": unit_label,
                    "source": source
                })
        elif len(nums) == 1:
             val = _to_decimal(nums[0])
             if val is None: continue
             rows.append({
                    "period": periods[0] if periods else None,
                    "metric": CF_METRIC_MAP.get(canon, None),
                    "value_dec": val,
                    "category": "cashflow",
                    "unit": unit_label,
                    "source": source
                })

    if not rows: return pd.DataFrame()
    out = pd.DataFrame(rows)
    out = out.dropna(subset=["period", "metric"])
    out["value"] = out["value_dec"].apply(lambda d: _round4(d * scale))
    return out[["period","metric","value","category","unit","source"]].sort_values(["period","metric"]).reset_index(drop=True)


def parse_segments_v1_style(tables, page_text: str, source: str): # 세그먼트 데이터 테이블 기반 파서 (폴백)
    """세그먼트 데이터 테이블 기반 파서 (텍스트 파싱 실패 시 사용되는 폴백)"""
    if not tables: return pd.DataFrame()
    all_dfs = []
    categories = ['Revenue', 'Operating Profit']

    # 견고성을 위해 텍스트 기반 헤더 추출을 사용합니다.
    header_quarters = _find_quarter_headers_in_text(page_text)
    if not header_quarters: return pd.DataFrame() # 텍스트에서 헤더를 찾지 못하면 파싱할 수 없습니다.
    header_periods = [parse_period_from_raw(normalize_quarter_raw(q)) for q in header_quarters]
    header_periods = [p for p in header_periods if p is not None] # None 기간 필터링
    if not header_periods: return pd.DataFrame()

    for i, table in enumerate(tables[:2]): # 첫 두 테이블이 각각 매출, 영업이익이라고 가정합니다.
        df = pd.DataFrame(table)
        hdr_idx = pick_header_row(df)
        if hdr_idx is None: continue
        
        # 값 컬럼 수가 header_periods와 일치한다고 가정하고, melt를 위해 일반 컬럼 이름을 생성합니다.
        num_value_cols = len(header_periods)
        # 테이블에서 실제로 값이 포함된 컬럼 수를 찾습니다.
        # (계정 컬럼 뒤의 비어있지 않은 컬럼 수를 세는 휴리스틱)
        if len(df.columns) > 1: # 계정 컬럼과 최소 하나의 값 컬럼이 있는지 확인합니다.
            # 값 컬럼일 가능성이 있는 첫 번째 컬럼을 찾습니다.
            first_value_col_idx = -1
            for col_idx in range(len(df.columns)):
                # 처음 몇 행에 숫자가 포함되어 있는지 확인하는 휴리스틱
                if any(re.match(VAL_RE.pattern, str(clean_text(df.iloc[row_idx, col_idx]))) for row_idx in range(min(len(df), 5))):
                    first_value_col_idx = col_idx
                    break
            
            if first_value_col_idx != -1:
                # 계정 컬럼이 값 컬럼보다 앞에 있다고 가정합니다.
                acct_col_name = next((c for c in df.columns if isinstance(c, str) and re.search(r"구\s*분", c)), df.columns[0])
                # 실제 값 컬럼을 header_periods에 매핑합니다.
                # 테이블의 값 컬럼 수가 header_periods 수와 일치해야 합니다.
                table_value_cols = df.columns[first_value_col_idx : first_value_col_idx + num_value_cols]
                if len(table_value_cols) == num_value_cols:
                    # melt를 위해 이 컬럼들의 이름을 header_periods로 변경합니다.
                    rename_map = {table_value_cols[j]: header_periods[j] for j in range(num_value_cols)}
                    df = df.rename(columns=rename_map)
                    value_vars = list(header_periods) # 실제 기간을 value_vars로 사용합니다.
                else:
                    # 컬럼 수가 일치하지 않으면 일반 컬럼 이름을 사용하는 폴백 로직
                    value_vars = [f"value_col_{j}" for j in range(num_value_cols)]
                    # 테이블 컬럼이 header_periods보다 많으면 마지막 컬럼들을 사용합니다.
                    if len(df.columns) - (first_value_col_idx) >= num_value_cols:
                        df.columns = list(df.columns[:first_value_col_idx]) + value_vars + list(df.columns[first_value_col_idx + num_value_cols:])
                    else:
                        # 컬럼 수가 적으면 테이블이 잘못되었거나 원하는 테이블이 아닐 수 있습니다。
                        continue # 이 테이블은 건너뜁니다.
            else:
                continue # 값 컬럼을 찾지 못하면 테이블을 건너뜁니다.
        else:
            continue # 컬럼이 충분하지 않으면 테이블을 건너뜁니다.

        acct_col = next((c for c in df.columns if isinstance(c, str) and re.search(r"구\s*분", c)), df.columns[0])
        df = df.rename(columns={acct_col: "account"}).copy()
        df = _ensure_account_series(df)
        df["account"] = df["account"].astype(str).str.strip()
        df = df[df["account"].notna() & (df["account"] != '')]

        id_vars = ["account"]
        # value_vars는 위에서 이미 결정되었습니다.
        df_long = pd.melt(df, id_vars=id_vars, value_vars=value_vars, var_name="period", value_name="value")
        df_long['category'] = categories[i]
        all_dfs.append(df_long)

    if not all_dfs: return pd.DataFrame()    
    df_long = pd.concat(all_dfs, ignore_index=True)
    df_long["value_str"] = df_long["value"].astype(str).str.extract(r"(\(?-?[\d,]+\)?)" if VAL_RE.pattern.startswith(r"\(") else r"(-?[\d,]+\.?\d*)")[0]
    df_long["value_dec"] = df_long["value_str"].apply(_to_decimal)
    df_long = df_long.dropna(subset=["value_dec"])

    # period는 이미 value_vars에서 올바르게 설정되었습니다.
    # df_long['period'] = df_long['quarter_raw'].apply(parse_period_from_raw)
    # df_long = df_long.dropna(subset=['period'])

    tr = df_long["account"].apply(translate_segment_as_reported)
    df_long["segment_code"]    = tr.map(lambda x: x[0])
    df_long["segment_name_en"] = tr.map(lambda x: x[1])
    df_long["lineage_group"]   = tr.map(lambda x: x[2])
    df_long = df_long.dropna(subset=['segment_code']) # 매핑되지 않은 세그먼트 제거

    df_long['metric'] = df_long['category'].replace(SEGMENT_METRIC_MAP)

    unit_label, scale = detect_unit_scale(page_text)
    df_long["value"] = df_long["value_dec"].apply(lambda d: _round4(d * scale))
    df_long["scope"] = ""
    df_long["unit"] = unit_label
    df_long["source"] = source

    cols = ["period", "segment_code", "segment_name_en", "lineage_group", "metric", "value", "scope", "unit", "source"]
    return df_long[cols].sort_values(["period","segment_code","metric"]).reset_index(drop=True)

def parse_segments_from_text(page_text: str, source: str): # 견고한 세그먼트 텍스트 기반 파서
    """견고한 세그먼트 데이터 텍스트 기반 파서"""
    if not page_text: return pd.DataFrame()
    lines = [l.strip() for l in page_text.splitlines() if l.strip()]
    
    header_quarters = _find_quarter_headers_in_text(page_text)
    if not header_quarters: return pd.DataFrame()
    header_periods = [parse_period_from_raw(normalize_quarter_raw(q)) for q in header_quarters]
    header_periods = [p for p in header_periods if p is not None] # None 기간 필터링
    if not header_periods: return pd.DataFrame()
    ncol = len(header_periods)

    unit_label, scale = detect_unit_scale(page_text)
    rows = []
    current_metric = None

    for ln in lines:
        # '매출'과 '영업이익' 섹션을 구분하는 휴리스틱
        if "매출" in ln and "영업이익" not in ln: # '매출' 섹션 시작
            current_metric = "revenue"
            continue
        elif "영업이익" in ln and "매출" not in ln: # '영업이익' 섹션 시작
            current_metric = "op_profit"
            continue
        
        if current_metric:
            code, name_en, lineage = translate_segment_as_reported(ln)
            if not code: continue
            nums = [m.group(0) for m in VAL_RE.finditer(ln)]
            if len(nums) >= ncol:
                nums = nums[:ncol] # [GM] 추출된 숫자 중 기간 헤더 수만큼만 사용 (QoQ, YoY 등 불필요한 값 제외)
                for h_idx, v in enumerate(nums):
                    val = _to_decimal(v)
                    if val is None: continue
                    rows.append({
                        "period": header_periods[h_idx],
                        "segment_code": code,
                        "segment_name_en": name_en,
                        "lineage_group": lineage,
                        "metric": SEGMENT_METRIC_MAP.get(current_metric.capitalize(), current_metric), # 'revenue' 또는 'op_profit'으로 매핑
                        "value_dec": val,
                        "unit": unit_label,
                        "source": source,
                    })
    if not rows: return pd.DataFrame()

    out = pd.DataFrame(rows)
    out = out.dropna(subset=["period", "metric"])
    out["value"] = out["value_dec"].apply(lambda d: _round4(d * scale))
    out["scope"] = "segment"
    cols = ["period","segment_code","segment_name_en","lineage_group","metric","value","scope","unit","source"]
    out = out.dropna(subset=["period"]).loc[:, cols]
    return out.sort_values(["period","segment_code","metric"]).reset_index(drop=True)

# ---------------- 헤더 감지 ----------------
def pick_header_row(df: pd.DataFrame) -> int | None:
    """DataFrame의 상위 몇 행을 검사하여 '구분' 키워드가 포함된 헤더 행의 인덱스를 찾습니다."""
    if df is None or df.empty: return None
    top = min(8, len(df))
    for i in range(top):
        row = [clean_text(x) for x in df.iloc[i].tolist()]
        if any(isinstance(c, str) and re.search(r"구\s*분", c) for c in row):
            return i
    return 0

def _derive_cf_periods_2020(page_text: str, source_name: str) -> list[str]:
    """
    2020년 현금흐름표(CF)용 기간 헤더를 유도합니다.
    - 4분기 문서는 '20년 4분기, '20년, '19년 → 2020Q4, 2020FY, 2019FY로 변환합니다.
    - 그 외 분기는 텍스트에서 헤더를 직접 추출합니다.
    """
    if "2020_4Q" in source_name:
        return ["2020Q4", "2020FY", "2019FY"]
    headers = _find_quarter_headers_in_text(page_text or "")
    periods = [parse_period_from_raw(normalize_quarter_raw(h)) for h in headers]
    periods = [p for p in periods if p is not None]
    return periods

# ---------------- 메인 실행 ----------------

def main():
    # 처리할 PDF 파일이 있는지 확인합니다.
    if not PDFS:
        dbg_write("path_debug", f"BASE={BASE}\nRAW={RAW}\nCWD={Path.cwd()}\n(no PDFs)")
        print(f"No PDF files matched in {RAW}")
        return

    # 모든 PDF에서 추출한 데이터를 저장할 리스트를 초기화합니다.
    all_q: list[pd.DataFrame] = []
    all_b: list[pd.DataFrame] = []
    all_c: list[pd.DataFrame] = []
    all_s: list[pd.DataFrame] = []

    print(f"Found {len(PDFS)} PDF files to process in {RAW}")
    # 각 PDF 파일을 순회하며 처리합니다.
    for pdf_path in PDFS:
        m = re.search(r"(\d)Q", pdf_path.name)
        if not m: continue
        q = int(m.group(1))
        print(f"\nProcessing {YEAR} Q{q} from {pdf_path.name} ...")
        try:
            with pdfplumber.open(str(pdf_path)) as pdf:
                # --- 분기별 손익 데이터 파싱 ---
                # 분기별 데이터가 포함된 페이지를 찾아 파싱합니다.
                # 텍스트 기반 파싱을 먼저 시도하고, 실패 시 테이블 파싱으로 대체합니다.
                idx_q, page_q, t_q = find_page_and_tables_any(pdf, ANCHORS["quarter"],  str(q), "quarter")
                page_q_text = page_q.extract_text() if page_q else ""
                src_q = f"{pdf_path.name}#p{idx_q:02d}" if idx_q is not None else f"{pdf_path.name}"
                
                qdf = parse_income_statement_text(page_q_text, src_q)
                if qdf.empty and t_q: # 텍스트 파싱 실패 시 테이블 파싱 시도
                    qdf = parse_financial_statement_tables(t_q, "P/L", page_q_text, src_q)
                if not qdf.empty: all_q.append(qdf)

                # --- 재무상태표 데이터 파싱 ---
                # 재무상태표 데이터가 포함된 페이지를 찾아 범용 테이블 파서로 파싱합니다.
                idx_b, page_b, t_b = find_page_and_tables_any(pdf, ANCHORS["balance"],  str(q), "balance")
                page_b_text = page_b.extract_text() if page_b else ""
                src_b = f"{pdf_path.name}#p{idx_b:02d}" if idx_b is not None else f"{pdf_path.name}"
                bdf = parse_financial_statement_tables(t_b, "B/S", page_b_text, src_b)
                if not bdf.empty: all_b.append(bdf)

                # --- 현금흐름표 데이터 파싱 ---
                # 현금흐름표 데이터가 포함된 페이지를 찾아 파싱합니다.
                # 텍스트 기반 파싱을 우선하며, 실패 시 테이블 기반 파싱으로 대체합니다.
                idx_c, page_c, t_c = find_page_and_tables_any(pdf, ANCHORS["cashflow"], str(q), "cashflow")
                page_c_text = page_c.extract_text() if page_c else ""
                src_c = f"{pdf_path.name}#p{idx_c:02d}" if idx_c is not None else f"{pdf_path.name}"
                
                cdf = parse_cashflow_statement_text(page_c_text, src_c)
                if cdf.empty and t_c: # 텍스트 파싱 실패 시 테이블 파싱 시도
                    cdf = parse_financial_statement_tables(t_c, "C/F", page_c_text, src_c)
                if not cdf.empty: all_c.append(cdf)
                
                # --- 순현금 데이터 파싱 ---
                # 현금흐름 페이지에서 보조적인 순현금 데이터를 추출합니다.
                per_c = _derive_cf_periods_2020(page_c_text, src_c)
                try:                
                    nc_rows = parse_net_cash_panel(page_c_text, per_c, fname=src_c, page_no=idx_c if idx_c is not None else None)                
                    if nc_rows:                
                        nc_df = pd.DataFrame(nc_rows)                
                        if not nc_df.empty:            
                            all_c.append(nc_df[['period','metric','value','category','unit','source']])                
                except Exception as _:                
                    pass

                # --- 부문별 실적 데이터 파싱 ---
                # 부문별 데이터가 포함된 페이지를 찾아 파싱합니다.
                # 텍스트 기반 파싱을 우선하며, 실패 시 테이블 기반 파싱으로 대체합니다.
                idx_s, page_s, t_s = find_page_and_tables_any(pdf, ANCHORS["segments"], str(q), "segments")
                page_s_text = page_s.extract_text() if page_s else ""
                src_s = f"{pdf_path.name}#p{idx_s:02d}" if idx_s is not None else f"{pdf_path.name}"
                
                sdf = parse_segments_from_text(page_s_text, src_s) # 텍스트 파싱 우선
                if sdf.empty and t_s: # 텍스트 파싱 실패 시 테이블 파싱 시도
                    sdf = parse_segments_v1_style(t_s, page_s_text, src_s)
                if not sdf.empty: all_s.append(sdf)
                else:
                    dbg_write(f"{YEAR}_Q{q}_segments_empty", "no rows parsed")

        except Exception as e:
            print(f"[ERROR] {pdf_path.name}: {e}")
            dbg_write(f"{YEAR}_Q{q}_exception", str(e))

    print("\n--- 최종 데이터 표준화 및 저장 ---")

    # --- 데이터 저장 ---
    # 수집된 데이터프레임을 CSV 파일로 저장하는 헬퍼 함수입니다。
    def _save(df_list, key):
        if not df_list:
            print(f"[SKIP] {key}: no data")
            return
        df = pd.concat(df_list, ignore_index=True)
        # 값을 소수점 4자리로 반올림합니다.
        df['value'] = df['value'].apply(_round4)
        # 중복 제거를 위해 각 데이터 유형별 키 컬럼을 정의합니다.
        key_cols = {
            "quarter": ["period", "metric"],
            "balance": ["period", "metric"],
            "cashflow": ["period", "metric"],
            "segments": ["period", "segment_code", "metric"]
        }
        # 중복을 제거하고 데이터를 정렬합니다.
        df = df.drop_duplicates(subset=key_cols[key]).sort_values(by=key_cols[key]).reset_index(drop=True)
        # CSV 파일로 저장합니다.
        df.to_csv(OUTS[key], index=False, encoding='utf-8-sig')
        print(f"[OK] {OUTS[key].name}  rows={len(df)}  cols={list(df.columns)}")

    # 수집된 모든 데이터를 저장합니다.
    _save(all_q, 'quarter')
    _save(all_b, 'balance')
    _save(all_c, 'cashflow')
    _save(all_s, 'segments')


if __name__ == "__main__":
    main()