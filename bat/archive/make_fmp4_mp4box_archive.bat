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

if exist "264" goto setup

REM Check if x264 directory exists
if not exist "264" echo Can not find the source '264' directory containing videos. Please run the fmp4 video batch file before this one. Press any key to exit...
echo.

pause > nul

exit /b

:setup

set /p name="Enter the video title (spaces allowed): "
echo.

setlocal enableextensions enabledelayedexpansion

REM Remove spaces from name variable
set filename=%name: =_%

REM Convert to lower case
call :tolower filename
goto :framerate

REM Subroutines exit with goto :eof at the end
:toupper
for %%L IN (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) DO SET %1=!%1:%%L=%%L!
goto :EOF

:tolower
for %%L IN (a b c d e f g h i j k l m n o p q r s t u v w x y z) DO SET %1=!%1:%%L=%%L!
goto :EOF

:framerate
echo.
set /p framerate="Enter the video framerate: "
echo.

set copyright="Edwin Bradford (c) 2016"
set language="en"
set pixelAspectRatio="1:1"

REM Recommended DASH segment length is 2s
set segment="2000"

REM Check for existing directories
if exist "mp4"  echo mp4 directory already exists. Files with the same name will be overwritten. && echo. && pause && echo.
if not exist "mp4" mkdir "mp4"

if not exist "logs" mkdir "logs"

REM MP4Box Add each H264 track to an MP4 container
for %%f in (264\*.*) do (
  MP4Box -add %%f -new -fps %framerate% -lang %language% -par 1=%pixelAspectRatio% mp4/%%~nf.mp4 && echo. && echo Moved 264/%%~nf.264 to mp4/%%~nf.mp4
  echo.
)

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

REM MPEG-DASH contents
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
MP4Box -log-file logs/mp4box-bug-log.txt -logs all@debug -cprt %copyright% -bs-switching no -dash %segment% -frag %segment% -rap -profile %profile% -mpd-title "%name%" "%segmentation%" -out fmp4/"%filename%" %list%
endlocal

echo. && echo Processed all files for dash. Press any key to exit...

pause > nul

exit /b
