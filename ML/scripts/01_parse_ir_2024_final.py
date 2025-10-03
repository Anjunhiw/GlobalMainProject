# -*- coding: utf-8 -*- 
# scripts/01_parse_ir_2024_final.py
#
# 목표: 2024년 IR PDF에서 전사 실적, 부문별 실적, 재무상태표, 현금흐름표 데이터를 모두 추출
#
# final(v4) 변경점:
# - VAL_RE를 2024+ 형식에 맞게 단순화하여 소괄호 음수 처리 안정성 확보. (SyntaxError 수정)
# - 사업부문(Segment) 파싱 로직을 lineage_group 기반으로 변경하여 데이터 일관성 확보.
# - 2022_v26 스크립트와 동일한 `SEG_KO_PATTERNS` 및 `translate_segment_as_reported` 함수를 도입.
# - `parse_segments` 함수를 재작성하여 `lineage_group`을 포함한 표준화된 컬럼 구조로 출력.
# - 2024년 PDF의 분기별 컬럼 순서 변경에 대응하는 `reorder_columns` 기능은 유지.

import re
import os
import sys
import logging
import contextlib
import unicodedata
from pathlib import Path
from typing import List, Dict, Tuple, Optional, Any

import pandas as pd
import pdfplumber
from pypdf import PdfReader

# ────────────────────────────────────────────────────────────────────────────────
# 경로 및 상수 설정
# 스크립트의 위치를 기준으로 기본 경로, 원시 데이터 경로, 디버그 출력 경로를 설정합니다.
BASE_DIR = Path(__file__).resolve().parent.parent
RAW_DIR = BASE_DIR / "data" / "raw"
DBG_DIR = RAW_DIR / "debug"
DBG_DIR.mkdir(parents=True, exist_ok=True)

# pdfminer 로깅 수준을 ERROR로 설정하여 불필요한 로그 출력을 줄입니다.
logging.getLogger("pdfminer").setLevel(logging.ERROR)

# 각 보고서 파일별로 재무상태표와 현금흐름표가 위치한 페이지 번호를 지정합니다.
PAGE_OVERRIDES = {
    "2024_1Q_conference_kor": {"balance": 12, "cashflow": 13},
    "2024_2Q_conference_kor": {"balance": 12, "cashflow": 13},
    "2024_3Q_conference_kor": {"balance": 13, "cashflow": 14},
    "2024_4Q_conference_kor": {"balance": 13, "cashflow": 14},
}

# ────────────────────────────────────────────────────────────────────────────────
# 공통 유틸리티 함수
def remove_zero_width(s: str) -> str:
    """문자열에서 폭이 0인 유니코드 문자(zero-width characters)를 제거합니다."""
    return "".join(ch for ch in (s or "") if unicodedata.category(ch) != "Cf").replace("﻿", "")

def clean_spaces(s: str) -> str:
    """다양한 종류의 공백 문자를 표준 공백으로 변환하고, 연속된 공백을 하나로 합칩니다."""
    s = remove_zero_width(s)
    s = (s.replace("\u2009", " ").replace("\u202f", " ").replace("\xa0", " ").replace("／", "/"))
    s = re.sub(r"[ \t]+", " ", s).strip()
    return s

def _parse_num_str(tok: str) -> Optional[float]:
    """숫자 문자열을 파싱하여 float으로 변환합니다. 괄호로 둘러싸인 경우 음수로 처리합니다."""
    if not tok: return None
    t = tok.strip()
    neg = False
    if t.startswith("(") and t.endswith(")"):
        t = t[1:-1]
        neg = True
    t = t.replace(",", "")
    try:
        v = float(t)
        return -v if neg else v
    except (ValueError, TypeError):
        return None

def path_write_text(path: Path, text: str):
    """주어진 텍스트를 지정된 경로에 UTF-8 인코딩으로 저장합니다."""
    try:
        path.write_text(text, encoding="utf-8", errors="ignore")
    except Exception:
        pass

def get_report_quarter_from_path(pdf_path: Path) -> Optional[int]:
    """PDF 파일 이름에서 분기 정보를 추출합니다. (예: '..._1Q_...' -> 1)"""
    m = re.search(r"_([1-4])Q", pdf_path.name)
    if m:
        return int(m.group(1))
    return None

