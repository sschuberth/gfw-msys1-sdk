@echo off

set MSYSTEM=MSYS
bin\sh.exe --login update-perl-modules.sh

timeout /t 5
