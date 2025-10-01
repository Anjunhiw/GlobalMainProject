# -*- coding: utf-8 -*- 
# scripts/01_parse_ir_2025_final.py
#
# 목표: 2025년 IR PDF에서 전사 실적, 부문별 실적, 재무상태표, 현금흐름표 데이터를 모두 추출
#
# final(v5) 변경 요약:
# - 숫자 토큰 NUM_RE_C를 괄호/△/유니코드 마이너스까지 포괄하도록 보강
# - extract_consolidated_table_wide(): 전사 손익 표에서 헤더-수치 정렬 레이어 추가
#   * 헤더 라인 + 다음 라인을 합쳐 period 헤더 보강
#   * 숫자 토큰 개수와 헤더 개수 어긋남에 대비한 슬라이딩 윈도우 정렬(_align_numbers_to_periods)
#   * 너무 짧거나 과도하게 긴 라인 스킵 규칙
#   * metric별로 N개 수집되면 추가 라인 무시(중복 삽입 방지)
# - 나머지(세그먼트/재무상태표/현금흐름표) 로직/이름은 유지

import csv
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
BASE_DIR = Path(__file__).resolve().parent.parent
RAW_DIR = BASE_DIR / "data" / "raw"
DBG_DIR = RAW_DIR / "debug"
DBG_DIR.mkdir(parents=True, exist_ok=True)

logging.getLogger("pdfminer").setLevel(logging.ERROR)

# 각 보고서 파일별 재무상태표/현금흐름표 페이지 번호 지정
PAGE_OVERRIDES = {
    "2025_1Q_conference_kor": {"balance": 13, "cashflow": 14},
    "2025_2Q_conference_kor": {"balance": 13, "cashflow": 14},
}

# ────────────────────────────────────────────────────────────────────────────────
# 공통 유틸리티 함수
def remove_zero_width(s: str) -> str:
    """문자열에서 폭이 0인 유니코드 문자를 제거합니다."""
    return "".join(ch for ch in (s or "") if unicodedata.category(ch) != "Cf").replace("﻿", "")

def clean_spaces(s: str):
    """다양한 공백 문자를 표준 공백으로 변환하고 연속 공백을 하나로 합칩니다."""
    s = remove_zero_width(s)
    s = (s.replace("\u2009", " ").replace("\u202f", " ").replace("\xa0", " ").replace("／", "/"))
    return re.sub(r"[ \t]+", " ", s).strip()

def _parse_num_str(tok: Optional[str]) -> Optional[float]:
    """
    숫자 문자열을 파싱하여 float으로 변환합니다.
    괄호 음수, △, 유니코드 마이너스, 천단위 콤마, 꼬리 기호(%, ↑, ↓, p) 등 다양한 형식을 처리합니다.
    변환 실패 시 None을 반환합니다.
    """
    if tok is None:
        return None
    t = str(tok).strip()
    if not t:
        return None

    neg = False

    # 괄호 음수 처리: (123.4) -> -123.4
    if t.startswith("(") and t.endswith(")"):
        t = t[1:-1].strip()
        neg = True

    # 삼각형(△) 음수 처리
    if t.startswith("△"):
        t = t[1:].strip()
        neg = True

    # 다양한 마이너스/대시 기호 정규화
    t = t.replace("−", "-").replace("–", "-").replace("—", "-")

    # 백분율, 방향, 포인트 등 꼬리 기호 제거
    t = re.sub(r"[%p↑↓]+$", "", t, flags=re.IGNORECASE).strip()

    # 천단위 콤마 제거
    t = t.replace(",", "")

    if not t:
        return None

    try:
        v = float(t)
        return -v if neg else v
    except Exception:
        return None

def path_write_text(path: Path, text: str):
    """텍스트를 지정된 경로에 UTF-8 인코딩으로 저장합니다."""
    try:
        path.write_text(text, encoding="utf-8", errors="ignore")
    except Exception:
        pass