def reorder_columns(
    headers: List[str], values: List[Any], report_q: Optional[int]
) -> Tuple[List[str], List[Any]]:
    """특정 분기 보고서(2,3,4분기)의 컬럼 순서가 다른 경우, 표준 순서로 재정렬합니다."""
    # 2, 3, 4분기 보고서는 컬럼 순서가 역순으로 되어 있는 경우가 있어 이를 표준화합니다.
    if report_q in [2, 3, 4]:
        if len(headers) == 3 and len(values) == 3:
            return [headers[2], headers[1], headers[0]], [values[2], values[1], values[0]]
        elif len(headers) == 2 and len(values) == 2:
            return [headers[1], headers[0]], [values[1], values[0]]
    return headers, values

# ────────────────────────────────────────────────────────────────────────────────
# PDF 텍스트 추출 함수
def extract_page_text(pdf_path: Path, page_no_1idx: int) -> str:
    """pdfplumber를 사용하여 PDF의 특정 페이지에서 텍스트를 추출합니다."""
    with pdfplumber.open(pdf_path) as pdf:
        if page_no_1idx > len(pdf.pages):
            return ""
        page = pdf.pages[page_no_1idx - 1]
        # 더 나은 텍스트 추출을 위해 두 가지 다른 허용 오차 값으로 시도합니다.
        t = page.extract_text(x_tolerance=1, y_tolerance=1) or page.extract_text() or ""
        return t

# ────────────────────────────────────────────────────────────────────────────────
# 1. 전사 실적 파싱 (기존 로직 유지)
# ────────────────────────────────────────────────────────────────────────────────
RE_REV_LABEL = re.compile(r"^(매\s*출(액)?(?!\s*원가|\s*총))|Revenue", re.I)
RE_OP_LABEL = re.compile(r"(영\s*업\s*이\s*익|Operating\s*Profit|^OP$|\bOP\b)", re.I)
RE_GPROFIT = re.compile(r"(매\s*출\s*총\s*이\s*익|Gross\s*Profit)", re.I)
RE_OP_MARGINLN = re.compile(r"(영\s*업\s*이\s*익\s*률|이\s*익\s*률|마\s*진|op\s*margin|operating\s*margin|margin|ratio|rate|opm)", re.I)

def normalize_to_trillion(val: float, unit: str) -> float:
    """주어진 값을 '조원' 단위로 정규화합니다."""
    if unit == "tril": return val
    if unit == "ok": return val / 1e4 # '억' 단위를 '조' 단위로 변환
    return val

def is_reasonable_revenue(tril: float) -> bool: 
    """매출액 값이 합리적인 범위(50조 ~ 150조)에 있는지 확인합니다."""
    return 50 <= tril <= 150
def is_reasonable_op(tril: float) -> bool: 
    """영업이익 값이 합리적인 범위(0조 ~ 40조)에 있는지 확인합니다."""
    return 0 <= tril <= 40

