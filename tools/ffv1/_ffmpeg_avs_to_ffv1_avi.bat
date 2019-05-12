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

:Encode

if not exist "mkv" mkdir "mkv"

REM Encode video to huffyuv and copy audio
REM ffmpeg -i %input% -c:v codec -c:a copy -y avi/output.avi
REM Lossless codecs in order of performance = ffv1, utvideo, huffyuv
ffmpeg -i %input% -c:v ffv1 -c:a copy -y mkv/%output%_ffv1.mkv
echo.

echo All encoding complete, the video was saved in mkv/%output%_ffv1.mkv, press any key to exit...

pause > nul

exit /b
