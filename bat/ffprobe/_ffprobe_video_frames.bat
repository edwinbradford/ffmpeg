<<<<<<< HEAD
@echo off

REM Jump to this directory
pushd "%~dp0"
cd ..\..\

echo. && echo %cd% && echo.

REM Title
echo This batch file uses FFprobe to log mp4 frame type ^& position in a .csv text file.  && echo.

:Source

REM variables are local to this batch file
setlocal

set /p input="Drag and drop a video file into this window and press enter: "
echo.

REM check if filetyype is .mp4
FOR %%f IN ("%input%") DO (

  REM Extract file name without suffix
  set output=%%~nf

  REM Continue if mp4 or 264 format
  if %%~xf==.mp4 goto Dump
  if %%~xf==.264 goto Dump
)

echo Oops, not an mp4 video file... && echo.

goto Source

:Dump

REM Check if mp4 directory exists
if not exist "logs" mkdir "logs"

REM See https://goo.gl/xak49p probesize is optional and only prevents warnings
ffprobe %input% -probesize 10000000 -select_streams v -show_frames -of csv -show_entries frame=coded_picture_number,key_frame,pict_type > logs/%output%_frames.csv

echo.

echo FFprobe complete, the log was saved in logs/%output%_frames.csv, press any key to exit...

pause > nul

exit /b
=======
@echo off

REM Jump to this directory
pushd "%~dp0"
cd ..\..\

echo. && echo %cd% && echo.

REM Title
echo This batch file uses FFprobe to log mp4 frame type ^& position in a .csv text file.  && echo.

:Source

REM variables are local to this batch file
setlocal

set /p input="Drag and drop a video file into this window and press enter: "
echo.

REM check if filetyype is .mp4
FOR %%f IN ("%input%") DO (

  REM Extract file name without suffix
  set output=%%~nf

  REM Continue if mp4 or 264 format
  if %%~xf==.mp4 goto Dump
  if %%~xf==.264 goto Dump
)

echo Oops, not an mp4 video file... && echo.

goto Source

:Dump

REM Check if mp4 directory exists
if not exist "logs" mkdir "logs"

REM See https://goo.gl/xak49p probesize is optional and only prevents warnings
ffprobe %input% -probesize 10000000 -select_streams v -show_frames -of csv -show_entries frame=coded_picture_number,key_frame,pict_type > logs/%output%_frames.csv

echo.

echo FFprobe complete, the log was saved in logs/%output%_frames.csv, press any key to exit...

pause > nul

exit /b
>>>>>>> 1307abd0f5b8059d9ab697a10e3671557f2fc6ca