def extract_consolidated_table_wide(pdf_path: Path) -> List[Dict[str, Any]]:
    """PDF에서 '전사 손익' 테이블을 찾아 매출과 영업이익 데이터를 추출합니다."""
    results: List[Dict[str, Any]] = []
    report_q = get_report_quarter_from_path(pdf_path)

    def normalize_header_period(h: str) -> Optional[str]:
        """'1 Q '24'와 같은 헤더 문자열을 '2024Q1' 형식으로 표준화합니다."""
        if not h: return None
        m = re.search(r"([1-4])\s*Q\s*'\s*(\d{2})", h)
        if m: return f"20{m.groups()[1]}Q{m.groups()[0]}"
        return None

    with contextlib.redirect_stderr(open(os.devnull, "w")):
        with pdfplumber.open(pdf_path) as pdf:
            for page in pdf.pages:
                page_text = page.extract_text(x_tolerance=1.5) or ""
                if not any(k in page_text for k in ["전사 손익 분석", "전사 매출 및 손익 세부"]): continue

                lines = page_text.splitlines()
                period_headers_raw, header_line_idx = [], -1
                for i, line in enumerate(lines):
                    q_strings = re.findall(r"([1-4]\s*Q\s*'\s*\d{2})", line)
                    if len(q_strings) >= 2:
                        period_headers_raw = q_strings
                        header_line_idx = i
                        break
                if not period_headers_raw: continue
                period_headers = [p for p in (normalize_header_period(q) for q in period_headers_raw) if p]

                for line in lines[header_line_idx + 1:]:
                    line = line.strip()
                    metric_name, is_reasonable_func = None, None
                    if RE_REV_LABEL.match(line) and not RE_GPROFIT.search(line): metric_name, is_reasonable_func = "revenue", is_reasonable_revenue
                    elif RE_OP_LABEL.match(line) and not RE_OP_MARGINLN.search(line): metric_name, is_reasonable_func = "op_profit", is_reasonable_op
                    if not metric_name or not is_reasonable_func: continue
                    
                    toks = re.findall(r"([0-9]+(?:[.,]\s*[0-9]+)?)\s*(%|％)?", line)
                    nums = [_parse_num_str(t[0]) for t in toks if t[1] != '%' and _parse_num_str(t[0]) is not None]
                    reordered_headers, reordered_nums = reorder_columns(period_headers, nums, report_q)

                    for i, period in enumerate(reordered_headers):
                        if i < len(reordered_nums):
                            val_tril = normalize_to_trillion(reordered_nums[i], "tril")
                            if is_reasonable_func(val_tril):
                                results.append({"period": period, "metric": metric_name, "value": val_tril})
                if results: break

    if not results: return []
    # 중복된 결과 제거
    seen = set()
    unique_results = []
    for d in results:
        t = tuple(sorted(d.items()))
        if t not in seen:
            seen.add(t)
            unique_results.append(d)
    return unique_results

def parse_quarterly_data(pdf_path: Path) -> List[Dict]:
    """전사 실적 데이터를 파싱하여 표준 형식의 딕셔너리 리스트로 반환합니다."""
    table_results = extract_consolidated_table_wide(pdf_path)
    rows = []
    if table_results:
        for r in table_results:
            rows.append({'period': r['period'], 'metric': r['metric'], 'value_trillion': r['value'], 'source': 'IR_PDF', 'explain': f"text_parser|period:{r['period']}"})
        return rows
    if not rows: print(f"[WARN] Quarterly data not found in {pdf_path.name} using primary method.")
    return rows

# ────────────────────────────────────────────────────────────────────────────────
# 2. 부문별 실적 파싱 (v2: lineage_group 기반으로 변경)
# ────────────────────────────────────────────────────────────────────────────────

SEGMENT_TITLE_PAT = re.compile(r"사업부문별\s*매출\s*(?:및|과)\s*영업이익")
SEGMENT_HEADER_Q_RE = re.compile(r"([1-4])\s*Q\s*'\s*(\d{2}|\d{4})", re.I)
VAL_RE = re.compile(r"\(?[\[\d,.]+\)?") # v4: 2024년 이후 형식에 맞게 정규식 단순화

# 표준 사업부문 이름 및 계층 구조 정의
SEG_KO_PATTERNS = [
    # 1. 가장 구체적인 자식 세그먼트 (하이픈으로 시작)
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
    (r"^(harman|하만)\s*.*$",   "Harman", "Harman", "Harman"), # 우선순위 상향 조정
    (r"메모리|Memory", "Memory", "Memory", "Semiconductor"),
    (r"^\s*network(s)?\s*.*$", "Network", "Network", "Consumer&Mobile"),
    (r"^\s*dp\s*부문\s*.*$", "DP", "Display Panel", "Display"), 

    # 4. 일반적인 MX, VD (하이픈 없이 단독으로 나타날 경우, 부모보다 낮은 우선순위)
    (r"\bMX\b", "MX", "Mobile eXperience", "Consumer&Mobile"), # 단어 경계(\b)를 사용하여 유연성 증대
    (r"\bVD\b", "VD", "Visual Display", "Consumer&Mobile"),
    (r"\bSDC\b", "SDC", "Samsung Display", "Display"), # SDC에 단어 경계 추가

    # 5. 레거시 및 총계
    (r"^\s*총(액|합|계)\s*.*$", "Total", "Total", "Total")
]

