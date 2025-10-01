@echo off
setlocal enableextensions

rem ============================================================
rem  GMP_ML Pipeline Runner - robust Python bootstrap for Windows
rem  Save as ANSI (recommended). For UTF-8 + Korean, add: chcp 65001 >nul
rem ============================================================

title GMP_ML Pipeline Runner
echo [GMP_ML] Starting pipeline bootstrap...
echo Do not close this window. We will guide logs and outputs.
echo ------------------------------------------------------------

rem ---- folders ----
set "ROOT=%~dp0"
set "SCRIPTS=%ROOT%scripts"
set "REPORTS=%ROOT%reports"
if not exist "%REPORTS%" mkdir "%REPORTS%" >nul 2>&1
if not exist "%REPORTS%\logs" mkdir "%REPORTS%\logs" >nul 2>&1
if not exist "%REPORTS%\figures" mkdir "%REPORTS%\figures" >nul 2>&1

rem ---- detect Python (function call sets PY_EXE) ----
call :detect_python

if not defined PY_EXE (
  echo [INFO] Python 3.x is not available on this machine.
  set "ANS=Y"
  set /p ANS=Install Python now via winget? [Y/N]: 
  if /i "%ANS%"=="Y" (
    echo.
    echo [INFO] Installing Python via winget...
    echo      (If prompted, accept Microsoft Store/winget agreements.)
    winget install --id Python.Python.3.13 ^
      --silent --accept-package-agreements --accept-source-agreements
    rem try re-detect immediately (without opening a new console)
    call :detect_python

    if not defined PY_EXE (
      rem try WindowsApps alias
      if exist "%LocalAppData%\Microsoft\WindowsApps\python.exe" (
        set "PY_EXE=%LocalAppData%\Microsoft\WindowsApps\python.exe"
      )
    )
  ) else (
    echo [FATAL] Python not installed. Exiting.
    goto :end_fail
  )
)

if not defined PY_EXE (
  echo.
  echo [FATAL] Python still not found. Please check:
  echo   1) Settings > Apps > App execution aliases:
  echo      Turn ON "python.exe" and "python3.exe".
  echo   2) Re-open this .bat as Administrator.
  echo   3) Or install from https://www.python.org/downloads/windows/
  echo.
  pause
  goto :end_fail
)

echo [OK] Using Python: %PY_EXE%
for /f "usebackq delims=" %%V in (`"%PY_EXE%" -c "import sys;print(sys.version)"`) do set "PY_VER=%%V"
echo [OK] Python version: %PY_VER%

rem ---- ensure pip & install requirements (session only if needed) ----
echo.
echo [STEP] Ensuring pip and required packages...
"%PY_EXE%" -m ensurepip --upgrade >nul 2>&1
"%PY_EXE%" -m pip install --upgrade pip >nul 2>&1

set "REQ=%ROOT%requirements.txt"
if exist "%REQ%" (
  echo [INFO] Installing from requirements.txt ...
  "%PY_EXE%" -m pip install -r "%REQ%"
) else (
  echo [WARN] requirements.txt not found. Skipping dependency install.
)

rem ---- run whole pipeline (your latest final scripts) ----
echo.
echo [STEP] Running pipeline...
echo   Logs    : %REPORTS%\logs
echo   Figures : %REPORTS%\figures
echo   Reports : %REPORTS%
echo ------------------------------------------------------------

call :runit "[Step 1] IR Parsing"        "%PY_EXE%" "%SCRIPTS%\01_parse_ir_2020_final.py"   "%REPORTS%\logs\01_ir_2020.log"
call :runit ""                           "%PY_EXE%" "%SCRIPTS%\01_parse_ir_2022_final.py"   "%REPORTS%\logs\01_ir_2022.log"
call :runit ""                           "%PY_EXE%" "%SCRIPTS%\01_parse_ir_2024_final.py"   "%REPORTS%\logs\01_ir_2024.log"
call :runit ""                           "%PY_EXE%" "%SCRIPTS%\01_parse_ir_2025_final.py"   "%REPORTS%\logs\01_ir_2025.log"

