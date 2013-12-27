@echo off

rem Clean the PATH from unwanted stuff.
set PATH=%PATH:c:\mingwGitDevEnv\mingw\bin=%
set PATH=%PATH:c:\mingwGitDevEnv\bin=%

echo.
echo PATH environment:
echo %PATH%

rem Start a login shell.
mingwGitDevEnv\bin\sh.exe --login -i
