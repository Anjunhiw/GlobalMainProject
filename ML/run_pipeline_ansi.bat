@echo off
setlocal ENABLEDELAYEDEXPANSION

:: ================== [GMP_ML] Pipeline runner ==================
set "ROOT=%~dp0"
set "PY=python"
set "SCRIPTS=%ROOT%scripts"
set "REPORTS=%ROOT%reports"
set "LOGS=%REPORTS%\logs"
set "FIGS=%REPORTS%\figures"

if not exist "%REPORTS%" mkdir "%REPORTS%"
if not exist "%LOGS%"    mkdir "%LOGS%"
if not exist "%FIGS%"    mkdir "%FIGS%"

echo ============================================================
echo [GMP_ML] Pipeline runner
echo Root:    %ROOT%
echo Scripts: %SCRIPTS%
echo Reports: %REPORTS%
echo Logs:    %LOGS%
echo Figures: %FIGS%
echo ============================================================

:: -------- Python/requirements 사전 점검 --------
where %PY% >nul 2>&1
if errorlevel 1 (
  echo [ERROR] "python" 실행 파일을 찾을 수 없습니다.
  echo - https://www.python.org/ 에서 Python 3.x 를 설치하고 다시 실행하세요.
  goto :END
)

echo [Step 0] Ensure pip & requirements ...
%PY% -m pip --version  1>>"%LOGS%\00_pip_upgrade.log" 2>&1
%PY% -m pip install --upgrade pip  1>>"%LOGS%\00_pip_upgrade.log" 2>&1
if exist "%ROOT%requirements.txt" (
  %PY% -m pip install -r "%ROOT%requirements.txt"  1>>"%LOGS%\00_requirements.log" 2>&1
) else (
  echo [WARN] requirements.txt not found at %ROOT%
)

:: ---------------- IR Parsing ----------------
echo [Step 1] IR Parsing ...
%PY% "%SCRIPTS%\01_parse_ir_2020_final.py"  1>>"%LOGS%\01_ir_2020.log"  2>&1
%PY% "%SCRIPTS%\01_parse_ir_2022_final.py"  1>>"%LOGS%\01_ir_2022.log"  2>&1
%PY% "%SCRIPTS%\01_parse_ir_2024_final.py"  1>>"%LOGS%\01_ir_2024.log"  2>&1
%PY% "%SCRIPTS%\01_parse_ir_2025_final.py"  1>>"%LOGS%\01_ir_2025.log"  2>&1

:: ---------------- External ------------------
echo [Step 2] External (DART/Public/ERP) ...
%PY% "%SCRIPTS%\02a_fetch_dart_final.py"           1>>"%LOGS%\02a_dart.log"   2>&1
%PY% "%SCRIPTS%\02b_fetch_odcloudkr_api_final.py"  1>>"%LOGS%\02b_public.log" 2>&1

:: ---------------- Dataset Build --------------
echo [Step 3] Dataset Build ...
%PY% "%SCRIPTS%\03a_ir_dataset_final.py"      1>>"%LOGS%\03a_ird.log"   2>&1
%PY% "%SCRIPTS%\03b_build_ml_dataset_final.py" 1>>"%LOGS%\03b_build.log" 2>&1

:: ---------------- EDA -----------------------
echo [Step 4] EDA ...
%PY% "%SCRIPTS%\04_eda_final.py"              1>>"%LOGS%\04_eda.log"   2>&1

:: ---------------- Train & Predict -----------
echo [Step 5] Train & Predict ...
%PY% "%SCRIPTS%\05a_train_baseline_final.py"  1>>"%LOGS%\05a_train.log"   2>&1
%PY% "%SCRIPTS%\05b_train_next_final.py"      1>>"%LOGS%\05b_predict.log" 2>&1

:: ---------------- Visualization -------------
echo [Step 6] Visualization ...
%PY% "%SCRIPTS%\06_visualize_predictions_final.py"  1>>"%LOGS%\06_viz.log" 2>&1

echo.
echo ========= Pipeline finished =========
echo 로그와 산출물은 다음 위치를 확인하세요:
echo  - Logs:    "%LOGS%"
echo  - Figures: "%FIGS%"   (PNG charts)
echo  - Reports: "%REPORTS%\next_quarter_predictions.csv"
echo.
pause
endlocal
