
@echo off
cd /d %~dp0

setlocal enabledelayedexpansion

REM Build (if needed)
call mvnw.cmd clean package -DskipTests

REM Find the latest JAR file in target directory
set JAR=
for /f "delims=" %%i in ('dir /b /o-d target\*.jar 2^>nul') do (
    set JAR=%%i
    goto :run
)

echo No JAR file found. Please check the build process or the target folder.
pause
exit /b

:run
echo Running JAR: !JAR!
java -jar target\!JAR!
pause