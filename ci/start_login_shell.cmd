@echo off

rem Clean the PATH from unwanted stuff.
set PATH=%PATH:C:\Git-SDK\local\bin=%
set PATH=%PATH:C:\Git-SDK\mingw\bin=%
set PATH=%PATH:C:\Git-SDK\bin=%

echo.
echo PATH environment:
echo %PATH%

rem Start a login shell.
Git-SDK\bin\sh.exe --login -i
