# -*- coding: utf-8 -*-
"""
01_parse_ir_2022_final.py
삼성전자 2022년 IR PDF 문서에서 주요 재무 데이터를 추출합니다.

이 스크립트는 2020년 파서의 업데이트 버전으로, 2022년 보고서 형식에 맞게 조정되었습니다.
손익계산서(분기별), 재무상태표, 현금흐름표, 사업 부문별 실적 데이터를 추출합니다.

주요 변경 사항 (v29 기준):
- [세그먼트] 'Total'의 세그먼트 ID를 다시 'Total'로 되돌렸습니다 (v28 변경 사항 롤백).
- [세그먼트] 데이터 손실을 방지하기 위해 'Memory' 패턴이 한글과 영문 모두 인식하도록 수정했습니다.

사용법:
    python scripts/01_parse_ir_2022_final.py
"""

import re
import warnings
import logging
from pathlib import Path
import argparse
import pandas as pd
import pdfplumber
from decimal import Decimal, ROUND_HALF_UP, InvalidOperation

# PDF 파싱 라이브러리에서 발생하는 상세 로그를 줄여 콘솔 출력을 깔끔하게 유지합니다.
logging.getLogger("pdfminer").setLevel(logging.ERROR)
logging.getLogger("pdfplumber").setLevel(logging.ERROR)
# 불필요한 경고 메시지를 무시합니다.
warnings.filterwarnings("ignore")

# --- 경로 설정 ---
BASE = Path(__file__).resolve().parents[1]
RAW  = BASE / "data" / "raw"
DEBUG_DIR = RAW / "debug"
RAW.mkdir(parents=True, exist_ok=True)
DEBUG_DIR.mkdir(parents=True, exist_ok=True)

# ---------- 페이지 번호 지정 (2022년 PDF 기준) ----------
# 각 분기별 보고서에서 재무상태표와 현금흐름표가 위치한 페이지를 지정합니다.
BAL_PAGE_OVERRIDES = {"2022_1Q": 7, "2022_2Q": 7, "2022_3Q": 7, "2022_4Q": 7}
CF_PAGE_OVERRIDES  = {"2022_1Q": 8, "2022_2Q": 8, "2022_3Q": 8, "2022_4Q": 8}

# ---------- 정규식 (Regex) ----------
HDR_Q_RE      = re.compile(r"([1-4])\s*Q\s*[’']\s*(\d{2})") # "1 Q '22" 형식의 분기 헤더
RE_QY1        = re.compile(r"([1-4])\s*Q(?:\s*말)?\s*[’']\s*(\d{2})") # "1Q'22" 또는 "1Q말'22"
RE_YQ2        = re.compile(r"[’']\s*(\d{2})\s*년\s*([1-4])\s*분기(?:말)?") # "'22년 1분기" 또는 "'22년 1분기말"
RE_YE         = re.compile(r"[’']\s*(\d{2})\s*년\s*말") # "'22년 말"

VAL_RE   = re.compile(r"(?:△|\()?-?[\d,.]+\)?") # 숫자 값 (음수, 괄호, 쉼표, 소수점 포함)
TRI_NUM_RE    = re.compile(r"([\(△\-−–]?\d[\d,]*\.?\d*\)?)\s+([\(△\-−–]?\d[\d,]*\.?\d*\)?)\s+([\(△\-−–]?\d[\d,]*\.?\d*\)?)") # 3개의 숫자 그룹
TOTAL_RE      = re.compile(r"(총\s*액|총액|합계)[^\d\-()△−–]*" + TRI_NUM_RE.pattern) # '총계' 등 레이블 뒤의 3개 숫자 그룹

OP_LABELS       = [r"영업이익", r"영업\s*이익"]
REVENUE_LABELS  = [r"매출\s*액", r"총\s*매출"]

SEGMENT_TITLE_PAT = re.compile(r"(사업부문별|부문별|사업군별)\s*(매출|실적|영업이익)") # 세그먼트 테이블 제목