def translate_segment_as_reported(s: str):
    """보고서에 기재된 한글 세그먼트 이름을 표준 코드, 영문명, 상위 그룹으로 변환합니다."""
    raw = (s or "").strip()
    base = raw.lower().replace(" ", "")
    for pat, code, name_en, lineage in SEG_KO_PATTERNS:
        # 라인 전체에서 패턴을 검색하도록 re.search 사용
        if re.search(pat, raw, flags=re.IGNORECASE) or re.search(pat, base, flags=re.IGNORECASE):
            return code, name_en, lineage
    return None, None, None


def score_segment_page(txt: str) -> int:
    """페이지 텍스트가 부문별 실적 데이터일 가능성을 점수로 평가합니다."""
    T = clean_spaces(txt)
    sc = 0
    if SEGMENT_TITLE_PAT.search(T): sc += 8
    if ("사업부문" in T and ("매출" in T or "영업이익" in T)): sc += 5
    sc += 2 * len(SEGMENT_HEADER_Q_RE.findall(T))
    if any(k in T for k in ["별첨", "현금흐름", "순현금"]): sc -= 6 # 관련 없는 페이지일 경우 감점
    return sc

def find_best_segment_page(pdf_path: Path) -> Optional[int]:
    """PDF 내에서 부문별 실적 데이터가 있을 가장 가능성 높은 페이지를 찾습니다."""
    best = (-10**9, None)
    with pdfplumber.open(pdf_path) as pdf:
        for p1 in range(1, min(20, len(pdf.pages) + 1)):
            page = pdf.pages[p1 - 1]
            txt = page.extract_text(x_tolerance=1, y_tolerance=1) or page.extract_text() or ""
            if not txt: continue
            sc = score_segment_page(txt)
            if sc > best[0]:
                best = (sc, p1)
    return best[1]

def extract_half_text(page, left: bool) -> str:
    """페이지를 좌/우 절반으로 나누어 텍스트를 추출합니다. (매출/영업이익 분리용)"""
    w = float(page.width)
    h = float(page.height)
    bbox = (0, 0, w * 0.52, h) if left else (w * 0.48, 0, w, h)
    region = page.crop(bbox)
    txt = region.extract_text(x_tolerance=1, y_tolerance=1) or region.extract_text() or ""
    return clean_spaces(txt)

def parse_segment_header_periods(text: str, report_q: Optional[int]) -> List[str]:
    """부문별 실적 테이블의 헤더에서 기간 정보를 파싱합니다."""
    cleaned_text = clean_spaces(text)
    # 4분기 보고서는 연간(FY) 실적을 포함할 수 있습니다.
    fy_re = re.compile(r"(FY\s*'\s*(\d{2}|\d{4}))", re.I) if report_q == 4 else None
    q_matches = SEGMENT_HEADER_Q_RE.findall(cleaned_text)
    fy_matches = fy_re.findall(cleaned_text) if fy_re else []
    periods = []
    for q, yy_str in q_matches:
        y = int(yy_str)
        year = y if y > 2000 else 2000 + y
        periods.append(f"{year}Q{q}")
    for _, yy_str in fy_matches:
        y = int(yy_str)
        year = y if y > 2000 else 2000 + y
        periods.append(f"{year}FY")
    return periods

def parse_segments(pdf_path: Path) -> List[Dict]:
    """PDF에서 부문별 실적(매출, 영업이익) 데이터를 파싱합니다."""
    out: List[Dict] = []
    report_q = get_report_quarter_from_path(pdf_path)

    with pdfplumber.open(pdf_path) as pdf:
        best_pno = find_best_segment_page(pdf_path)
        if not best_pno: return out
        page = pdf.pages[best_pno - 1]

        # 페이지를 좌(매출), 우(영업이익)로 나누어 텍스트 블록을 추출합니다.
        rev_text = extract_half_text(page, left=True)
        op_text = extract_half_text(page, left=False)

        # 각 블록에서 헤더(기간) 정보를 파싱합니다.
        rev_periods = parse_segment_header_periods(rev_text, report_q)
        op_periods = parse_segment_header_periods(op_text, report_q)

        # 각 지표(매출, 영업이익)에 대해 데이터를 파싱합니다.
        for metric, text_block, periods in [("revenue", rev_text, rev_periods), ("op_profit", op_text, op_periods)]:
            if not periods: continue
            for line in text_block.splitlines():
                line = line.strip()
                if not line: continue

                code, name_en, lineage = translate_segment_as_reported(line)
                if not code: continue

                nums = [n for n in (_parse_num_str(s) for s in VAL_RE.findall(line)) if n is not None]
                if not nums: continue

                # 컬럼 순서 재정렬
                reordered_periods, reordered_nums = reorder_columns(periods, nums, report_q)

                for i, value in enumerate(reordered_nums):
                    if i < len(reordered_periods):
                        # 영업이익 값이 비정상적으로 클 경우(20조 초과) 제외합니다.
                        if metric == "op_profit" and value > 20.0: continue
                        
                        out.append({
                            "period": reordered_periods[i],
                            "segment_code": code,
                            "segment_name_en": name_en,
                            "lineage_group": lineage,
                            "metric": metric,
                            "value": value,
                            "scope": "segment",
                            "unit": "조원",
                            "source": "IR_PDF"
                        })
    return out

