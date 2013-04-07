@echo off

wmic process get executablepath,processid | findstr /c:"mingwGitDevEnv" > process.log
if errorlevel 1 (
    echo No shell process found that needs to be terminated.
    exit /b 0
)

for /f "tokens=2" %%p in (process.log) do (
    taskkill /f /pid %%p
)