# ---------- 표준 사업부문(Segment) 이름 정의 (v29: 최종 수정) ----------

SEG_KO_PATTERNS = [
    # 자식 세그먼트 (하이픈으로 시작) - 최우선 순위
    (r"^\s*-\s*mx\s*.*$", "MX", "Mobile eXperience", "Consumer&Mobile"),
    (r"^\s*-\s*vd\s*.*$", "VD", "Visual Display", "Consumer&Mobile"),

    # 2. 부모 세그먼트 (더 구체적인 것부터)
    (r"mx\s*/\s*네트워크", "MX_NW", "MX & Network", "Consumer&Mobile"),
    (r"mx.*network", "MX_NW", "MX & Network", "Consumer&Mobile"),
    (r"vd.*da", "VD_DA", "VD & DA", "Consumer&Mobile"),
    (r"vd.*가전", "VD_DA", "VD & Home Appliances", "Consumer&Mobile"),
    (r"^\s*dx\s*.*$", "DX", "Device eXperience", "Consumer&Mobile"),

    # 3. 일반 세그먼트 (자식/부모 패턴과 겹치지 않는 것들)
    (r"^\s*ce\s*부문\s*.*$", "CE", "Consumer Electronics", "Consumer&Mobile"),
    (r"^\s*im\s*부문\s*.*$", "IM", "IT & Mobile communications", "Consumer&Mobile"),
    (r"^\s*ds\s*부문\s*.*$", "DS", "Device Solutions", "Semiconductor"),
    (r"^(harman|하만)\s*.*$",   "Harman", "Harman", "Harman"), # 일관성을 위해 한글 '하만' 추가
    (r"메모리|Memory", "Memory", "Memory", "Semiconductor"),
    (r"^\s*network(s)?\s*.*$", "Network", "Network", "Consumer&Mobile"),
    (r"^\s*dp\s*부문\s*.*$", "DP", "Display Panel", "Display"),
    # 4. 일반적인 MX, VD (하이픈 없이 단독으로 나타날 경우, 부모보다 낮은 우선순위)
    (r"\bMX\b", "MX", "Mobile eXperience", "Consumer&Mobile"), # 단어 경계(\b)를 사용하여 더 유연하게 매칭
    (r"\bVD\b", "VD", "Visual Display", "Consumer&Mobile"),
    (r"\bSDC\b", "SDC", "Samsung Display", "Display"), # SDC에 단어 경계 추가

    # 5. 레거시 및 총계
    (r"^\s*총(액|합|계)\s*.*$", "Total", "Total", "Total")
]


def translate_segment_as_reported(s: str):
    """보고서에 기재된 한글 세그먼트 이름을 표준 코드, 영문명, 상위 그룹으로 변환합니다."""
    # v27: re.match -> re.search로 변경하여 라인 전체에서 패턴을 검색하도록 개선했습니다.
    raw = (s or "").strip()
    base = raw.lower().replace(" ", "")
    for pat, code, name_en, lineage in SEG_KO_PATTERNS:
        if re.search(pat, raw, flags=re.IGNORECASE) or re.search(pat, base, flags=re.IGNORECASE):
            return code, name_en, lineage
    return None, None, None

# ---------- 유틸리티 함수 ----------
def clean_num(s: str) -> float:
    """숫자 문자열을 정리하여 float으로 변환합니다. (음수, 괄호, 특수문자 처리)"""
    if s is None: return float("nan")
    s = s.strip().replace("△", "-").replace("−", "-").replace("–", "-").replace("▲", "-")
    neg = s.startswith("(") and s.endswith(")")
    if neg: s = s[1:-1]
    s = s.replace(",", "")
    try:
        v = float(s)
    except (ValueError, TypeError):
        return float("nan")
    return -v if neg else v

