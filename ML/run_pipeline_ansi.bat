@echo off
setlocal ENABLEDELAYEDEXPANSION
title GMP_ML Pipeline Runner (ANSI/EN)

echo ------------------------------------------------------------
echo [GMP_ML] Starting pipeline...
echo Do not close this window. We will guide logs and outputs.
echo ------------------------------------------------------------

REM ===== Paths =====
set "ROOT=%~dp0"
set "SCRIPTS=%ROOT%scripts"
set "REPORTS=%ROOT%reports"
set "FIGDIR=%REPORTS%\figures"
set "LOGDIR=%REPORTS%\logs"
set "DATADIR=%ROOT%data"
if not exist "%REPORTS%" mkdir "%REPORTS%"
if not exist "%FIGDIR%"   mkdir "%FIGDIR%"
if not exist "%LOGDIR%"   mkdir "%LOGDIR%"
if not exist "%DATADIR%"  mkdir "%DATADIR%"

REM ===== Python runtime: detect + validate + (optionally) install =====
set "PY="

for /f "delims=" %%P in ('where py 2^>nul')      do set "PY=py -3"
if not defined PY for /f "delims=" %%P in ('where python 2^>nul')  do set "PY=python"
if not defined PY for /f "delims=" %%P in ('where python3 2^>nul') do set "PY=python3"

call :_validate_py
if "%ERRORLEVEL%"=="0" goto :_py_ready

echo [INFO] Python 3.x is not available on this machine.
set /p _YN=Install Python now via winget? [Y/N]: 
if /i "!_YN!" NEQ "Y" (
  echo [ABORT] User canceled installation. Exiting.
  pause & exit /b 1
)

where winget >nul 2>&1
if errorlevel 1 (
  echo [WARN] winget not found. Opening python.org download page...
  start "" "https://www.python.org/downloads/windows/"
  echo Press any key after finishing installation...
  pause >nul
) else (
  echo [INFO] Installing Python via winget...
  winget install -e --id Python.Python.3.13 -h
  if errorlevel 1 (
    echo [WARN] winget installation failed. Opening python.org page...
    start "" "https://www.python.org/downloads/windows/"
    echo Press any key after finishing installation...
    pause >nul
  )
)

set "PY="
for /f "delims=" %%P in ('where py 2^>nul')      do set "PY=py -3"
if not defined PY for /f "delims=" %%P in ('where python 2^>nul')  do set "PY=python"
if not defined PY for /f "delims=" %%P in ('where python3 2^>nul') do set "PY=python3"
call :_validate_py
if not "%ERRORLEVEL%"=="0" (
  echo [FATAL] Python still not found. Please install and re-run.
  pause & exit /b 1
)

:_py_ready
echo [OK] Python detected: %PY%
echo.

REM ===== requirements =====
if exist "%ROOT%requirements.txt" (
  echo [Step 0] Checking/Installing dependencies (requirements.txt)
  "%PY%" -m pip install --upgrade pip >nul 2>&1
  "%PY%" -m pip install -r "%ROOT%requirements.txt"
  if errorlevel 1 (
    echo [WARN] Some packages failed to install. See logs.
  )
  echo.
)

REM ===== Pipeline =====
echo [Step 1] IR Parsing
"%PY%" "%SCRIPTS%\01_parse_ir_2020_final.py"  1>>"%LOGDIR%\01_ir_2020.log"  2>&1
"%PY%" "%SCRIPTS%\01_parse_ir_2022_final.py"  1>>"%LOGDIR%\01_ir_2022.log"  2>&1
"%PY%" "%SCRIPTS%\01_parse_ir_2024_final.py"  1>>"%LOGDIR%\01_ir_2024.log"  2>&1
"%PY%" "%SCRIPTS%\01_parse_ir_2025_final.py"  1>>"%LOGDIR%\01_ir_2025.log"  2>&1

echo [Step 2] External (DART/Public/ERP)
"%PY%" "%SCRIPTS%\02a_fetch_dart_final.py"           1>>"%LOGDIR%\02a_dart.log"    2>&1
"%PY%" "%SCRIPTS%\02b_fetch_odcloudkr_api_final.py"  1>>"%LOGDIR%\02b_public.log"  2>&1

echo [Step 3] Dataset Build
"%PY%" "%SCRIPTS%\01d_ir_dataset_final.py"        1>>"%LOGDIR%\03_01d.log"    2>&1
"%PY%" "%SCRIPTS%\03b_build_ml_dataset_final.py"  1>>"%LOGDIR%\03_build.log"  2>&1

echo [Step 4] EDA
"%PY%" "%SCRIPTS%\04_eda_final.py"  1>>"%LOGDIR%\04_eda.log"  2>&1

echo [Step 5] Train & Predict
"%PY%" "%SCRIPTS%\05a_train_baseline_final.py"  1>>"%LOGDIR%\05a_train.log"   2>&1
"%PY%" "%SCRIPTS%\05b_train_next_final.py"     1>>"%LOGDIR%\05b_predict.log" 2>&1

echo [Step 6] Visualization
"%PY%" "%SCRIPTS%\06_visualize_predictions_final.py"  1>>"%LOGDIR%\06_viz.log" 2>&1

echo.
echo ------------------------------------------------------------
echo [DONE] Pipeline finished.
echo [Where to check]
echo   - Logs:     "%LOGDIR%"
echo   - Figures:  "%FIGDIR%"
echo   - Pred CSV: "%REPORTS%\next_quarter_predictions.csv"
echo   - ML DS:    "%ROOT%\data\ml_dataset_*.csv"
echo ------------------------------------------------------------
pause
endlocal
exit /b 0


:_validate_py
if not defined PY ( exit /b 1 )
echo %PY% | find /i "py -3" >nul
if not errorlevel 1 (
  for /f "delims=" %%L in ('py -0p 2^>nul') do (
    echo %%L | findstr /r /c:"\\python3" >nul && (
      py -3 --version >nul 2>&1 && exit /b 0
    )
  )
  exit /b 1
) else (
  %PY% --version >nul 2>&1 && exit /b 0
  exit /b 1
)
