@echo off

REM Jump to this directory
pushd "%~dp0"
cd ..\..\

echo. && echo %cd% && echo.

REM Title
echo This batch file encodes video in lossless compressed FFV1 AVI format. && echo.

:Source

REM variables are local to this batch file
setlocal

set /p input="Drag and drop the source file (.avi, .avs etc.) into this window and press enter: "
echo.

REM check if filetyype is .avs or .avi
FOR %%f IN ("%input%") DO (

  REM Extract file name without suffix
  set output=%%~nf

  REM Continue if avi or avs format
  if %%~xf==.avs goto Encode
  if %%~xi==.avi goto Encode
)

REM Alert user to file format
echo You are not using an .avs or .avi source file, are you sure you want to continue?
echo.
set /p m="Enter 'y' for yes or 'n' for no: "
echo.

if %m%==y goto Encode
if %m%==n goto Source

:Encode

if not exist "avi" mkdir "avi"

REM Encode video to huffyuv and copy audio
REM ffmpeg -i %input% -c:v codec -c:a copy -y avi/output.avi
REM Lossless codecs in order of performance = ffv1, utvideo, huffyuv
ffmpeg -i %input% -c:v ffv1 -c:a copy -y avi/%output%_ffv1.avi
echo.

echo All encoding complete, the video was saved in avi/%output%_ffv1.avi, press any key to exit...

pause > nul

exit /b