def dump_page_text(stem: str, page: int, text: str):
    """디버깅을 위해 추출된 페이지 텍스트를 파일로 저장합니다."""
    out = DEBUG_DIR / f"{stem}_p{page}.txt"
    with open(out, "w", encoding="utf-8") as f:
        f.write(text or "")
    return out

def get_page_text(path: Path, page: int) -> str:
    """PDF 파일의 특정 페이지에서 텍스트를 추출하고, 디버그용 파일로 저장합니다."""
    with pdfplumber.open(path) as pdf:
        if page <= 0 or page > len(pdf.pages):
            print(f"[WARN] Page number {page} is out of range for {path.name} (total pages: {len(pdf.pages)}).")
            return ""
        txt = pdf.pages[page-1].extract_text() or ""
    dump_page_text(path.stem, page, txt)
    dbg = DEBUG_DIR / f"{path.stem}_p{page}.txt"
    if dbg.exists():
        try:
            t2 = dbg.read_text(encoding="utf-8")
            if len(t2) > len(txt): txt = t2
        except Exception: pass
    return txt

# ---------- 기간(Period) 처리 헬퍼 함수 ----------
def to_periods_from_header(text: str) -> list[str] | None:
    """텍스트 헤더에서 '1 Q '22' 형식의 분기 정보를 찾아 기간 목록을 생성합니다."""
    qs = HDR_Q_RE.findall(text)
    if len(qs) >= 3:
        return [f"20{int(yy)}Q{int(q)}" for q, yy in qs[:3]]
    return None

def to_periods_from_balance_header(text: str) -> list[str] | None:
    """재무상태표 헤더의 다양한 기간 형식을 파싱하여 표준 기간 목록을 생성합니다."""
    tokens = []
    tokens += [(2000+int(y), int(q)) for q, y in RE_QY1.findall(text)]
    tokens += [(2000+int(y), int(q)) for y, q in RE_YQ2.findall(text)]
    tokens += [(2000+int(y), 4) for y in RE_YE.findall(text)]
    if len(tokens) < 3: return None
    return [f"{y}Q{q}" for (y, q) in tokens[:3]]

def to_periods_from_cf_header(text: str) -> list[str] | None:
    """현금흐름표 헤더의 다양한 기간 형식을 파싱하여 표준 기간 목록을 생성합니다."""
    tokens = []
    tokens += [(2000+int(y), int(q)) for q, y in RE_QY1.findall(text)]
    tokens += [(2000+int(y), int(q)) for y, q in RE_YQ2.findall(text)]
    tokens += [(2000+int(y), 4) for y in RE_YE.findall(text)]
    if len(tokens) < 3: return None
    return [f"{y}Q{q}" for (y, q) in tokens[:3]]

def normalize_periods_for_quarter(periods: list[str], fname: str) -> list[str]:
    """특정 파일(2022_1Q)에 대해 기간 순서를 정규화합니다."""
    # 2022년 1분기 보고서는 다른 분기와 달리 기간 컬럼 순서가 역순(과거 -> 현재)으로 되어 있어, 이를 표준(현재 -> 과거)으로 맞춥니다.
    if fname.startswith("2022_1Q"):
        return [periods[2], periods[1], periods[0]]
    return periods

# ---------- 분기 실적 (매출/영업이익) 파싱 ----------
TRI_NUM_BLOCK_RE = re.compile(TOTAL_RE.pattern)

def find_tri_after_label(text: str, label: str):
    """주어진 레이블(예: '매출액') 다음에 나오는 3개의 숫자 그룹을 찾습니다."""
    p = re.compile(rf"{label}[^\d\-(△−–]*{TRI_NUM_RE.pattern}", re.MULTILINE)
    m = p.search(text)
    if not m: return None
    return [clean_num(x) for x in m.groups()[-3:]]

