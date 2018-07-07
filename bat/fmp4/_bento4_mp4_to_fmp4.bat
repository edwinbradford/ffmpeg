@echo off

REM variables are local to this batch file
setlocal

if exist "mp4" goto Initialized

REM Check if mp4 directory exists
if not exist "mp4" echo Something went wrong, can not find the mp4/ directory, press any key to exit...
echo.

pause > nul

exit

:Initialized

REM Check for fmp4 directory
if exist "fmp4" rmdir "fmp4" /s /q

mkdir "fmp4"

REM Convert fragment size from secs to millisecs
set /a fragmentms=%fragment%*1000

echo Ready to fragment with a fragment size of %fragmentms%, press any key to continue... && echo.

pause > nul

REM Fragment mp4 files with user input duration
for %%f in (mp4\*.*) do (
  mp4fragment --verbosity 1 --fragment-duration %fragmentms% %%f fmp4/%%~nf.mp4 && echo Fragmented mp4/%%~nf.mp4 in fmp4/%%~nf.mp4
)

echo. && echo All files were fragmented and saved to fmp4/ && echo.

exit /b