# ────────────────────────────────────────────────────────────────────────────────
# PDF 텍스트 추출 함수
def extract_page_text(pdf_path: Path, page_no_1idx: int) -> str:
    """pdfplumber를 사용하여 PDF의 특정 페이지에서 텍스트를 추출합니다."""
    with pdfplumber.open(pdf_path) as pdf:
        if page_no_1idx > len(pdf.pages): return ""
        page = pdf.pages[page_no_1idx - 1]
        return page.extract_text(x_tolerance=1, y_tolerance=1) or page.extract_text() or ""

# ────────────────────────────────────────────────────────────────────────────────
# 1. 전사 실적 파싱
# ────────────────────────────────────────────────────────────────────────────────
RE_REV_LABEL = re.compile(r"^(매\s*출(액)?(!\s*원가|\s*총))|Revenue", re.I)
RE_OP_LABEL = re.compile(r"(영\s*업\s*이\s*익|Operating\s*Profit|^OP$|\bOP\b)", re.I)
RE_GPROFIT = re.compile(r"(매\s*출\s*총\s*이\s*익|Gross\s*Profit)", re.I)
RE_OP_MARGINLN = re.compile(r"(영\s*업\s*이\s*익\s*률|이\s*익\s*률|마\s*진|op\s*margin|operating\s*margin|margin|ratio|rate|opm)", re.I)

def normalize_to_trillion(val: float, unit: str) -> float:
    """값을 '조원' 단위로 정규화합니다."""
    if unit == "tril": return val
    if unit == "ok": return val / 1e4
    return val

def is_reasonable_revenue(tril: float) -> bool: 
    """매출액 값이 합리적인 범위(50조 ~ 150조)에 있는지 확인합니다."""
    return 50 <= tril <= 150
def is_reasonable_op(tril: float) -> bool: 
    """영업이익 값이 합리적인 범위(0조 ~ 40조)에 있는지 확인합니다."""
    return 0 <= tril <= 40

# 숫자 토큰 정규식: 괄호, 삼각형, 유니코드 마이너스 등 다양한 음수 표현을 포괄합니다.
VAL_RE = re.compile(
    r"""
    (?: 
        \(\s*[-−–—]?\s*[\d,]+(?:\.\d+)?\s*\)   # (1,234.56) 형태 (괄호 음수)
        |
        △\s*[\d,]+(?:\.\d+)?                   # △1,234.56 형태 (삼각형 음수)
        |
        [-−–—]?\s*[\d,]+(?:\.\d+)?             # -1,234.56 또는 1,234.56
    )
    """,
    re.VERBOSE
)

def _align_numbers_to_periods(nums: List[float], periods: List[str], metric: str, dbg_id: str="") -> Optional[List[float]]:
    """
    추출된 숫자 리스트(nums)가 기간 헤더(periods) 개수와 맞지 않을 때, 최적의 숫자 조합을 찾습니다.
    슬라이딩 윈도우를 사용하여, 각 지표(매출/영업이익)의 합리적인 범위, 값의 분포 등을 고려한 점수 체계로 최적의 숫자 시퀀스를 선택합니다.
    """
    N = len(periods)
    if not nums or N == 0:
        return None
    if len(nums) == N:
        return nums
    if len(nums) < N:
        return None

    def ok(val: float) -> bool:
        """값이 해당 지표의 합리적인 범위 내에 있는지 확인합니다."""
        if metric == "revenue":
            return 50 <= val <= 150
        if metric == "op_profit":
            return 0 <= val <= 40
        return True

    best = (float("-inf"), None)
    dbg_rows = []

    # 슬라이딩 윈도우로 최적의 숫자 조합 탐색
    for start in range(0, len(nums) - N + 1):
        win = nums[start:start+N]
        # 점수 계산: 합리적 범위 내 값이 많을수록, 특정 값(0, 100)이 적을수록, 변동성이 적을수록 높은 점수 부여
        in_range = sum(1 for v in win if ok(v))
        tiny_penalty = sum(1 for v in win if abs(v) <= 5)
        hundred_penalty = sum(1 for v in win if abs(v - 100.0) < 0.01)
        large_penalty = sum(1 for v in win if metric=="op_profit" and v > 15.0)
        diffs = [abs(win[i+1]-win[i]) for i in range(len(win)-1)]
        smooth_penalty = sum(1 for d in diffs if d > 30)

        score = in_range*3 - tiny_penalty*2 - hundred_penalty*3 - large_penalty - smooth_penalty
        
        dbg_rows.append({ "metric": metric, "dbg_id": dbg_id, "start": start, "win": win, "score": score })

        if score > best[0]:
            best = (score, win)

    # 디버깅을 위해 점수 계산 과정을 CSV 파일로 저장
    try:
        out_path = DBG_DIR / f"align_debug_{metric}_{dbg_id}.csv"
        with open(out_path, "w", newline="", encoding="utf-8-sig") as f:
            writer = csv.DictWriter(f, fieldnames=dbg_rows[0].keys())
            writer.writeheader()
            writer.writerows(dbg_rows)
    except Exception as e:
        print("[HINT] debug csv write failed:", e)

    return best[1]


