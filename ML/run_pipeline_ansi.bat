@echo off
setlocal ENABLEDELAYEDEXPANSION

rem ================== BASIC PATHS ==================
set "ROOT=%~dp0"
set "SCRIPTS=%ROOT%scripts"
set "REPORTS=%ROOT%reports"
set "LOGS=%REPORTS%\logs"
set "FIGS=%REPORTS%\figures"

if not exist "%REPORTS%" mkdir "%REPORTS%"
if not exist "%LOGS%"    mkdir "%LOGS%"
if not exist "%FIGS%"    mkdir "%FIGS%"

echo ================================================
echo [GMP_ML] Pipeline runner (stable)
echo Root:     %ROOT%
echo Scripts:  %SCRIPTS%
echo Reports:  %REPORTS%
echo Logs:     %LOGS%
echo Figures:  %FIGS%
echo ================================================
echo.

rem ================== PYTHON CHECK ==================
set "PY="
call :detect_python
if not defined PY (
  echo [INFO] Python 3.x is not available on this machine.
  set /p _ans=Install Python now via winget? [Y/N]: 
  if /I "!_ans!"=="Y" (
    call :install_python_via_winget || goto :fatal
    call :detect_python
  ) else (
    echo [FATAL] Python required. Aborting.
    goto :eof
  )
)

echo [INFO] Using:
"%PY%" --version
for /f "usebackq tokens=*" %%P in (`"%PY%" -c "import sys;print(sys.executable)"`) do set "PY_EXE=%%P"
echo Python exe: %PY_EXE%
echo.

rem ================== PIP / REQUIREMENTS ==================
echo [Step 0] Ensure pip ^& requirements ...
"%PY%" -m ensurepip --upgrade >nul 2>&1
"%PY%" -m pip install --upgrade pip > "%LOGS%\00_pip_upgrade.log" 2>&1
if exist "%ROOT%requirements.txt" (
  "%PY%" -m pip install --disable-pip-version-check --no-input -r "%ROOT%requirements.txt" 1>>"%LOGS%\00_requirements.log" 2>&1
) else (
  echo [WARN] requirements.txt not found at %ROOT%
)

rem ================== RUN STEPS ==================
echo [Step 1] IR Parsing ...
call :run "%SCRIPTS%\01_parse_ir_2020_final.py"  "%LOGS%\01_ir_2020.log"
call :run "%SCRIPTS%\01_parse_ir_2022_final.py"  "%LOGS%\01_ir_2022.log"
call :run "%SCRIPTS%\01_parse_ir_2024_final.py"  "%LOGS%\01_ir_2024.log"
call :run "%SCRIPTS%\01_parse_ir_2025_final.py"  "%LOGS%\01_ir_2025.log"

echo [Step 2] External (DART/Public/ERP) ...
call :run "%SCRIPTS%\02a_fetch_dart_final.py"         "%LOGS%\02a_dart.log"
call :run "%SCRIPTS%\02b_fetch_odcloudkr_api_final.py" "%LOGS%\02b_public.log"

echo [Step 3] Dataset Build ...
call :run "%SCRIPTS%\03a_ir_dataset_final.py"         "%LOGS%\03a_ird.log"
call :run "%SCRIPTS%\03b_build_ml_dataset_final.py"   "%LOGS%\03b_build.log"

echo [Step 4] EDA ...
call :run "%SCRIPTS%\04_eda_final.py"                 "%LOGS%\04_eda.log"

echo [Step 5] Train ^& Predict ...
call :run "%SCRIPTS%\05a_train_baseline_final.py"     "%LOGS%\05a_train.log"
call :run "%SCRIPTS%\05b_train_next_final.py"         "%LOGS%\05b_predict.log"

echo [Step 6] Visualization ...
call :run "%SCRIPTS%\06_visualize_predictions_final.py" "%LOGS%\06_viz.log"

rem ================== SUMMARY ==================
echo.
echo ========= Pipeline finished =========
echo Where to check:
echo   - Logs:    "%LOGS%"
echo   - Figures: "%FIGS%"  (PNG charts)
echo   - Reports: "%REPORTS%\next_quarter_predictions.csv"
echo If charts/CSV are missing, open the latest *.log and check errors.
echo (TIP) Open a terminal here and run:
echo   type "%LOGS%\05b_predict.log"
echo =====================================
echo.
pause
goto :eof

rem -------- SUBROUTINES --------
:run
set "SCRIPT=%~1"
set "LOG=%~2"
if not exist "%SCRIPT%" (
  echo [WARN] Missing script: %SCRIPT%
  goto :eof
)
echo   >nul Running %~nx1
"%PY%" "%SCRIPT%"  1>>"%LOG%" 2>&1
if errorlevel 1 (
  echo [ERR ] Failed: %~nx1  (see %LOG%)
) else (
  echo [ OK ] %~nx1
)
goto :eof

:detect_python
rem Prefer py -3 if available, else python
for /f "tokens=1,*" %%A in ('where py 2^>nul') do (
  py -3 --version >nul 2>&1 && (set "PY=py -3" & goto :eof)
)
for /f "tokens=1,*" %%A in ('where python 2^>nul') do (
  python --version >nul 2>&1 && (set "PY=python" & goto :eof)
)
goto :eof

:install_python_via_winget
where winget >nul 2>&1 || (echo [FATAL] winget not found. Install Python manually. & exit /b 1)
echo Installing Python via winget...
winget install -e --id Python.Python.3.13 --source winget --accept-package-agreements --accept-source-agreements
exit /b %ERRORLEVEL%

:fatal
echo [FATAL] Aborting.
exit /b 1
