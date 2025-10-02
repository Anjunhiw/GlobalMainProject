@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ===== Stable paths (ASCII only messages) =====
set "ROOT=%~dp0"
set "SCRIPTS=%ROOT%scripts"
set "REPORTS=%ROOT%reports"
set "LOGS=%REPORTS%\logs"
set "FIGS=%REPORTS%\figures"

if not exist "%REPORTS%" mkdir "%REPORTS%"
if not exist "%LOGS%"    mkdir "%LOGS%"
if not exist "%FIGS%"    mkdir "%FIGS%"

echo ===============================================
echo [GMP_ML] Pipeline runner (stable)
echo Root:     %ROOT%
echo Scripts:  %SCRIPTS%
echo Reports:  %REPORTS%
echo Logs:     %LOGS%
echo Figures:  %FIGS%
echo ===============================================

REM ===== Find Python safely =====
set "PY="
where python >nul 2>&1 && set "PY=python"
if not defined PY (
  where py >nul 2>&1 && set "PY=py -3"
)
if not defined PY (
  echo [WARN] Python was not found.
  echo        Please run "bootstrap_install_py.cmd" first or install Python 3.10+ manually.
  echo        Then re-open a NEW terminal and re-run this pipeline.
  pause
  goto :EOF
)

echo [INFO] Using: & %PY% --version

REM ===== Step 1: IR Parsing =====
echo [Step 1] IR Parsing ...
call %PY% "%SCRIPTS%\01_parse_ir_2020_final.py"  1>"%LOGS%\01_ir_2020.log"  2>&1
call %PY% "%SCRIPTS%\01_parse_ir_2022_final.py"  1>"%LOGS%\01_ir_2022.log"  2>&1
call %PY% "%SCRIPTS%\01_parse_ir_2024_final.py"  1>"%LOGS%\01_ir_2024.log"  2>&1
call %PY% "%SCRIPTS%\01_parse_ir_2025_final.py"  1>"%LOGS%\01_ir_2025.log"  2>&1

REM ===== Step 2: External (DART/Public/ERP) =====
echo [Step 2] External (DART/Public/ERP) ...
call %PY% "%SCRIPTS%\02a_fetch_dart_final.py"           1>"%LOGS%\02a_dart.log"    2>&1
call %PY% "%SCRIPTS%\02b_fetch_odcloudkr_api_final.py"  1>"%LOGS%\02b_public.log"  2>&1

REM ===== Step 3: Dataset Build =====
echo [Step 3] Dataset Build ...
call %PY% "%SCRIPTS%\01d_ir_dataset_final.py"           1>"%LOGS%\03_01d.log"     2>&1
call %PY% "%SCRIPTS%\03_build_ml_dataset_final.py"      1>"%LOGS%\03_build.log"   2>&1

REM ===== Step 4: EDA =====
echo [Step 4] EDA ...
call %PY% "%SCRIPTS%\04_eda_final.py"                   1>"%LOGS%\04_eda.log"     2>&1

REM ===== Step 5: Train & Predict =====
echo [Step 5] Train & Predict ...
call %PY% "%SCRIPTS%\05a_train_baseline_final.py"       1>"%LOGS%\05a_train.log"  2>&1
call %PY% "%SCRIPTS%\05b_train_next_final.py"           1>"%LOGS%\05b_predict.log" 2>&1

REM ===== Step 6: Visualization =====
echo [Step 6] Visualization ...
call %PY% "%SCRIPTS%\06_visualize_predictions_final.py" 1>"%LOGS%\06_viz.log"     2>&1

echo.
echo ========= Pipeline finished =========
echo Where to check:
echo  - Logs:    "%LOGS%"
echo  - Figures: "%FIGS%" (PNG charts)
echo  - Reports: "%REPORTS%\next_quarter_predictions.csv"
echo.
echo If charts/CSV are missing, open the latest *.log and check errors.
echo (TIP) Open a terminal here and run:  type "%LOGS%\05b_predict.log"
echo ===============================================
pause
endlocal