# ────────────────────────────────────────────────────────────────────────────────
# 3. 별첨 재무/현금흐름 파싱 (기존 로직 유지)
# ────────────────────────────────────────────────────────────────────────────────
NUM_RE_C = r"[\-\(]?\d[\d,]*(?:\.\d+)?\)?"

def to_trillion_from_eok(tok: str) -> Optional[float]:
    """'억원' 단위의 숫자 문자열을 '조원' 단위 float으로 변환합니다."""
    v = _parse_num_str(tok)
    return v / 10000.0 if v is not None else None

def to_trillion_direct(tok: str) -> Optional[float]:
    """'조원' 단위의 숫자 문자열을 float으로 변환합니다."""
    return _parse_num_str(tok)

def extract_numbers_from_line(line: str, converter) -> List[float]:
    """한 라인에서 숫자 값들을 추출하고, 주어진 변환 함수(단위 변환 등)를 적용합니다."""
    num_and_maybe_percent_re = rf"({NUM_RE_C})\s*(%|％)?"
    tokens = re.findall(num_and_maybe_percent_re, clean_spaces(line))
    numbers = []
    for num_str, percent in tokens:
        if not percent: # 퍼센트(%) 기호가 없는 숫자만 추출
            val = converter(num_str)
            if val is not None: numbers.append(val)
    return numbers

def parse_annex_headers(text: str) -> List[str]:
    """별첨 자료의 헤더에서 기간 정보를 파싱합니다."""
    lines = text.splitlines()
    best_line_tokens = []
    header_patterns = [
        re.compile(r"'(?P<y>\d{2})\s*\.\s*(?P<q>[1-4])Q"),
        re.compile(r"(?P<q>[1-4])Q\s*말\s*'\s*(?P<y>\d{2})"),
        re.compile(r"(?P<q>[1-4])Q\s*'\s*(?P<y>\d{2})"),
        re.compile(r"'(?P<y>\d{2})\s*년말?"),
        re.compile(r"\b(?P<y>20\d{2})\b"),
    ]
    for line in lines[:8]: # 상위 8라인만 탐색하여 효율성 증대
        if len(re.findall(r'\d', line)) > 15: continue # 숫자가 너무 많은 라인은 헤더가 아닐 가능성이 높음
        current_line_tokens = [m for pat in header_patterns for m in pat.finditer(clean_spaces(line))]
        if len(current_line_tokens) > len(best_line_tokens): best_line_tokens = current_line_tokens
    if not best_line_tokens: return []
    best_line_tokens.sort(key=lambda m: m.start())
    periods = []
    for match in best_line_tokens:
        d = match.groupdict()
        y_str, q_str = d.get("y"), d.get("q")
        if y_str:
            year = int(y_str) if len(y_str) == 4 else 2000 + int(y_str)
            periods.append(f"{year}Q{q_str}" if q_str else f"{year}FY")
    return periods