def extract_consolidated_table_wide(pdf_path: Path) -> List[Dict[str, Any]]:
    """PDF에서 '전사 손익' 테이블을 찾아 매출과 영업이익 데이터를 추출합니다. (2025년 형식 대응)"""
    results: List[Dict[str, Any]] = []
    
    def normalize_header_period(h: str) -> Optional[str]:
        """'1Q'25'와 같은 헤더를 '2025Q1' 형식으로 표준화합니다."""
        if not h: return None
        m = re.search(r"(?P<q>[1-4])\\s*Q\\s*'?(?P<y>\\d{2})", h)
        if m:
            return f"20{m.group('y')}Q{m.group('q')}"
        return None

    with contextlib.redirect_stderr(open(os.devnull, "w")):
        with pdfplumber.open(pdf_path) as pdf:
            collected = {"revenue": set(), "op_profit": set()}
            for page_num, page in enumerate(pdf.pages, 1):
                page_text = page.extract_text(x_tolerance=1.5) or ""
                if not any(k in page_text for k in ["전사 손익 분석", "전사 매출 및 손익 세부"]): 
                    continue

                lines = page_text.splitlines()
                period_headers, header_line_idx = [], -1

                # 1. 헤더 탐지: '1Q'25' 같은 패턴으로 기간 헤더를 찾습니다.
                for i, line in enumerate(lines):
                    q_strings = re.findall(r"[1-4]\\s*Q\\s*'?(?:\\d{2})", line)
                    if len(q_strings) >= 2:
                        period_headers = [p for p in (normalize_header_period(q) for q in q_strings) if p]
                        header_line_idx = i
                        break
                if not period_headers:
                    continue

                # 2. 헤더 보강: 헤더가 두 줄에 걸쳐 있을 수 있으므로 다음 라인도 확인하여 헤더를 보강합니다.
                if header_line_idx >= 0 and header_line_idx + 1 < len(lines):
                    more_q = re.findall(r"[1-4]\\s*Q\\s*'?(?:\\d{2})", lines[header_line_idx + 1])
                    extra = [p for p in (normalize_header_period(q) for q in more_q) if p]
                    seen = set(period_headers)
                    for p in extra:
                        if p not in seen:
                            period_headers.append(p)
                            seen.add(p)

                # 3. 데이터 라인 처리
                for line_num, line in enumerate(lines[header_line_idx + 1:]):
                    line = line.strip()
                    metric_name, is_reasonable_func = None, None
                    if RE_REV_LABEL.match(line) and not RE_GPROFIT.search(line):
                        metric_name, is_reasonable_func = "revenue", is_reasonable_revenue
                    elif RE_OP_LABEL.match(line) and not RE_OP_MARGINLN.search(line):
                        metric_name, is_reasonable_func = "op_profit", is_reasonable_op
                    if not metric_name or not is_reasonable_func: 
                        continue

                    if len(collected.get(metric_name, set())) >= len(period_headers):
                        continue

                    toks = VAL_RE.findall(line)
                    nums = [n for n in (_parse_num_str(s) for s in toks) if n is not None]

                    # 4. 교차 구조 처리: '수치'와 '비중(%)'이 번갈아 나오는 경우, 수치만 선택합니다.
                    if len(nums) == 2 * len(period_headers):
                        even = nums[::2] # 짝수 인덱스 (수치)
                        odd  = nums[1::2] # 홀수 인덱스 (비중)
                        # 수치와 비중이 각각 합리적인 범위에 있는지 확인
                        left_ok = sum(is_reasonable_revenue(v) if metric_name == "revenue" else is_reasonable_op(v) for v in even)
                        right_pctish = sum(0 <= v <= 100 for v in odd)
                        if left_ok >= len(period_headers) - 1 and right_pctish >= len(period_headers) - 1:
                            nums = even

                    if len(nums) < len(period_headers) - 1 or len(nums) > len(period_headers) * 2:
                        continue

                    # 5. 숫자-헤더 정렬: 숫자 개수와 헤더 개수가 다를 때 최적의 조합을 찾습니다.
                    aligned = _align_numbers_to_periods(nums, period_headers, metric_name, dbg_id=f"p{page_num}l{line_num}")
                    if not aligned:
                        continue

                    for i, period in enumerate(period_headers):
                        val_tril = normalize_to_trillion(aligned[i], "tril")
                        if is_reasonable_func(val_tril):
                            results.append({"period": period, "metric": metric_name, "value": val_tril})
                            collected[metric_name].add(period)

                if len(collected["revenue"]) >= len(period_headers) and len(collected["op_profit"]) >= len(period_headers):
                    break

    if not results: 
        return []
    # 중복 제거
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
            rows.append({'period': r['period'], 'metric': r['metric'], 'value_trillion': r['value'], 'source': "IR_PDF", 'explain': f"text_parser|period:{r['period']}"})
        return rows
    if not rows: 
        print(f"[WARN] Quarterly data not found in {pdf_path.name} using primary method.")
    return rows

