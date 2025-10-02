﻿@echo off
REM =========================================================
REM  GMP_ML Pipeline Runner (UTF-8, BOM) - with guidance
REM =========================================================
chcp 65001 >nul
title [GMP_ML] Starting pipeline...

setlocal ENABLEDELAYEDEXECUTION
set "ROOT=%~dp0"
set "SCRIPTS=%ROOT%scripts"
set "REPORTS=%ROOT%reports"
set "LOGS=%REPORTS%\logs"
set "FIGS=%REPORTS%\figures"

if not exist "%REPORTS%" mkdir "%REPORTS%"
if not exist "%LOGS%" mkdir "%LOGS%"
if not exist "%FIGS%" mkdir "%FIGS%"

echo ---------------------------------------------------------
echo [INFO] 본 창을 닫지 마세요. 진행상황/로그를 안내합니다.
echo [INFO] 결과물은 "%REPORTS%" 아래에 저장됩니다.
echo ---------------------------------------------------------

REM ---------- 환경 스냅샷 ----------
(
  echo ==== ENV SNAPSHOT ====
  date /t & time /t
  ver
  echo.
  echo [PATH]
  echo %PATH%
  echo.
  echo [where python]
  where python
  echo.
  echo [where py]
  where py
) > "%LOGS%\00_env.txt" 2>&1

REM ---------- Python 탐색 ----------
set "PY_CMD="
REM 우선 py -3 우선 사용
py -3 --version >nul 2>&1 && set "PY_CMD=py -3"
if not defined PY_CMD (
  python --version >nul 2>&1 && set "PY_CMD=python"
)

if not defined PY_CMD (
  echo [INFO] 이 PC에는 Python 3.x 가 없습니다.
  set /p CONFIRM="[Q] winget 으로 지금 설치할까요? (Y/N): "
  if /I not "%CONFIRM%"=="Y" (
    echo [FATAL] Python 미설치 상태로 종료합니다.
    pause & exit /b 1
  )

  echo [INFO] winget 으로 Python 3 설치를 시도합니다...
  winget --version >nul 2>&1 || (
    echo [FATAL] winget 이 사용 불가합니다. 수동 설치가 필요합니다.
    start "" https://www.python.org/downloads/windows/
    pause & exit /b 1
  )

  winget install -e --id Python.Python.3.13 --source winget --accept-package-agreements --accept-source-agreements
  if errorlevel 1 (
    echo [FATAL] winget 설치 중 오류가 발생했습니다.
    start "" https://www.python.org/downloads/windows/
    pause & exit /b 1
  )

  REM 새 PATH 반영을 위해 셸 재시작 유도
  echo [INFO] Python 설치가 완료되었습니다. 새 콘솔에서 다시 실행해주세요.
  echo [HINT] 현재 창을 닫고 배치 파일을 다시 더블클릭하세요.
  pause & exit /b 0
)

REM ---------- Python 버전 출력 ----------
for /f "tokens=*" %%V in ('%PY_CMD% --version') do set "PY_VER=%%V"
echo [OK] Python detected: %PY_CMD%  (%PY_VER%)

REM ---------- pip 최신화 및 의존성 설치 ----------
echo [STEP] pip 업데이트 중...
%PY_CMD% -m pip install --upgrade pip  1>>"%LOGS%\01_pip.log" 2>&1

if exist "%ROOT%requirements.txt" (
  echo [STEP] requirements.txt 의존성 설치/확인 중...
  %PY_CMD% -m pip install -r "%ROOT%requirements.txt"  1>>"%LOGS%\02_requirements.log" 2>&1
) else (
  echo [WARN] requirements.txt 를 찾지 못했습니다. (건너뜀)
)

REM ---------- 공통 안내 ----------
echo ---------------------------------------------------------
echo [DATA] 입력:   data\raw 및 외부 소스(DART/Public/ERP)
echo [OUT ] 출력:   reports\  (logs, figures, csv 등)
echo ---------------------------------------------------------

REM ---------- STEP 1 : IR Parsing ----------
echo [Step 1] IR Parsing
%PY_CMD% "%SCRIPTS%\01_parse_ir_2020_final.py"   1>>"%LOGS%\01_ir_2020.log"  2>&1
%PY_CMD% "%SCRIPTS%\01_parse_ir_2022_final.py"   1>>"%LOGS%\01_ir_2022.log"  2>&1
%PY_CMD% "%SCRIPTS%\01_parse_ir_2024_final.py"   1>>"%LOGS%\01_ir_2024.log"  2>&1
%PY_CMD% "%SCRIPTS%\01_parse_ir_2025_final.py"   1>>"%LOGS%\01_ir_2025.log"  2>&1

REM ---------- STEP 2 : External ----------
echo [Step 2] External (DART/Public/ERP)
%PY_CMD% "%SCRIPTS%\02a_fetch_dart_final.py"             1>>"%LOGS%\02a_dart.log"     2>&1
%PY_CMD% "%SCRIPTS%\02b_fetch_odcloudkr_api_final.py"    1>>"%LOGS%\02b_public.log"   2>&1
REM (ERP 연동 스크립트가 있다면 여기에 추가)

REM ---------- STEP 3 : Dataset Build ----------
echo [Step 3] Dataset Build
%PY_CMD% "%SCRIPTS%\03a_ir_dataset_final.py"         1>>"%LOGS%\03a_ir_dataset.log"    2>&1
%PY_CMD% "%SCRIPTS%\03b_build_ml_dataset_final.py"   1>>"%LOGS%\03b_build_ml.log"      2>&1

REM ---------- STEP 4 : EDA ----------
echo [Step 4] EDA
%PY_CMD% "%SCRIPTS%\04_eda_final.py"                 1>>"%LOGS%\04_eda.log"            2>&1

REM ---------- STEP 5 : Train & Predict ----------
echo [Step 5] Train & Predict
%PY_CMD% "%SCRIPTS%\05a_train_baseline_final.py"     1>>"%LOGS%\05a_train.log"         2>&1
%PY_CMD% "%SCRIPTS%\05b_train_next_final.py"         1>>"%LOGS%\05b_predict.log"       2>&1

REM ---------- STEP 6 : Visualization ----------
echo [Step 6] Visualization
%PY_CMD% "%SCRIPTS%\06_visualize_predictions_final.py"  1>>"%LOGS%\06_viz.log"        2>&1

echo ---------------------------------------------------------
echo [DONE] 파이프라인 완료.
echo [OPEN] 로그:    "%LOGS%"
echo [OPEN] 그림:    "%FIGS%"
echo [OPEN] 예측CSV: "%REPORTS%\next_quarter_predictions.csv"
echo ---------------------------------------------------------
pause
endlocal