# 재무상태표 항목 레이블
LAB_ASSETS = re.compile(r"(?<!\w)자\s*산\s*계\b", re.I)
LAB_LIABS = re.compile(r"(?<!\w)부\s*채\b(?!.*자\s*본\s*계)", re.I)
LAB_EQU = re.compile(r"(?<!\w)자\s*본\b(?!.*계)", re.I)
LAB_LIAEQT = re.compile(r"(?<!\w)부\s*채\s*와\s*자\s*본\s*계\b", re.I)
# 세부 항목을 총계로 오인하지 않도록 제외 리스트
BAL_BLACKLIST = re.compile(r"(매출채권|재고자산|투자자산|현금및현금성자산|유동자산|비유동자산|유동부채|비유동부채|유형자산|무형자산|이익잉여금)", re.I)

def parse_balance(pdf_path: Path) -> List[Dict]:
    """PDF에서 재무상태표(자산, 부채, 자본) 데이터를 파싱합니다."""
    pno = PAGE_OVERRIDES.get(pdf_path.stem, {}).get("balance")
    if not pno: return []
    text = extract_page_text(pdf_path, pno)
    report_q = get_report_quarter_from_path(pdf_path)
    periods = parse_annex_headers(text)
    if not periods: return []
    rows, lines = [], text.splitlines()
    got = {"assets": False, "liabilities": False, "equity": False}

    def process_metric(metric_name, search_regex, blacklist_regex):
        """주어진 정규식으로 특정 재무 지표를 찾아 값을 추출합니다."""
        for ln in lines:
            s = clean_spaces(ln)
            if not search_regex: continue
            match = search_regex.search(s)
            if match and not blacklist_regex.search(s[:match.start()]):
                numbers = extract_numbers_from_line(s[match.end():], to_trillion_from_eok)
                if numbers:
                    reordered_periods, reordered_numbers = reorder_columns(periods, numbers, report_q)
                    for i, v in enumerate(reordered_numbers):
                        if i < len(reordered_periods): rows.append({"period": reordered_periods[i], "category": "balance", "metric": metric_name, "value": v, "unit": "조원", "source": "IR_PDF"})
                    got[metric_name] = True
                    return

    assets_search_regex = LAB_LIAEQT if LAB_LIAEQT.search(clean_spaces(text)) else LAB_ASSETS
    process_metric("assets", assets_search_regex, BAL_BLACKLIST)
    process_metric("liabilities", LAB_LIABS, BAL_BLACKLIST)
    process_metric("equity", LAB_EQU, BAL_BLACKLIST)
    return rows

# 현금흐름표 항목 레이블
CFS_LEFT_LABELS = {"cfo": [r"영업활동(?:으로\s*인한)?\s*현금흐름"], "cfi": [r"투자활동(?:으로\s*인한)?\s*현금흐름"], "cff": [r"재무활동(?:으로\s*인한)?\s*현금흐름"], "cash_begin": [r"기초\s*현금"], "cash_end": [r"기말\s*현금"], "cash_change": [r"현금\s*증감"]}
RIGHT_NETCASH_TITLE = re.compile(r"순\s*현금\s*현황", re.I)

def parse_cashflow(pdf_path: Path) -> List[Dict]:
    """PDF에서 현금흐름표(영업/투자/재무활동, 순현금 등) 데이터를 파싱합니다."""
    pno = PAGE_OVERRIDES.get(pdf_path.stem, {}).get("cashflow")
    if not pno: return []
    text = extract_page_text(pdf_path, pno)
    report_q = get_report_quarter_from_path(pdf_path)
    periods = parse_annex_headers(text)
    if not periods: return []
    rows, lines = [], text.splitlines()
    got = {metric: False for metric in list(CFS_LEFT_LABELS.keys()) + ["net_cash"]}

    for ln in lines:
        s = clean_spaces(ln)
        metric_found = False
        for metric, patt_list in CFS_LEFT_LABELS.items():
            if got[metric]: continue
            for patt in patt_list:
                m = re.search(patt, s, re.I)
                if m:
                    numbers = extract_numbers_from_line(s[m.end():], to_trillion_direct)
                    reordered_periods, reordered_numbers = reorder_columns(periods, numbers, report_q)
                    for i, v in enumerate(reordered_numbers):
                        if i < len(reordered_periods): rows.append({"period": reordered_periods[i], "category": "cashflow", "metric": metric, "value": v, "unit": "조원", "source": "IR_PDF"})
                    if numbers: got[metric] = True
                    metric_found = True
                    break
            if metric_found: break
        if metric_found: continue

        # 순현금 현황은 별도 테이블에 있을 수 있음
        if not got["net_cash"] and RIGHT_NETCASH_TITLE.search(text):
            if re.search(r"^순\s*현금\b", s, re.I):
                numbers = extract_numbers_from_line(s, to_trillion_direct)
                reordered_periods, reordered_numbers = reorder_columns(periods, numbers, report_q)
                for i, v in enumerate(reordered_numbers):
                    if i < len(reordered_periods): rows.append({"period": reordered_periods[i], "category": "cashflow", "metric": "net_cash", "value": v, "unit": "조원", "source": "IR_PDF"})
                if numbers: got["net_cash"] = True
    return rows