# ────────────────────────────────────────────────────────────────────────────────
# 2. 부문별 실적 파싱 (v3: 계층 구조 인식)
# ────────────────────────────────────────────────────────────────────────────────

SEGMENT_TITLE_PAT = re.compile(r"사업부문별\\s*매출\\s*(?:및|과)\\s*영업이익")
SEGMENT_HEADER_Q_RE = re.compile(r"([1-4])\\s*Q\\s*'?(?:\\d{2}|\\d{4})", re.I)

SEG_KO_PATTERNS = [
    (r"^\\s*-\s*mx\\s*.*$", "MX", "Mobile eXperience", "Consumer&Mobile"),
    (r"^\\s*-\s*vd\\s*.*$", "VD", "Visual Display", "Consumer&Mobile"),
    (r"mx\\s*/\\s*네트워크", "MX_NW", "MX & Network", "Consumer&Mobile"),
    (r"mx.*network", "MX_NW", "MX & Network", "Consumer&Mobile"),
    (r"vd.*da", "VD_DA", "VD & DA", "Consumer&Mobile"),
    (r"vd.*가전", "VD_DA", "VD & Home Appliances", "Consumer&Mobile"),
    (r"^\\s*dx\\s*.*$", "DX", "Device eXperience", "Consumer&Mobile"),
    (r"^\\s*ce\\s*부문\\s*.*$", "CE", "Consumer Electronics", "Consumer&Mobile"),
    (r"^\\s*im\\s*부문\\s*.*$", "IM", "IT & Mobile communications", "Consumer&Mobile"),
    (r"^\\s*ds\\s*부문\\s*.*$", "DS", "Device Solutions", "Semiconductor"),
    (r"^(harman|하만)\\s*.*$",   "Harman", "Harman", "Harman"),
    (r"메모리|Memory", "Memory", "Memory", "Semiconductor"),
    (r"^\\s*network(s)?\\s*.*$", "Network", "Network", "Consumer&Mobile"),
    (r"^\\s*dp\\s*부문\\s*.*$", "DP", "Display Panel", "Display"),
    (r"\\bMX\\b", "MX", "Mobile eXperience", "Consumer&Mobile"),
    (r"\\bVD\\b", "VD", "Visual Display", "Consumer&Mobile"),
    (r"\\bSDC\\b", "SDC", "Samsung Display", "Display"),
    (r"^\\s*총(액|합|계)\\s*.*$", "Total", "Total", "Total")
]

