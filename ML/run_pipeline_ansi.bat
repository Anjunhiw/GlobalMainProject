@echo off
REM =========================================================
REM  GMP_ML Pipeline Runner (ANSI) - with guidance (EN)
REM =========================================================
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
echo [INFO] Do not close this window. We will guide logs/outputs.
echo [INFO] Outputs will be saved under: "%REPORTS%"
echo ---------------------------------------------------------

REM --- Environment snapshot ---
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

REM --- Locate Python ---
set "PY_CMD="
py -3 --version >nul 2>&1 && set "PY_CMD=py -3"
if not defined PY_CMD (
  python --version >nul 2>&1 && set "PY_CMD=python"
)

if not defined PY_CMD (
  echo [INFO] Python 3.x not found on this machine.
  set /p CONFIRM="[Q] Install via winget now? (Y/N): "
  if /I not "%CONFIRM%"=="Y" (
    echo [FATAL] Python not installed. Exiting.
    pause & exit /b 1
  )

  echo [INFO] Trying to install Python 3 via winget...
  winget --version >nul 2>&1 || (
    echo [FATAL] winget unavailable. Open python.org instead.
    start "" https://www.python.org/downloads/windows/
    pause & exit /b 1
  )

  winget install -e --id Python.Python.3.13 --source winget --accept-package-agreements --accept-source-agreements
  if errorlevel 1 (
    echo [FATAL] winget installation failed.
    start "" https://www.python.org/downloads/windows/
    pause & exit /b 1
  )

  echo [INFO] Python installed. Please close this window and re-run batch in a NEW console so PATH is refreshed.
  pause & exit /b 0
)

for /f "tokens=*" %%V in ('%PY_CMD% --version') do set "PY_VER=%%V"
echo [OK] Python detected: %PY_CMD%  (%PY_VER%)

echo [STEP] Upgrading pip...
%PY_CMD% -m pip install --upgrade pip  1>>"%LOGS%\01_pip.log" 2>&1

if exist "%ROOT%requirements.txt" (
  echo [STEP] Installing requirements...
  %PY_CMD% -m pip install -r "%ROOT%requirements.txt"  1>>"%LOGS%\02_requirements.log" 2>&1
) else (
  echo [WARN] requirements.txt not found. Skipping.
)

echo ---------------------------------------------------------
echo [DATA] IN : data\raw and external sources (DART/Public/ERP)
echo [OUT ] OUT: reports\ (logs, figures, csv)
echo ---------------------------------------------------------

echo [Step 1] IR Parsing
%PY_CMD% "%SCRIPTS%\01_parse_ir_2020_final.py"   1>>"%LOGS%\01_ir_2020.log"  2>&1
%PY_CMD% "%SCRIPTS%\01_parse_ir_2022_final.py"   1>>"%LOGS%\01_ir_2022.log"  2>&1
%PY_CMD% "%SCRIPTS%\01_parse_ir_2024_final.py"   1>>"%LOGS%\01_ir_2024.log"  2>&1
%PY_CMD% "%SCRIPTS%\01_parse_ir_2025_final.py"   1>>"%LOGS%\01_ir_2025.log"  2>&1

echo [Step 2] External (DART/Public/ERP)
%PY_CMD% "%SCRIPTS%\02a_fetch_dart_final.py"             1>>"%LOGS%\02a_dart.log"     2>&1
%PY_CMD% "%SCRIPTS%\02b_fetch_odcloudkr_api_final.py"    1>>"%LOGS%\02b_public.log"   2>&1

echo [Step 3] Dataset Build
%PY_CMD% "%SCRIPTS%\03a_ir_dataset_final.py"         1>>"%LOGS%\03a_ir_dataset.log"    2>&1
%PY_CMD% "%SCRIPTS%\03b_build_ml_dataset_final.py"   1>>"%LOGS%\03b_build_ml.log"      2>&1

echo [Step 4] EDA
%PY_CMD% "%SCRIPTS%\04_eda_final.py"                 1>>"%LOGS%\04_eda.log"            2>&1

echo [Step 5] Train & Predict
%PY_CMD% "%SCRIPTS%\05a_train_baseline_final.py"     1>>"%LOGS%\05a_train.log"         2>&1
%PY_CMD% "%SCRIPTS%\05b_train_next_final.py"         1>>"%LOGS%\05b_predict.log"       2>&1

echo [Step 6] Visualization
%PY_CMD% "%SCRIPTS%\06_visualize_predictions_final.py"  1>>"%LOGS%\06_viz.log"        2>&1

echo ---------------------------------------------------------
echo [DONE] Pipeline completed.
echo [OPEN] Logs   : "%LOGS%"
echo [OPEN] Figures: "%FIGS%"
echo [OPEN] CSV    : "%REPORTS%\next_quarter_predictions.csv"
echo ---------------------------------------------------------
pause
endlocal
