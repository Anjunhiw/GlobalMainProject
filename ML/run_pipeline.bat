@echo off
setlocal EnableExtensions

REM ===== Paths (ASCII only, fully quoted on use) =====
set "BASE=%~dp0"
set "PY=python"
set "SCRIPTS=%BASE%scripts"
set "REPORTS=%BASE%reports"

REM ===== Create output dirs =====
if not exist "%REPORTS%" mkdir "%REPORTS%"
if not exist "%REPORTS%\logs" mkdir "%REPORTS%\logs"
if not exist "%REPORTS%\figures" mkdir "%REPORTS%\figures"

echo =======================================
echo   GMP_ML Pipeline START
echo   Logs: reports\logs
echo =======================================
echo.

echo [Step 1] IR Parsing ...
"%PY%" "%SCRIPTS%\01_parse_ir_2020_final.py"  1>>"%REPORTS%\logs\01_ir_2020.log"  2>&1
"%PY%" "%SCRIPTS%\01_parse_ir_2022_final.py"  1>>"%REPORTS%\logs\01_ir_2022.log"  2>&1
"%PY%" "%SCRIPTS%\01_parse_ir_2024_final.py"  1>>"%REPORTS%\logs\01_ir_2024.log"  2>&1
"%PY%" "%SCRIPTS%\01_parse_ir_2025_final.py"  1>>"%REPORTS%\logs\01_ir_2025.log"  2>&1
echo   Results: data\raw\*.csv
echo.

echo [Step 2] External (DART/Public/ERP) ...
"%PY%" "%SCRIPTS%\02a_fetch_dart_final.py"           1>>"%REPORTS%\logs\02a_dart.log"     2>&1
"%PY%" "%SCRIPTS%\02b_fetch_odcloudkr_api_final.py"  1>>"%REPORTS%\logs\02b_public.log"   2>&1
echo   Results: data\external\*.csv
echo.

echo [Step 3] Dataset Build ...
"%PY%" "%SCRIPTS%\03a_ir_dataset_final.py"       1>>"%REPORTS%\logs\03a_ir_dataset.log"  2>&1
"%PY%" "%SCRIPTS%\03b_build_ml_dataset_final.py" 1>>"%REPORTS%\logs\03b_build_ml.log"    2>&1
echo   Results: data\final\ir_long_master.csv, ml_dataset_*.csv
echo.

echo [Step 4] EDA ...
"%PY%" "%SCRIPTS%\04_eda_final.py"               1>>"%REPORTS%\logs\04_eda.log"          2>&1
echo   Results: reports\EDA\*.png
echo.

REM & is a command separator. Escape it as ^& in echo lines.
echo [Step 5] Train ^& Predict ...
"%PY%" "%SCRIPTS%\05a_train_baseline_final.py"   1>>"%REPORTS%\logs\05a_train.log"       2>&1
"%PY%" "%SCRIPTS%\05b_train_next_final.py"       1>>"%REPORTS%\logs\05b_predict.log"     2>&1
echo   Models:  models\*.joblib
echo   Metrics: reports\metrics_*.json
echo   Predict: reports\next_quarter_predictions.csv
echo.

echo [Step 6] Visualization ...
"%PY%" "%SCRIPTS%\06_visualize_predictions_final.py" 1>>"%REPORTS%\logs\06_viz.log" 2>&1
echo   Figures: reports\figures\*.png
echo.

echo =======================================
echo   Pipeline DONE
echo   Logs:   reports\logs
echo   Output: reports\next_quarter_predictions.csv
echo   Open:   reports\figures (Explorer)
echo =======================================
echo.

REM Open figures folder (create if missing)
if not exist "%REPORTS%\figures" mkdir "%REPORTS%\figures"
start "" "%REPORTS%\figures"

pause
endlocal
