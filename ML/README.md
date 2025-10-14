# ERP 프로젝트 머신 러닝 파싱

IR·DART·공공데이터포털 기반 기업 실적 데이터 전처리 및 ML 데이터셋 구축

## 프로젝트 개요

본 프로젝트는 **삼성전자 IR PDF, DART API, 공공데이터포털(ODcloud)** 등  
여러 출처의 재무 및 산업 데이터를 통합하여  
**시계열 기반 예측 모델 학습용 데이터셋**을 구축하는 것을 목표로 한다.

## 디렉토리 구조

ML/
├─ data/
│ ├─ raw/ # 원본 데이터 (PDF, API, CSV)
│ ├─ processed/ # 전처리된 중간 데이터
│ ├─ final/ # 모델 입력용 데이터셋 (Wide/Long)
├─ scripts/
│ ├─ 01_parse_ir_2025.py # IR PDF 파싱
│ ├─ 02a_fetch_dart.py # DART API 수집
│ ├─ 02b_fetch_odcloudkr_api.py # 공공데이터 수집
│ ├─ 03_build_ml_dataset.py # 병합 및 데이터셋 구축
│ ├─ 04_eda.py # 탐색적 데이터 분석
│ ├─ 05a_train_baseline.py # 기본 회귀 모델 학습
│ └─ 05b_train_next.py # 다음 분기 예측 모델 학습
├─ models/
├─ reports/
│ ├─ figures/
│ └─ logs/
└─ README.md

## 주요 기능 및 스크립트 요약

| 스크립트                       | 기능                                                                 |
| ------------------------------ | -------------------------------------------------------------------- |
| **01_parse_ir_2025.py**        | 2024~2025년 IR PDF에서 전사/부문별 실적, 재무/현금흐름표 데이터 추출 |
| **02a_fetch_dart.py**          | DART Open API를 활용하여 분기별 재무제표 단일계정 데이터 수집        |
| **02b_fetch_odcloudkr_api.py** | ODcloud API로 산업지표(출하지수, 반도체/디스플레이 등) 수집          |
| **03_build_ml_dataset.py**     | IR·DART·ODcloud 데이터를 병합하여 ML 학습용 Wide/Long 데이터 생성    |
| **04_eda.py**                  | 결측치, 상관관계, 시계열 추세를 시각화하고 변수 간 관계 탐색         |
| **05a_train_baseline.py**      | 기본 회귀 모델 학습 및 피처 유효성 검증                              |
| **05b_train_next.py**          | 다음 분기 실적 예측 모델 학습 (revenue, op_profit 등)                |
