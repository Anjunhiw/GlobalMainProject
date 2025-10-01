﻿@echo off
chcp 65001 >nul
setlocal enableextensions

rem ============================================================
rem  GMP_ML Pipeline Runner (UTF-8, Korean messages)
rem ============================================================

title GMP_ML 파이프라인 실행기
echo [GMP_ML] 파이프라인 실행을 시작합니다...
echo 이 창을 닫지 마세요. 로그와 출력물이 안내됩니다.
echo ------------------------------------------------------------

rem ---- 폴더 경로 ----
set "ROOT=%~dp0"
set "SCRIPTS=%ROOT%scripts"
set "REPORTS=%ROOT%reports"
if not exist "%REPORTS%" mkdir "%REPORTS%" >nul 2>&1
if not exist "%REPORTS%\logs" mkdir "%REPORTS%\logs" >nul 2>&1
if not exist "%REPORTS%\figures" mkdir "%REPORTS%\figures" >nul 2>&1

rem ---- Python 탐지 ----
call :detect_python

if not defined PY_EXE (
  echo [INFO] 현재 Python 3.x 이 설치되어 있지 않습니다.
  set /p ANS=winget 으로 Python을 설치하시겠습니까? [Y/N]: 
  if /i "%ANS%"=="Y" (
    echo [INFO] winget으로 Python 설치를 진행합니다...
    winget install --id Python.Python.3.13 ^
      --silent --accept-package-agreements --accept-source-agreements
    call :detect_python
    if not defined PY_EXE (
      if exist "%LocalAppData%\Microsoft\WindowsApps\python.exe" (
        set "PY_EXE=%LocalAppData%\Microsoft\WindowsApps\python.exe"
      )
    )
  ) else (
    echo [FATAL] Python이 없어 종료합니다.
    goto :end_fail
  )
)

if not defined PY_EXE (
  echo [FATAL] 여전히 Python을 찾을 수 없습니다.
  echo 다음을 확인하세요:
  echo   1) 설정 → 앱 → 앱 실행 별칭: python.exe, python3.exe 켜기
  echo   2) 관리자 권한으로 이 배치 실행
  echo   3) https://www.python.org/downloads/windows/ 에서 수동 설치
  pause
  goto :end_fail
)

echo [OK] Python 경로: %PY_EXE%
for /f "usebackq delims=" %%V in (`"%PY_EXE%" -c "import sys;print(sys.version)"`) do set "PY_VER=%%V"
echo [OK] Python 버전: %PY_VER%

rem ---- pip 및 패키지 확인 ----
echo.
echo [STEP] pip 및 필수 라이브러리 확인...
"%PY_EXE%" -m ensurepip --upgrade >nul 2>&1
"%PY_EXE%" -m pip install --upgrade pip >nul 2>&1

set "REQ=%ROOT%requirements.txt"
if exist "%REQ%" (
  echo [INFO] requirements.txt 기반 패키지 설치...
  "%PY_EXE%" -m pip install -r "%REQ%"
) else (
  echo [WARN] requirements.txt 파일이 없습니다. 패키지 설치 건너뜀.
)

rem ---- 파이프라인 실행 ----
echo.
echo [STEP] 전체 파이프라인 실행...
echo   로그 폴더   : %REPORTS%\logs
echo   그림 폴더   : %REPORTS%\figures
echo   결과 CSV   : %REPORTS%
echo ------------------------------------------------------------

call :runit "[1단계] IR 파싱 - 2020" "%PY_EXE%" "%SCRIPTS%\01_parse_ir_2020_final.py"   "%REPORTS%\logs\01_ir_2020.log"
call :runit "[1단계] IR 파싱 - 2022" "%PY_EXE%" "%SCRIPTS%\01_parse_ir_2022_final.py"   "%REPORTS%\logs\01_ir_2022.log"
call :runit "[1단계] IR 파싱 - 2024" "%PY_EXE%" "%SCRIPTS%\01_parse_ir_2024_final.py"   "%REPORTS%\logs\01_ir_2024.log"
call :runit "[1단계] IR 파싱 - 2025" "%PY_EXE%" "%SCRIPTS%\01_parse_ir_2025_final.py"   "%REPORTS%\logs\01_ir_2025.log"

call :runit "[2단계] 외부 데이터 (DART)"   "%PY_EXE%" "%SCRIPTS%\02a_fetch_dart_final.py"         "%REPORTS%\logs\02a_dart.log"
call :runit "[2단계] 외부 데이터 (공공)"   "%PY_EXE%" "%SCRIPTS%\02b_fetch_odcloudkr_api_final.py" "%REPORTS%\logs\02b_public.log"

call :runit "[3단계] 데이터셋 빌드 - IR"    "%PY_EXE%" "%SCRIPTS%\03a_ir_dataset_final.py"         "%REPORTS%\logs\03_01d.log"
call :runit "[3단계] 데이터셋 빌드 - ML"    "%PY_EXE%" "%SCRIPTS%\03b_build_ml_dataset_final.py"   "%REPORTS%\logs\03_build.log"

call :runit "[4단계] EDA 실행"              "%PY_EXE%" "%SCRIPTS%\04_eda_final.py"                "%REPORTS%\logs\04_eda.log"

call :runit "[5단계] 학습"                  "%PY_EXE%" "%SCRIPTS%\05a_train_baseline_final.py"    "%REPORTS%\logs\05a_train.log"
call :runit "[5단계] 예측"                  "%PY_EXE%" "%SCRIPTS%\05b_train_next_final.py"        "%REPORTS%\logs\05b_predict.log"

call :runit "[6단계] 시각화"                "%PY_EXE%" "%SCRIPTS%\06_visualize_predictions_final.py" "%REPORTS%\logs\06_viz.log"

echo.
echo ===================== 요약 =====================
echo 로그 파일:
echo   %REPORTS%\logs\*.log
echo 결과 파일:
echo   %REPORTS%\next_quarter_predictions.csv
echo   %REPORTS%\oof_*.csv
echo 그림:
echo   %REPORTS%\figures\*.png
echo ================================================
echo 완료되었습니다.
pause
goto :eof

rem --------------------- 헬퍼 함수 ---------------------

:runit
if not "%~1"=="" echo %~1
echo 실행: %~3
if not exist "%~dp4" mkdir "%~dp4" >nul 2>&1
"%~2" "%~3"  1>>"%~4"  2>&1
if errorlevel 1 (
  echo [WARN] 오류 발생, 로그 확인: %~4
) else (
  echo [OK] 완료. 로그: %~4
)
echo.
exit /b

:detect_python
set "PY_EXE="
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
where python >nul 2>nul && for /f "delims=" %%P in ('where python') do (
  set "PY_EXE=%%P"
  goto :dp_found
)
where py >nul 2>nul && ( set "PY_EXE=py -3" & goto :dp_found )
:dp_found
exit /b

:end_fail
endlocal
exit /b 1
