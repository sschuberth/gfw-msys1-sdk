@echo off

setlocal

for /f "delims=" %%f in ('dir /b /o:d *.exe 2^> nul') do set newest=%%~nf

if "%newest%" == "" (
    echo ERROR: No installer found, please build it first.
    exit /b 1
)

echo Installing %newest% ...
%newest%.exe /log="%newest%.log" /verysilent /dir="mingwGitDevEnv" /noicons /portable=1
