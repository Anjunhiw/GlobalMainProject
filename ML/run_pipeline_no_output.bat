@echo off
rem 콘솔 출력 숨김 실행용 배치 파일
rem 인코딩: ANSI / UTF-8(BOM 없음) 모두 사용 가능

rem chcp 65001 >nul  (UTF-8 필요시 주석 해제)

pushd "%~dp0"

python scripts\01_parse_ir_2025.py    >nul 2>&1
python scripts\02a_fetch_dart.py      >nul 2>&1
python scripts\02b_fetch_odcloudkr_api.py  >nul 2>&1
python scripts\01d_ir_dataset.py      >nul 2>&1
python scripts\03_build_ml_dataset.py  >nul 2>&1
python scripts\05a_train_baseline.py   >nul 2>&1
python scripts\05b_train_next.py       >nul 2>&1

popd
exit /b 0