def parse_quarter(path: Path) -> list[dict]:
    """PDF 페이지를 순회하며 분기별 매출과 영업이익 데이터를 파싱합니다."""
    rows = []
    with pdfplumber.open(path) as pdf:
        for i, page in enumerate(pdf.pages, start=1):
            txt = page.extract_text() or ""
            dump_page_text(path.stem, i, txt)
            periods = to_periods_from_header(txt)
            if not periods: continue
            periods = normalize_periods_for_quarter(periods, path.name)
            all_tot = list(TRI_NUM_BLOCK_RE.finditer(txt))
            if all_tot:
                for k, m in enumerate(all_tot[:2]):
                    vals = [clean_num(x) for x in m.groups()[-3:]]
                    metric = "revenue" if k == 0 else "op_profit"
                    for per, v in zip(periods, vals):
                        rows.append({"period": per, "metric": metric, "value": v, "source": "IR_PDF", "file": path.name, "page": i})
            else:
                rev = None
                for lab in REVENUE_LABELS:
                    rev = find_tri_after_label(txt, lab)
                    if rev:
                        for per, v in zip(periods, rev):
                            rows.append({"period": per, "metric": "revenue", "value": v, "source": "IR_PDF", "file": path.name, "page": i})
                        break
                for lab in OP_LABELS:
                    tri = find_tri_after_label(txt, lab)
                    if tri:
                        for per, v in zip(periods, tri):
                            rows.append({"period": per, "metric": "op_profit", "value": v, "source": "IR_PDF", "file": path.name, "page": i})
                        break
    return rows

# ---------- 사업부문별(Segments) 실적 파싱 (v29: 최종 수정) ----------
def parse_segments(path: Path) -> list[dict]:
    """PDF 페이지를 순회하며 사업부문별 매출 및 영업이익 데이터를 파싱합니다."""
    rows = []
    with pdfplumber.open(path) as pdf:
        for i, page in enumerate(pdf.pages, start=1):
            txt = page.extract_text() or ""
            dump_page_text(path.stem, i, txt)

            if not SEGMENT_TITLE_PAT.search(txt): continue
            periods = to_periods_from_header(txt)
            if not periods: continue
            periods = normalize_periods_for_quarter(periods, path.name)
            ncol = 3

            current_metric = None
            for ln in txt.splitlines():
                ln_strip = ln.strip()
                if not ln_strip: continue

                if "매출" in ln_strip and "영업이익" not in ln_strip:
                    current_metric = "revenue"
                    continue
                elif "영업이익" in ln_strip and "매출" not in ln_strip:
                    current_metric = "op_profit"
                    continue
                
                if current_metric:
                    code, name_en, lineage = translate_segment_as_reported(ln_strip)
                    if not code: continue
                    
                    nums = VAL_RE.findall(ln_strip)
                    if len(nums) >= ncol:
                        vals = [clean_num(v) for v in nums[:ncol]]
                        for h_idx, val in enumerate(vals):
                            if val == val: # NaN이 아닌지 확인
                                rows.append({
                                    "period": periods[h_idx],
                                    "segment_code": code,
                                    "segment_name_en": name_en,
                                    "lineage_group": lineage,
                                    "metric": current_metric,
                                    "value": val,
                                    "scope": "segment",
                                    "unit": "조원",
                                    "source": "IR_PDF",
                                    "file": path.name,
                                    "page": i,
                                })
    return rows

# ---------- 재무상태표(Balance Sheet) 파싱 ----------
BAL_PATTERNS = {
    "asset_line":      [r"^\s*자\s*산(?!\s*계)\b"], # '자산' (자산계 제외)
    "asset_total":     [r"^\s*자\s*산\s*계\b", r"^\s*자산계\b", r"^\s*자\s*산\s*총\s*계\b", r"^\s*자산총계\b"], # '자산계', '자산총계'
    "liab_line":       [r"^\s*부\s*채\b", r"^\s*부채\s*총\s*계\b", r"^\s*부채총계\b"], # '부채', '부채총계'
    "equity_line":     [r"^\s*자\s*본\b", r"^\s*자본\s*총\s*계\b", r"^\s*자본총계\b"], # '자본', '자본총계'
    "le_total":        [r"^\s*부\s*채\s*와\s*자\s*본\s*계\b", r"^\s*부채와\s*자본계\b"], # '부채와자본계'
}

