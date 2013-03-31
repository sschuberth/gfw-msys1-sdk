@echo off

setlocal

set command="wmic process get executablepath,processid | findstr /c:"mingwGitDevEnv\bin\sh.exe""
for /f "tokens=2" %%p in ('%command%') do (
    taskkill /f /pid %%p
)

REM For some reason, without this comment Jenkins markes the build as failure when no tasks are killed!
