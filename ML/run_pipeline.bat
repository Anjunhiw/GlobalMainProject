@echo off
setlocal

REM -------- Paths --------
set PY=python
set SCRIPTS=%~dp0scripts
set REPORTS=%~dp0reports
if not exist "%REPORTS%" mkdir "%REPORTS%"
if not exist "%REPORTS%\logs" mkdir "%REPORTS%\logs"
if not exist "%REPORTS%\figures" mkdir "%REPORTS%\figures"

echo [Step 1] IR Parsing
%PY% "%SCRIPTS%\01_parse_ir_2020_final.py"  1>>"%REPORTS%\logs\01_ir_2020.log"  2>&1
%PY% "%SCRIPTS%\01_parse_ir_2022_final.py"  1>>"%REPORTS%\logs\01_ir_2022.log"  2>&1
%PY% "%SCRIPTS%\01_parse_ir_2024_final.py"   1>>"%REPORTS%\logs\01_ir_2024.log"  2>&1
%PY% "%SCRIPTS%\01_parse_ir_2025_final.py"   1>>"%REPORTS%\logs\01_ir_2025.log"  2>&1

echo [Step 2] External (DART/Public/ERP)
%PY% "%SCRIPTS%\02a_fetch_dart_final.py"        1>>"%REPORTS%\logs\02a_dart.log"     2>&1
%PY% "%SCRIPTS%\02b_fetch_odcloudkr_api_final.py" 1>>"%REPORTS%\logs\02b_public.log" 2>&1

echo [Step 3] Dataset Build
%PY% "%SCRIPTS%\01d_ir_dataset_final.py" 1>>"%REPORTS%\logs\03_01d.log" 2>&1
%PY% "%SCRIPTS%\03_build_ml_dataset_final.py"      1>>"%REPORTS%\logs\03_build.log" 2>&1

echo [Step 4] EDA
%PY% "%SCRIPTS%\04_eda_final.py"           1>>"%REPORTS%\logs\04_eda.log" 2>&1

echo [Step 5] Train & Predict
%PY% "%SCRIPTS%\05a_train_baseline_final.py" 1>>"%REPORTS%\logs\05a_train.log" 2>&1
%PY% "%SCRIPTS%\05b_train_next_final.py"    1>>"%REPORTS%\logs\05b_predict.log" 2>&1

echo [Step 6] Visualization
%PY% "%SCRIPTS%\06_visualize_predictions_final.py" 1>>"%REPORTS%\logs\06_viz.log" 2>&1

echo Done.
pause
endlocal
