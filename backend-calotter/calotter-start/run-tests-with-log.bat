@echo off
REM 运行测试并保存完整输出到文件
REM 使用方法: run-tests-with-log.bat [test-name] [output-file]

setlocal enabledelayedexpansion

set TEST_NAME=%1
set OUTPUT_FILE=%2

if "%OUTPUT_FILE%"=="" (
    for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
    set datetime=!datetime:~0,14!
    set OUTPUT_FILE=test-output-!datetime!.log
)

echo 开始运行测试，输出将保存到: %OUTPUT_FILE%

if "%TEST_NAME%"=="" (
    mvn test > "%OUTPUT_FILE%" 2>&1
) else (
    mvn test -Dtest=%TEST_NAME% > "%OUTPUT_FILE%" 2>&1
)

echo.
echo 测试完成！输出已保存到: %OUTPUT_FILE%
echo 文件位置: %CD%\%OUTPUT_FILE%

endlocal