# ────────────────────────────────────────────────────────────────────────────────
# Main Orchestrator
# ────────────────────────────────────────────────────────────────────────────────
def main():
    """메인 실행 함수. PDF 파일을 순회하며 모든 데이터를 파싱하고 CSV 파일로 저장합니다."""
    files_to_process = [RAW_DIR / f"2024_{i}Q_conference_kor.pdf" for i in range(1, 5)]
    if len(sys.argv) > 1: files_to_process = [Path(p).resolve() for p in sys.argv[1:]]

    all_rows_quarter, all_rows_segments, all_rows_balance, all_rows_cashflow = [], [], [], []
    for pdf_path in files_to_process:
        if not pdf_path.exists():
            print(f"[WARN] File not found, skipping: {pdf_path}")
            continue
        print(f"\n--- Processing: {pdf_path.name} ---")
        rows_q = parse_quarterly_data(pdf_path)
        all_rows_quarter.extend(rows_q)
        print(f"  - Quarterly: Found {len(rows_q)} data points.")
        rows_s = parse_segments(pdf_path)
        all_rows_segments.extend(rows_s)
        print(f"  - Segments: Found {len(rows_s)} data points.")
        rows_b = parse_balance(pdf_path)
        all_rows_balance.extend(rows_b)
        print(f"  - Balance Sheet: Found {len(rows_b)} data points.")
        rows_c = parse_cashflow(pdf_path)
        all_rows_cashflow.extend(rows_c)
        print(f"  - Cash Flow: Found {len(rows_c)} data points.")

    print("\n--- Saving results ---")

    # 각 데이터 유형별로 DataFrame을 생성하고 중복을 제거한 후 CSV로 저장합니다.
    if all_rows_quarter:
        df = pd.DataFrame(all_rows_quarter).drop_duplicates(subset=['period', 'metric'], keep='last').sort_values(by=['period', 'metric'])
        df.to_csv(RAW_DIR / "ir_quarter_2024.csv", index=False, encoding="utf-8")
        print(f"Saved: {RAW_DIR / 'ir_quarter_2024.csv'} (rows={len(df)})")

    if all_rows_segments:
        df = pd.DataFrame(all_rows_segments).drop_duplicates(subset=['period', 'segment_code', 'metric'], keep='last')
        df = df.sort_values(by=['period', 'segment_code', 'metric'])
        cols = ["period", "segment_code", "segment_name_en", "lineage_group", "metric", "value", "scope", "unit", "source"]
        df = df[cols]
        out_path = RAW_DIR / "ir_segments_2024.csv"
        df.to_csv(out_path, index=False, encoding="utf-8")
        print(f"Saved: {out_path} (rows={len(df)})")

    if all_rows_balance:
        df = pd.DataFrame(all_rows_balance).drop_duplicates(subset=['period', 'metric'], keep='last').sort_values(by=['period', 'metric'])
        df.to_csv(RAW_DIR / "ir_balance_2024.csv", index=False, encoding="utf-8")
        print(f"Saved: {RAW_DIR / 'ir_balance_2024.csv'} (rows={len(df)})")

    if all_rows_cashflow:
        df = pd.DataFrame(all_rows_cashflow).drop_duplicates(subset=['period', 'metric'], keep='last').sort_values(by=['period', 'metric'])
        df.to_csv(RAW_DIR / "ir_cashflow_2024.csv", index=False, encoding="utf-8")
        print(f"Saved: {RAW_DIR / 'ir_cashflow_2024.csv'} (rows={len(df)})")

if __name__ == "__main__":
    main()