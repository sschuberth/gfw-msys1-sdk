@echo off

rem The order of columns is fixed and cannot be changed by the order of arguments.
wmic process get executablepath,processid | findstr /c:"mingwGitDevEnv" > process.log
goto findstr_mingwGitDevEnv_%errorlevel%

:findstr_mingwGitDevEnv_0

for /f "tokens=2" %%p in (process.log) do (
    rem Force kill processes including their children.
    taskkill /f /t /pid %%p
)

goto findstr_sh

:findstr_mingwGitDevEnv_1

echo No processes found that need to be killed.

:findstr_sh

rem List any other running shell processes for informational purposes.
wmic process get executablepath,processid | findstr /c:"sh.exe" > process.log
goto findstr_sh_%errorlevel%

:findstr_sh_0

echo The following shell processes are still running:
type process.log

goto quit

:findstr_sh_1

echo No other shell processes found.

:quit

del process.log

rem Force the exit code to 0.
exit /b 0
