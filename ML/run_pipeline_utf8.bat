@echo off
chcp 65001 >nul
setlocal EnableExtensions

REM ===== Python 자동 탐색 =====
set "PY="
for /f "delims=" %%P in ('where py 2^>nul') do set "PY=py -3"
if not defined PY for /f "delims=" %%P in ('where python 2^>nul') do set "PY=python"
if not defined PY for /f "delims=" %%P in ('where python3 2^>nul') do set "PY=python3"

if not defined PY (
  echo [안내] 이 PC에 Python이 없습니다.
  set /p INSTALL=지금 Python을 설치할까요? (winget 사용) [Y/N]: 
  if /i "%INSTALL%"=="Y" (
    where winget >nul 2>&1
    if errorlevel 1 (
      echo [경고] winget이 없습니다. python.org 다운로드 페이지를 엽니다...
      start "" "https://www.python.org/downloads/windows/"
      echo 설치를 완료한 뒤, 아무 키나 누르세요...
      pause >nul
    ) else (
      echo [정보] winget으로 Python 설치를 시도합니다...
      winget install -e --id Python.Python.3.13 -h
      if errorlevel 1 (
        echo [경고] winget 설치 실패. python.org 페이지를 엽니다...
        start "" "https://www.python.org/downloads/windows/"
        echo 설치를 완료한 뒤, 아무 키나 누르세요...
        pause >nul
      )
    )
    REM 재검사
    for /f "delims=" %%P in ('where py 2^>nul') do set "PY=py -3"
    if not defined PY for /f "delims=" %%P in ('where python 2^>nul') do set "PY=python"
    if not defined PY for /f "delims=" %%P in ('where python3 2^>nul') do set "PY=python3"
    if not defined PY (
      echo [치명] 여전히 Python이 보이지 않습니다. 설치 후 다시 실행하세요.
      pause & exit /b 1
    )
  ) else (
    echo [중단] 사용자가 N을 선택하여 종료합니다.
    exit /b 1
  )
)

%PY% --version || ( echo [치명] Python 실행 실패 (PY=%PY%) & pause & exit /b 1 )

REM ===== 경로 =====
set "BASE=%~dp0"
set "SCRIPTS=%BASE%scripts"
set "REPORTS=%BASE%reports"
set "REQUIRE=%BASE%requirements.txt"

REM ===== 출력 디렉터리 =====
if not exist "%REPORTS%" mkdir "%REPORTS%"
if not exist "%REPORTS%\logs" mkdir "%REPORTS%\logs"
if not exist "%REPORTS%\figures" mkdir "%REPORTS%\figures"

echo =======================================
echo   GMP_ML 파이프라인 시작
echo   Python: %PY%
echo   로그:   reports\logs
echo =======================================
echo.

REM ===== Step 0: requirements 설치/검증 =====
echo [Step 0] 의존성 설치/검증 (requirements.txt) ...
if exist "%REQUIRE%" (
  "%PY%" -m pip --version  1>>"%REPORTS%\logs\00_setup.log" 2>&1 || (
    "%PY%" -m ensurepip --upgrade 1>>"%REPORTS%\logs\00_setup.log" 2>&1
  )
  "%PY%" -m pip install -r "%REQUIRE%" --upgrade 1>>"%REPORTS%\logs\00_setup.log" 2>&1
  if errorlevel 1 echo [경고] requirements 설치 실패. reports\logs\00_setup.log 확인
) else (
  echo [정보] requirements.txt 없음 → 설치 스킵
)
echo.

echo [Step 1] IR 파싱 ...
"%PY%" "%SCRIPTS%\01_parse_ir_2020_final.py"  1>>"%REPORTS%\logs\01_ir_2020.log"  2>&1
"%PY%" "%SCRIPTS%\01_parse_ir_2022_final.py"  1>>"%REPORTS%\logs\01_ir_2022.log"  2>&1
"%PY%" "%SCRIPTS%\01_parse_ir_2024_final.py"  1>>"%REPORTS%\logs\01_ir_2024.log"  2>&1
"%PY%" "%SCRIPTS%\01_parse_ir_2025_final.py"  1>>"%REPORTS%\logs\01_ir_2025.log"  2>&1
echo   → 결과물: data\raw\*.csv
echo.

echo [Step 2] 외부 수집(DART/Public/ERP) ...
"%PY%" "%SCRIPTS%\02a_fetch_dart_final.py"           1>>"%REPORTS%\logs\02a_dart.log"   2>&1
"%PY%" "%SCRIPTS%\02b_fetch_odcloudkr_api_final.py"  1>>"%REPORTS%\logs\02b_public.log" 2>&1
echo   → 결과물: data\external\*.csv
echo.

echo [Step 3] 데이터셋 빌드 ...
"%PY%" "%SCRIPTS%\03a_ir_dataset_final.py"       1>>"%REPORTS%\logs\03a_ir_dataset.log"  2>&1
"%PY%" "%SCRIPTS%\03b_build_ml_dataset_final.py" 1>>"%REPORTS%\logs\03b_build_ml.log"    2>&1
echo   → 결과물: data\final\ir_long_master.csv, ml_dataset_*.csv
echo.

echo [Step 4] EDA ...
"%PY%" "%SCRIPTS%\04_eda_final.py"               1>>"%REPORTS%\logs\04_eda.log"          2>&1
echo   → 결과물: reports\EDA\*.png
echo.

echo [Step 5] Train ^& Predict ...
"%PY%" "%SCRIPTS%\05a_train_baseline_final.py"   1>>"%REPORTS%\logs\05a_train.log"       2>&1
"%PY%" "%SCRIPTS%\05b_train_next_final.py"       1>>"%REPORTS%\logs\05b_predict.log"     2>&1
echo   → 모델:   models\*.joblib
echo   → 메트릭: reports\metrics_*.json
echo   → 예측:   reports\next_quarter_predictions.csv
echo.

echo [Step 6] 시각화 ...
"%PY%" "%SCRIPTS%\06_visualize_predictions_final.py" 1>>"%REPORTS%\logs\06_viz.log" 2>&1
echo   → 시각화: reports\figures\*.png
echo.

echo =======================================
echo   파이프라인 완료!
echo   로그:   reports\logs
echo   예측:   reports\next_quarter_predictions.csv
echo   시각화 폴더를 지금 엽니다...
echo =======================================
echo.

if not exist "%REPORTS%\figures" mkdir "%REPORTS%\figures"
start "" "%REPORTS%\figures"

pause
endlocal