def _looks_like_ratio_line(line: str) -> bool:
    """해당 라인이 비율(%)이나 비율 관련 텍스트를 포함하는지 확인합니다."""
    if "%" in line: return True
    if "비율" in line: return True
    if "(" in line and ")" in line and "/" in line: return True
    return False

def _find_line_values(txt: str, patterns: list[str]) -> list[float] | None:
    """텍스트에서 주어진 패턴에 맞는 라인을 찾아 숫자 값 3개를 추출합니다."""
    for raw in txt.splitlines():
        if not raw or _looks_like_ratio_line(raw): continue
        line = re.sub(r"\s+", " ", raw.strip())
        for pat in patterns:
            if re.search(pat, raw):
                nums = VAL_RE.findall(line)
                if len(nums) >= 3:
                    return [clean_num(x) for x in nums[:3]]
    return None

def parse_balance_table(txt: str, periods: list[str], fname: str, page: int) -> list[dict]:
    """재무상태표 텍스트에서 자산, 부채, 자본 데이터를 파싱합니다."""
    asset_total_won = _find_line_values(txt, BAL_PATTERNS["asset_total"])
    asset_line_won  = _find_line_values(txt, BAL_PATTERNS["asset_line"])
    liab_line_won   = _find_line_values(txt, BAL_PATTERNS["liab_line"])
    equity_line_won = _find_line_values(txt, BAL_PATTERNS["equity_line"])
    le_total_won    = _find_line_values(txt, BAL_PATTERNS["le_total"])

    rows = []
    if not any([asset_total_won, asset_line_won, liab_line_won, equity_line_won, le_total_won]):
        return rows

    assets_won = asset_total_won if asset_total_won else asset_line_won
    TOL_WON = 0.05 * 10000 # 허용 오차 (조원 단위)

    for idx, per in enumerate(periods):
        a_w  = (assets_won[idx] if assets_won else float("nan"))
        l_w  = (liab_line_won[idx] if liab_line_won else float("nan"))
        e_w  = (equity_line_won[idx] if equity_line_won else float("nan"))
        le_w = (le_total_won[idx] if le_total_won else float("nan"))

        have_l, have_e, have_le, have_a = (l_w==l_w), (e_w==e_w), (le_w==le_w), (a_w==a_w)
        if have_l and have_e:
            if have_le and abs((l_w + e_w) - le_w) > TOL_WON:
                print(f"[WARN] {fname} p{page} {per}: (l+e) {(l_w+e_w)/10000:.2f} != total {le_w/10000:.2f}")
            if have_a and abs(a_w - (l_w + e_w)) > TOL_WON:
                print(f"[WARN] {fname} p{page} {per}: assets {a_w/10000:.2f} != l+e {(l_w+e_w)/10000:.2f}")

        if have_le and have_a and abs(a_w - le_w) > TOL_WON:
            print(f"[ADJUST] {fname} p{page} {per}: assets {a_w/10000:.2f} -> {le_w/10000:.2f}")
            a_w = le_w

        to_jo2 = lambda x: round(x/10000, 2) if x == x else x
        for metric, val in [("assets", a_w), ("liabilities", l_w), ("equity", e_w)]:
            vj = to_jo2(val)
            if vj == vj:
                rows.append({"period": per, "metric": metric, "value": vj, "source": "IR_PDF", "file": fname, "page": page})
    return rows

