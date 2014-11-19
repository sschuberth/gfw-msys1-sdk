@echo off

set MSYSTEM=MSYS
bin\sh.exe --login update-perl-modules.sh

set seconds=5
where timeout > nul 2>&1
if errorlevel 0 (
    timeout %seconds%
) else (
    echo Waiting for %seconds% seconds...
    ping -n %seconds% 127.0.0.1 > nul
)