def translate_segment_as_reported(s: str):
    """보고서의 세그먼트 이름을 표준 코드로 변환합니다."""
    raw = (s or "").strip()
    base = raw.lower().replace(" ", "")
    for pat, code, name_en, lineage in SEG_KO_PATTERNS:
        if re.search(pat, raw, flags=re.IGNORECASE) or re.search(pat, base, flags=re.IGNORECASE):
            return code, name_en, lineage
    return None, None, None

def score_segment_page(txt: str) -> int:
    """페이지가 부문별 실적 데이터일 가능성을 점수로 평가합니다."""
    T = clean_spaces(txt)
    sc = 0
    if SEGMENT_TITLE_PAT.search(T): sc += 8
    if ("사업부문" in T and ("매출" in T or "영업이익" in T)): sc += 5
    sc += 2 * len(SEGMENT_HEADER_Q_RE.findall(T))
    if any(k in T for k in ["별첨", "현금흐름", "순현금"]): sc -= 6
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
            if sc > best[0]: best = (sc, p1)
    return best[1]

def extract_half_text(page, left: bool) -> str:
    """페이지를 좌/우로 나누어 텍스트를 추출합니다."""
    w = float(page.width)
    h = float(page.height)
    bbox = (0, 0, w * 0.52, h) if left else (w * 0.48, 0, w, h)
    region = page.crop(bbox)
    txt = region.extract_text(x_tolerance=1, y_tolerance=1) or region.extract_text() or ""
    return clean_spaces(txt)

def parse_segment_header_periods(text: str) -> List[str]:
    """부문별 실적 헤더에서 기간 정보를 파싱합니다."""
    qs = SEGMENT_HEADER_Q_RE.findall(clean_spaces(text))
    periods = []
    for q, yy_str in qs:
        y = int(yy_str)
        year = y if y > 2000 else 2000 + y
        periods.append(f"{year}Q{q}")
    return periods