# ---------- 현금흐름표(Cashflow) 파싱 ----------
CF_LINE_KEYS = {
    "cfo": [r"^\s*영업활동으로 인한 현금흐름\s*"],
    "cfi": [r"^\s*투자활동으로 인한 현금흐름\s*"],
    "cff": [r"^\s*재무활동으로 인한 현금흐름\s*"],
    "cash_begin": [r"^\s*기초현금\s*"],
    "cash_end": [r"^\s*기말현금\s*"],
    "cash_change": [r"^\s*현금.*증감\s*"],
    "net_cash": [r"^\s*순현금\s*$"],
}

def _strip_year_tokens(line: str) -> str:
    """라인에서 ''22년 1분기'와 같은 연도/분기 토큰을 제거합니다."""
    pat = re.compile(r"[’']\s*\d{2}\s*년(?:\s*[\d가-힣]*분기(?:말)?)?")
    return re.sub(pat, "", line)

def parse_cashflow_table(txt: str, periods: list[str], fname: str, page: int) -> list[dict]:
    """현금흐름표 텍스트에서 주요 항목(CFO, CFI, CFF 등)을 파싱합니다."""
    rows = []
    for raw in txt.splitlines():
        line = re.sub(r"\s+", " ", raw.strip())
        line_clean = _strip_year_tokens(line)
        for key, labels in CF_LINE_KEYS.items():
            for pat in labels:
                if re.search(pat, line_clean):
                    nums = VAL_RE.findall(line_clean)
                    nums = [t for t in nums if "%" not in t]
                    if len(nums) >= 3:
                        vals = [clean_num(x) for x in nums[-3:]]
                        for per, v in zip(periods, vals):
                            rows.append({"period": per, "metric": key, "value": v, "source": "IR_PDF", "file": fname, "page": page})
    return rows

def parse_balance_cashflow(path: Path):
    """지정된 페이지에서 재무상태표와 현금흐름표 데이터를 파싱합니다."""
    bal_rows, cf_rows = [], []
    fname = path.name
    bal_page = next((BAL_PAGE_OVERRIDES[k] for k in BAL_PAGE_OVERRIDES if fname.startswith(k)), None)
    cf_page  = next((CF_PAGE_OVERRIDES[k]  for k in CF_PAGE_OVERRIDES  if fname.startswith(k)), None)
    per_b = None

    if bal_page:
        txt_b = get_page_text(path, bal_page)
        per_b = to_periods_from_balance_header(txt_b) or to_periods_from_header(txt_b)
        if not per_b:
            print(f"[HINT] balance header parse failed: {fname} p{bal_page}")
        else:
            print(f"[INFO] balance periods {fname} p{bal_page}: {per_b}")
            bal_rows.extend(parse_balance_table(txt_b, per_b, fname, bal_page))

    if cf_page:
        txt_c = get_page_text(path, cf_page)
        if fname.startswith("2022_4Q"):
            # 4분기 보고서는 연간(FY) 실적을 포함하므로, 헤더 파싱 대신 표준 기간을 직접 지정합니다.
            per_c = ["2022Q4", "2022FY", "2021FY"] # 2022년 4분기는 하드코딩된 기간 사용
            print(f"[INFO] cashflow periods (hardcoded) {fname} p{cf_page}: {per_c}")
        else:
            per_c = to_periods_from_cf_header(txt_c) or to_periods_from_header(txt_c)
        
        if not per_c and per_b:
            per_c = per_b # 현금흐름표 기간 파싱 실패 시 재무상태표 기간으로 대체
            print(f"[INFO] cashflow header fallback to balance periods: {per_c}")
        if not per_c:
            print(f"[HINT] cashflow header parse failed: {fname} p{cf_page}")
        else:
            if not fname.startswith("2022_4Q"):
                print(f"[INFO] cashflow periods {fname} p{cf_page}: {per_c}")
            
            cf_rows.extend(parse_cashflow_table(txt_c, per_c, fname, cf_page))
            cf_rows.extend(parse_net_cash_panel(txt_c, per_c, fname=fname, page_no=cf_page))

    if bal_rows: bal_rows = [dict(t) for t in {tuple(d.items()) for d in bal_rows}]
    if cf_rows: cf_rows  = [dict(t) for t in {tuple(d.items()) for d in cf_rows}]
    return bal_rows, cf_rows