call :runit "[Step 2] External (DART/Public/ERP)" "%PY_EXE%" "%SCRIPTS%\02a_fetch_dart_final.py"         "%REPORTS%\logs\02a_dart.log"
call :runit ""                                     "%PY_EXE%" "%SCRIPTS%\02b_fetch_odcloudkr_api_final.py" "%REPORTS%\logs\02b_public.log"

call :runit "[Step 3] Dataset Build"    "%PY_EXE%" "%SCRIPTS%\03a_ir_dataset_final.py"      "%REPORTS%\logs\03_01d.log"
call :runit ""                           "%PY_EXE%" "%SCRIPTS%\03b_build_ml_dataset_final.py" "%REPORTS%\logs\03_build.log"

call :runit "[Step 4] EDA"              "%PY_EXE%" "%SCRIPTS%\04_eda_final.py"              "%REPORTS%\logs\04_eda.log"

call :runit "[Step 5] Train & Predict"  "%PY_EXE%" "%SCRIPTS%\05a_train_baseline_final.py"  "%REPORTS%\logs\05a_train.log"
call :runit ""                           "%PY_EXE%" "%SCRIPTS%\05b_train_next_final.py"      "%REPORTS%\logs\05b_predict.log"

call :runit "[Step 6] Visualization"    "%PY_EXE%" "%SCRIPTS%\06_visualize_predictions_final.py" "%REPORTS%\logs\06_viz.log"

echo.
echo ===================== SUMMARY =====================
echo Logs:
echo   %REPORTS%\logs\01_ir_*.log
echo   %REPORTS%\logs\02*.log
echo   %REPORTS%\logs\03*.log
echo   %REPORTS%\logs\04_eda.log
echo   %REPORTS%\logs\05*.log
echo   %REPORTS%\logs\06_viz.log
echo Outputs:
echo   Next-quarter predictions  : %REPORTS%\next_quarter_predictions.csv
echo   OOF predictions (if saved): %REPORTS%\oof_*.csv
echo   Figures                   : %REPORTS%\figures\*.png
echo ===================================================
echo Done.
pause
goto :eof

rem --------------------- helpers ----------------------

:runit
rem %1 (label, optional), %2 exe, %3 script, %4 logfile
if not "%~1"=="" echo %~1
echo Running: %~3
if not exist "%~dp4" mkdir "%~dp4" >nul 2>&1
"%~2" "%~3"  1>>"%~4"  2>&1
if errorlevel 1 (
  echo [WARN] Step failed, see log: %~4
) else (
  echo [OK] Done. Log: %~4
)
echo.
exit /b

:detect_python
set "PY_EXE="
rem 1) registry detection (HKCU/HKLM)
for %%V in (3.13 3.12 3.11 3.10 3.9) do (
  for /f "tokens=2,*" %%A in ('reg query "HKCU\Software\Python\PythonCore\%%V\InstallPath" /ve 2^>nul ^| findstr /i "REG_SZ"') do (
    if exist "%%B\python.exe" set "PY_EXE=%%B\python.exe"
  )
  if not defined PY_EXE (
    for /f "tokens=2,*" %%A in ('reg query "HKLM\Software\Python\PythonCore\%%V\InstallPath" /ve 2^>nul ^| findstr /i "REG_SZ"') do (
      if exist "%%B\python.exe" set "PY_EXE=%%B\python.exe"
    )
  )
  if defined PY_EXE goto :dp_found
)
rem 2) where python
where python >nul 2>nul && for /f "delims=" %%P in ('where python') do (
  set "PY_EXE=%%P"
  goto :dp_found
)
rem 3) py launcher
where py >nul 2>nul && ( set "PY_EXE=py -3" & goto :dp_found )
:dp_found
exit /b

:end_fail
endlocal
exit /b 1
