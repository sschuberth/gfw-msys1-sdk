@echo off

setlocal enabledelayedexpansion

pushd %~dp0
 
rem Fix permissions for Perl DLLs.
attrib -r lib\perl5\*.dll /s

:retry

rem Rebase DLLs from within dash.
bin\dash.exe -c "/bin/rebaseall -v"
if errorlevel 1 (
    echo.
    set ANSWER=y
    set /p ANSWER="Try again? (Y/n) "
    if /i "!ANSWER!"=="n" goto quit
    if /i "!ANSWER!"=="no" goto quit
    echo.
    goto retry
)

:quit

popd

set seconds=5
where timeout > nul 2>&1
if errorlevel 0 (
    timeout %seconds%
) else (
    echo Waiting for %seconds% seconds...
    ping -n %seconds% 127.0.0.1 > nul
)