def parse_net_cash_panel(txt: str, periods: list[str], fname: str, page_no: int | None = None) -> list[dict]:
    """
    순현금(Stock) 패널에서 'net_cash' 행을 생성해 반환합니다.
    - 대상 표현 예: '순현금', '순 현금', '순현금 현황', 'Net cash'
    - periods 길이에 맞춰 우측에서 n개 숫자를 매핑합니다.
    - 퍼센트(%) 토큰은 배제하여 QoQ/YoY 비율 혼입을 방지합니다.
    - 음수/괄호/△ 처리는 기존 clean_num 함수에 위임합니다.

    Args:
        txt (str): 해당 페이지 전체 텍스트
        periods (list[str]): 이 페이지에서 사용할 기간 라벨 (예: ['2022Q4','2022FY','2021FY'])
        fname (str): 파일명 (원본 추적용)
        page_no (int | None): 페이지 번호 (1-based로 저장)

    Returns:
        list[dict]: [{'period','metric'='net_cash','value','source','page'} ...]
    """
    rows: list[dict] = []
    if not txt or not periods:
        return rows

    # 앵커: 라인 어디에 있어도 매칭되도록 완화
    whole = txt.replace(" ", "")
    has_anchor = ("순현금" in whole) or ("순현금현황" in whole) or ("netcash" in txt.lower().replace(" ", ""))
    if not has_anchor:
        return rows

    for raw in txt.splitlines():
        line = raw.strip()
        if not line:
            continue

        # 후보 라인 필터: '순현금' 또는 'net cash' 포함 여부만 확인
        s_nospace = line.replace(" ", "")
        if ("순현금" not in s_nospace) and ("netcash" not in line.lower().replace(" ", "")):
            continue

        # 숫자 토큰 추출 + 퍼센트 제거
        try:
            nums = VAL_RE.findall(line)
        except NameError:
            # VAL_RE가 정의되지 않았을 경우를 대비한 폴백
            import re as _re
            _VAL_RE_FALLBACK = _re.compile(r"[()\-\d,\.]+")
            nums = _VAL_RE_FALLBACK.findall(line)

        nums = [t for t in nums if "%" not in t]
        if len(nums) < 3:
            # 컬럼 수가 부족하면 다음 라인 탐색
            continue

        # 우측부터 periods 개수만큼 사용 (현재는 3개 기간을 가정)
        vals = [clean_num(x) for x in nums[-3:]]

        for per, v in zip(periods, vals):
            rows.append({
                "period": per,
                "metric": "net_cash",
                "value": v,
                "source": fname,
                "page": (page_no + 1) if isinstance(page_no, int) else None,
            })

        # 첫 매칭 후 중복 방지를 위해 종료
        break

    return rows

# ---------- 데이터 저장 헬퍼 함수 ----------
def _period_sort(df, by_cols=None):
    """데이터프레임을 기간(period) 및 추가 컬럼 기준으로 정렬합니다."""
    if df is None or "period" not in df.columns: return df
    key_cols = ["period"] + ([c for c in (by_cols or []) if c in df.columns])
    return df.sort_values(key_cols).reset_index(drop=True)

def _drop_dupes(df, subset):
    """주어진 컬럼(subset) 기준으로 데이터프레임의 중복 행을 제거합니다."""
    subset = [c for c in subset if c in df.columns]
    return df.drop_duplicates(subset=subset).reset_index(drop=True)

def _save(df, path: Path):
    """데이터프레임을 지정된 경로에 CSV 파일로 저장합니다."""
    df.to_csv(path, index=False, encoding="utf-8-sig")
    print(f"[OK] {path} ({len(df)})")

