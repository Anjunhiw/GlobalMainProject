@echo off
setlocal ENABLEDELAYEDEXPANSION
REM ===== Console to UTF-8 =====
chcp 65001 >nul

title GMP_ML Pipeline Runner (UTF-8)

echo ------------------------------------------------------------
echo [GMP_ML] 파이프라인 실행기를 시작합니다.
echo 이 창은 닫지 마세요. 진행 상황과 로그 위치를 안내합니다.
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

REM 1) 후보 탐색
for /f "delims=" %%P in ('where py 2^>nul')      do set "PY=py -3"
if not defined PY for /f "delims=" %%P in ('where python 2^>nul')  do set "PY=python"
if not defined PY for /f "delims=" %%P in ('where python3 2^>nul') do set "PY=python3"

REM 2) 검증
call :_validate_py
if "%ERRORLEVEL%"=="0" goto :_py_ready

echo [INFO] 이 PC에 Python 3.x가 설치되어 있지 않습니다.
set /p _YN=지금 설치하시겠습니까? [Y/N]: 
if /i "!_YN!" NEQ "Y" (
  echo [ABORT] 사용자가 설치를 취소했습니다. 프로그램을 종료합니다.
  pause & exit /b 1
)

where winget >nul 2>&1
if errorlevel 1 (
  echo [WARN] winget이 없어 웹 페이지로 이동합니다.
  start "" "https://www.python.org/downloads/windows/"
  echo 설치를 완료하신 뒤, 아무 키나 눌러 계속하세요...
  pause >nul
) else (
  echo [INFO] winget으로 Python을 설치합니다...
  winget install -e --id Python.Python.3.13 -h
  if errorlevel 1 (
    echo [WARN] winget 설치가 실패했습니다. 웹 페이지를 엽니다.
    start "" "https://www.python.org/downloads/windows/"
    echo 설치를 완료하신 뒤, 아무 키나 눌러 계속하세요...
    pause >nul
  )
)

REM 재탐색/재검증
set "PY="
for /f "delims=" %%P in ('where py 2^>nul')      do set "PY=py -3"
if not defined PY for /f "delims=" %%P in ('where python 2^>nul')  do set "PY=python"
if not defined PY for /f "delims=" %%P in ('where python3 2^>nul') do set "PY=python3"
call :_validate_py
if not "%ERRORLEVEL%"=="0" (
  echo [FATAL] Python을 여전히 찾을 수 없습니다. 설치 후 다시 실행하세요.
  pause & exit /b 1
)

:_py_ready
echo [OK] Python 확인됨: %PY%
echo.

REM ===== 가상환경 권장 알림(선택) =====
echo [TIP] 가상환경(venv)을 사용하시는 것을 권장합니다.
echo      이미 환경이 있다면 활성화 후 다시 실행하세요.
echo.

REM ===== requirements 설치/검증 =====
if exist "%ROOT%requirements.txt" (
  echo [Step 0] 의존성 확인 및 설치 (requirements.txt)
  "%PY%" -m pip install --upgrade pip >nul 2>&1
  "%PY%" -m pip install -r "%ROOT%requirements.txt"
  if errorlevel 1 (
    echo [WARN] 일부 패키지 설치에 실패했습니다. 로그를 확인하세요.
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
REM ERP 연동 스크립트가 있다면 여기에 추가하세요.

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
echo [완료] 파이프라인이 종료되었습니다.
echo [확인 경로]
echo   - 로그:     "%LOGDIR%"
echo   - 그림:     "%FIGDIR%"
echo   - 예측 CSV: "%REPORTS%\next_quarter_predictions.csv"
echo   - ML DS:    "%ROOT%\data\ml_dataset_*.csv"
echo ------------------------------------------------------------
echo 필요 시 로그를 열어 오류 메시지를 확인하세요.
pause
endlocal
exit /b 0


REM ===== 함수: Python 검증 =====
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
