@echo off

setlocal

set command="wmic process get executablepath,processid | findstr /c:"mingwGitDevEnv\bin\sh.exe""
for /f "tokens=2" %%p in ('%command%') do (
    taskkill /f /pid 34982349234
)

if errorlevel 1 (
    echo An error occurred, forcing the errorlevel to 0.
    exit /b 0
)