# ---------- 메인 실행 함수 ----------
def main():
    # 커맨드라인 인자 파서 설정
    ap = argparse.ArgumentParser()
    ap.add_argument("--pdf_glob", default="2022_*_conference*.pdf", help="처리할 PDF 파일의 glob 패턴")
    args = ap.parse_args()
    files = sorted(RAW.glob(args.pdf_glob))
    if not files:
        print(f"[WARN] no PDFs found for glob '{args.pdf_glob}'")
        return

    # 모든 파일에서 추출한 데이터를 저장할 리스트 초기화
    q_all, seg_all, bal_all, cf_all = [], [], [], []
    for path in files:
        print(f"--- Processing {path.name} ---")
        q_all.extend(parse_quarter(path))
        seg_all.extend(parse_segments(path))
        b, c = parse_balance_cashflow(path)
        bal_all.extend(b); cf_all.extend(c)

    def _df(rows, cols=None):
        """행(rows) 리스트로부터 데이터프레임을 생성합니다."""
        if not rows: return None
        df = pd.DataFrame(rows)
        return df[cols] if cols else df

    # 각 데이터 유형별로 데이터프레임 생성
    df_q  = _df(q_all)
    df_s  = _df(seg_all)
    df_b  = _df(bal_all)
    df_cf = _df(cf_all)

    # 재무상태표 데이터 처리 및 저장
    if df_b is not None:
        df_b = _drop_dupes(df_b, ["period","metric"])
        df_b = df_b.assign(category="balance", unit="조원")
        df_b = df_b[["period","metric","value","category","unit", "source"]]
        df_b = _period_sort(df_b, by_cols=["metric"])
        _save(df_b, RAW/"ir_balance_2022.csv")
    else:
        print("[HINT] no rows: ir_balance_2022.csv")

    # 현금흐름표 데이터 처리 및 저장
    if df_cf is not None:
        df_cf = _drop_dupes(df_cf, ["period","metric"])
        df_cf = df_cf.assign(category="cashflow", unit="조원")
        df_cf = df_cf[["period","metric","value","category","unit", "source"]]
        df_cf = _period_sort(df_cf, by_cols=["metric"])
        _save(df_cf, RAW/"ir_cashflow_2022.csv")
    else:
        print("[HINT] no rows: ir_cashflow_2022.csv")

    # 분기 실적 데이터 처리 및 저장
    if df_q is not None:
        if "value" in df_q.columns:
            df_q = df_q.rename(columns={"value":"value_trillion"})
        if "value_trillion" not in df_q.columns:
            df_q = df_q.assign(value_trillion=pd.NA)
        df_q = df_q.assign(explain="")
        subset = ["period","metric"] if "metric" in df_q.columns else ["period"]
        df_q = _drop_dupes(df_q, subset)
        keep = ["period","metric","value_trillion","explain", "source"]
        have = [c for c in keep if c in df_q.columns]
        df_q = df_q[have]
        df_q = _period_sort(df_q, by_cols=["metric"])
        _save(df_q, RAW/"ir_quarter_2022.csv")
    else:
        print("[HINT] no rows: ir_quarter_2022.csv")

    # [v29] 사업부문별 실적(SEGMENTS) 저장 로직 변경
    if df_s is not None:
        df_s = _drop_dupes(df_s, ["period", "segment_code", "metric"])
        df_s = df_s.assign(scope="", unit="조원")
        # 최종 컬럼 순서 및 이름 통일
        keep = ["period", "segment_code", "segment_name_en", "lineage_group", "metric", "value", "scope", "unit", "source"]
        have = [c for c in keep if c in df_s.columns]
        df_s = df_s[have]
        df_s = _period_sort(df_s, by_cols=["segment_code", "metric"])
        _save(df_s, RAW/"ir_segments_2022.csv")
    else:
        print("[HINT] no rows: ir_segments_2022.csv")

if __name__ == "__main__":
    main()