@echo off

REM Jump to this directory
pushd "%~dp0"

REM Title
echo. && echo MP4Box MPEG-DASH && echo.

REM Check if MP4Box exists
for %%x in (mp4box.exe) do if not [%%~$PATH:x]==[] goto source

echo Can't find MP4Box. Press any key to exit...
echo.

pause > nul

exit /b

:source

if exist "mp4" goto setup

REM Check if mp4 directory exists
if not exist "mp4" echo Can not find the input 'mp4' directory, please run the add_video and add_audio files first. Press any key to exit...
echo.

pause > nul

exit /b

:setup

set /p name="Enter the video meta title: "
echo.

echo.
set /p framerate="Enter the video framerate: "
echo.

set copyright="Edwin Bradford (c) 2016"

REM Recommended DASH segment length is 4-10 seconds
set segment="4000"

if not exist "logs" mkdir "logs"

REM choose Dash Profile menu
set /p m="Select the Dash profile. Press 1 for 'On Demand' and 2 for 'Live': "

if %m%==2 goto live
if %m%==1 goto onDemand

:live

set profile="dashavc264:live"
set segmentation="-segment-name $RepresentationID$\0$Number$"
goto package

:onDemand

set profile="dashavc264:onDemand"
set segmentation="-single-segment"

goto package

:package

REM Check for existing directories
if exist "fmp4"  echo. && echo fmp4 directory already exists. Files with the same name will be overwritten. && echo. && pause && echo.
if not exist "fmp4" mkdir "fmp4"

REM Store input files as space separated list in a variable
setlocal enabledelayedexpansion enableextensions
set list=
for %%f in (mp4\*) do set list=!list! %%f
set list=%list:~1%

REM Fragment mp4 files and create dash content
REM -bs-switching should be disabled for H264
MP4Box -log-file logs/mp4box-bug-log.txt -logs all@debug -cprt %copyright% -bs-switching no -dash %segment% -frag %segment% -rap -profile %profile% -mpd-title "%name%" "%segmentation%" -out fmp4/media %list%
endlocal

echo. && echo Processed all files for dash. Press any key to exit...

pause > nul

exit /b
