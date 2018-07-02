@echo off

REM Jump to this directory
pushd "%~dp0"

REM Title
echo. && echo Mux H264 to mp4 && echo.

set /p framerate="Enter the video framerate: "
echo.

REM Check for mp4 directory
if exist "mp4" echo mp4 directory already exists. Files with the same name will be overwritten. && echo. && pause && echo.
if not exist "mp4" mkdir "mp4"

REM Define language
set language="en"

echo Ready to mux 264 to mp4, press any key to continue... && echo.

pause > nul

REM MP4Box Add each H264 track to an MP4 container
for %%f in (264\*.*) do (
REM  MP4Box -add %%f -new -fps %framerate% -lang %language% mp4/%%~nf.mp4 && echo. && echo Muxed 264/%%~nf.264 to mp4/%%~nf.mp4
  mp4mux --track h264:%%f#frame_rate=%framerate% mp4/%%~nf.mp4 && echo. && echo Muxed 264/%%~nf.264 to mp4/%%~nf.mp4
  echo.
)

echo Deleting *.mp4_ files... && echo.

del /s /q /f mp4\*.mp4_

echo.
echo All 264/ files muxed to mp4/, press any key to exit...

pause > nul

exit /b