def parse_segments(pdf_path: Path) -> List[Dict]:
    """PDF에서 부문별 실적 데이터를 파싱합니다."""
    out: List[Dict] = []
    with pdfplumber.open(pdf_path) as pdf:
        best_pno = find_best_segment_page(pdf_path)
        if not best_pno: return out
        page = pdf.pages[best_pno - 1]

        rev_text = extract_half_text(page, left=True)
        op_text = extract_half_text(page, left=False)

        rev_periods = parse_segment_header_periods(rev_text)
        op_periods = parse_segment_header_periods(op_text)

        for metric, text_block, periods in [("revenue", rev_text, rev_periods), ("op_profit", op_text, op_periods)]:
            if not periods: continue
            for line in text_block.splitlines():
                line = line.strip()
                if not line: continue
                code, name_en, lineage = translate_segment_as_reported(line)
                if not code: continue
                nums = [n for n in (_parse_num_str(s) for s in VAL_RE.findall(line)) if n is not None]
                if not nums: continue

                for i, value in enumerate(nums):
                    if i < len(periods):
                        if metric == "op_profit" and value > 20.0: continue
                        out.append({
                            "period": periods[i],
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
# 3. 별첨 재무/현금흐름 파싱
# ────────────────────────────────────────────────────────────────────────────────
NUM_RE_C = r"(?:\\(\\s*[-−–—]?\\s*[\\d,]+(?:\\.\\d+)?\\s*\\)|△\\s*[\\d,]+(?:\\.\\d+)?|[-−–—]?\\s*[\\d,]+(?:\\.\\d+)?)"

def to_trillion_from_eok(tok: str) -> Optional[float]:
    """'억원' 단위를 '조원' 단위로 변환합니다."""
    v = _parse_num_str(tok)
    return v / 10000.0 if v is not None else None

def to_trillion_direct(tok: str) -> Optional[float]:
    """'조원' 단위 문자열을 float으로 변환합니다."""
    return _parse_num_str(tok)

def extract_numbers_from_line(line: str, converter) -> List[float]:
    """라인에서 숫자들을 추출하고 단위를 변환합니다."""
    num_and_maybe_percent_re = rf"({NUM_RE_C})\\s*(%|％)?"
    tokens = re.findall(num_and_maybe_percent_re, clean_spaces(line))
    numbers = []
    for num_str, percent in tokens:
        if not percent:
            val = converter(num_str)
            if val is not None: numbers.append(val)
    return numbers

def parse_annex_headers(text: str) -> List[str]:
    """별첨 자료의 헤더에서 기간 정보를 파싱합니다."""
    lines = text.splitlines()
    best_line_tokens = []
    header_patterns = [
        re.compile(r"'?(?P<y>\\d{2})\\s*\\.\\s*(?P<q>[1-4])Q"),
        re.compile(r"(?P<q>[1-4])Q\\s*말\\s*'?(?P<y>\\d{2})"),
        re.compile(r"(?P<q>[1-4])Q\\s*'?(?P<y>\\d{2})"),
        re.compile(r"'?(?P<y>\\d{2})\\s*년말?"),
        re.compile(r"\\b(?P<y>20\\d{2})\\b"),
    ]
    for line in lines[:8]:
        if len(re.findall(r'\\d', line)) > 15: continue
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
            periods.append(f"{year}Q{q_str}" if q_str else f"{year}Y")
    return periods

LAB_ASSETS = re.compile(r"(?<!\\w)자\\s*산\\s*계\\b", re.I)
LAB_LIABS = re.compile(r"(?<!\\w)부\\s*채\\b(?!.*자\\s*본\\s*계)", re.I)
LAB_EQU = re.compile(r"(?<!\\w)자\\s*본\\b(?!.*계)", re.I)
LAB_LIAEQT = re.compile(r"(?<!\\w)부\\s*채\\s*와\\s*자\\s*본\\s*계\\b", re.I)
BAL_BLACKLIST = re.compile(r"(매출채권|재고자산|투자자산|현금및현금성자산|유동자산|비유동자산|유동부채|비유동부채|유형자산|무형자산|이익잉여금)", re.I)

def parse_balance(pdf_path: Path) -> List[Dict]:
    """PDF에서 재무상태표 데이터를 파싱합니다."""
    pno = PAGE_OVERRIDES.get(pdf_path.stem, {}).get("balance")
    if not pno: return []
    text = extract_page_text(pdf_path, pno)
    periods = parse_annex_headers(text)
    if not periods: return []
    rows, lines = [], text.splitlines()
    got = {"assets": False, "liabilities": False, "equity": False}
    assets_search_regex = LAB_LIAEQT if LAB_LIAEQT.search(clean_spaces(text)) else LAB_ASSETS
    def process_metric(metric_name, search_regex, blacklist_regex):
        for ln in lines:
            s = clean_spaces(ln)
            if not search_regex: continue
            match = search_regex.search(s)
            if match and not blacklist_regex.search(s[:match.start()]):
                numbers = extract_numbers_from_line(s[match.end():], to_trillion_from_eok)
                if numbers:
                    for i, v in enumerate(numbers):
                        if i < len(periods): rows.append({"period": periods[i], "category": "balance", "metric": metric_name, "value": v, "unit": "조원", "source": "IR_PDF"})
                    got[metric_name] = True
                    return
    process_metric("assets", assets_search_regex, BAL_BLACKLIST)
    process_metric("liabilities", LAB_LIABS, BAL_BLACKLIST)
    process_metric("equity", LAB_EQU, BAL_BLACKLIST)
    return rows

CFS_LEFT_LABELS = {"cfo": [r"영업활동(?:으로\\s*인한)?\\s*현금흐름"], "cfi": [r"투자활동(?:으로\\s*인한)?\\s*현금흐름"], "cff": [r"재무활동(?:으로\\s*인한)?\\s*현금흐름"], "cash_begin": [r"기초\\s*현금"], "cash_end": [r"기말\\s*현금"], "cash_change": [r"현금\\s*증감"]}
RIGHT_NETCASH_TITLE = re.compile(r"순\\s*현금\\s*현황", re.I)

def parse_cashflow(pdf_path: Path) -> List[Dict]:
    """PDF에서 현금흐름표 데이터를 파싱합니다."""
    pno = PAGE_OVERRIDES.get(pdf_path.stem, {}).get("cashflow")
    if not pno: return []
    text = extract_page_text(pdf_path, pno)
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
                    for i, v in enumerate(numbers):
                        if i < len(periods): rows.append({"period": periods[i], "category": "cashflow", "metric": metric, "value": v, "unit": "조원", "source": "IR_PDF"})
                    if numbers: got[metric] = True
                    metric_found = True
                    break
            if metric_found: break
        if metric_found: continue
        if not got["net_cash"] and RIGHT_NETCASH_TITLE.search(text):
            if re.search(r"^순\\s*현금\\b", s, re.I):
                numbers = extract_numbers_from_line(s, to_trillion_direct)
                for i, v in enumerate(numbers):
                    if i < len(periods): rows.append({"period": periods[i], "category": "cashflow", "metric": "net_cash", "value": v, "unit": "조원", "source": "IR_PDF"})
                if numbers: got["net_cash"] = True
    return rows

# ────────────────────────────────────────────────────────────────────────────────
# Main Orchestrator
# ────────────────────────────────────────────────────────────────────────────────
def main():
    """메인 실행 함수. PDF 파일을 순회하며 모든 데이터를 파싱하고 CSV 파일로 저장합니다."""
    files_to_process = [RAW_DIR / f"2025_{i}Q_conference_kor.pdf" for i in range(1, 3)]
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

    if all_rows_quarter:
        df = pd.DataFrame(all_rows_quarter).drop_duplicates(subset=['period', 'metric'], keep='last').sort_values(by=['period', 'metric'])
        df.to_csv(RAW_DIR / "ir_quarter_2025.csv", index=False, encoding="utf-8")
        print(f"Saved: {RAW_DIR / 'ir_quarter_2025.csv'} (rows={len(df)})")

    if all_rows_segments:
        df = pd.DataFrame(all_rows_segments).drop_duplicates(subset=['period', 'segment_code', 'metric'], keep='last')
        df = df.sort_values(by=['period', 'segment_code', 'metric'])
        cols = ["period", "segment_code", "segment_name_en", "lineage_group", "metric", "value", "scope", "unit", "source"]
        df = df[cols]
        out_path = RAW_DIR / "ir_segments_2025.csv"
        df.to_csv(out_path, index=False, encoding="utf-8")
        print(f"Saved: {out_path} (rows={len(df)})")

    if all_rows_balance:
        df = pd.DataFrame(all_rows_balance).drop_duplicates(subset=['period', 'metric'], keep='last').sort_values(by=['period', 'metric'])
        df.to_csv(RAW_DIR / "ir_balance_2025.csv", index=False, encoding="utf-8")
        print(f"Saved: {RAW_DIR / 'ir_balance_2025.csv'} (rows={len(df)})")

    if all_rows_cashflow:
        df = pd.DataFrame(all_rows_cashflow).drop_duplicates(subset=['period', 'metric'], keep='last').sort_values(by=['period', 'metric'])
        df.to_csv(RAW_DIR / "ir_cashflow_2025.csv", index=False, encoding="utf-8")
        print(f"Saved: {RAW_DIR / 'ir_cashflow_2025.csv'} (rows={len(df)})")

if __name__ == "__main__":
    main()