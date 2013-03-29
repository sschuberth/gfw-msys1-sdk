@echo off

for /f "tokens=2" %%p in ('wmic process get executablepath^,processid ^| findstr /c:"mingwGitDevEnv\bin\sh.exe"') do taskkill /f /pid %%p
