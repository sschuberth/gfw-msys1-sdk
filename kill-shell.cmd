@echo off

wmic /output:process.log process get executablepath,processid

REM Use "type" to convert Unicode to ASCII text before using "findstr".
type process.log | findstr /c:"mingwGitDevEnv\bin\sh.exe"
if errorlevel 1 (
    echo No shell process found that needs to be terminated.
    exit /b 0
)
