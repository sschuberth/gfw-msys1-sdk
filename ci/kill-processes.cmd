@echo off

rem The order of columns is fixed and cannot be changed by the order of arguments.
wmic process get executablepath,processid | findstr /c:"mingwGitDevEnv\bin\sh.exe" > process.log
goto findstr_mingwGitDevEnv_%errorlevel%

:findstr_mingwGitDevEnv_0

rem Do not kill child processes automatically to avoid error messages about non-existing PIDs.
for /f "tokens=2" %%p in (process.log) do (
    taskkill /pid %%p /t /f
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
