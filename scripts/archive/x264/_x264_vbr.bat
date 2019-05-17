@echo off

REM Jump to this directory
pushd "%~dp0"

REM Title
echo. && echo Make mp4 && echo.

:source

set /p input="Drag and drop an Avisynth (.avs) file into this window and press enter: "
echo.

REM check if filetyype is .avs
setlocal
FOR %%i IN (%input%) DO (
if %%~xi==.avs goto framerate
)
endlocal

echo. && echo Oops, not an Avisynth file. && echo.

goto source

:framerate

set /p framerate="Enter the input video framerate: "
echo.

REM /a enable arithmetic
REM MPEG DASH GOP recommendation is 2 to 4 times framerate
set /a GOP=%framerate%*2

REM Check for input and output directories and update them
if exist "264" echo 264 directory already exists. Files with the same name will be overwritten. && echo. && pause && echo.

if not exist "264" mkdir "264"

echo Ready to encode video to 264, press any key to continue... && echo.

pause > nul

REM See https://developer.apple.com/streaming/examples/ for bitrate values
REM MPEG DASH encoding recommendations are CBR or VBR with VBR Max 110% and Buffer double VBR Max

echo Encoding 1080p 7800kbps
x264 --output 264/h264_1080p_7800k.264 --fps %framerate% --preset slow --profile high --level 4.1 --bitrate 7800 --vbv-maxrate 8580 --vbv-bufsize 17160 --min-keyint %GOP% --keyint %GOP% --scenecut 0 %input%
echo.

echo Encoding 1080p 6000kbps
x264 --output 264/h264_1080p_6000k.264 --fps %framerate% --preset slow --profile high --level 4.1 --bitrate 6000 --vbv-maxrate 6600 --vbv-bufsize 13200 --min-keyint %GOP% --keyint %GOP% --scenecut 0 %input%
echo.

echo Encoding 1080p 4500kbps
x264 --output 264/h264_1080p_4500k.264 --fps %framerate% --preset slow --profile high --level 4.1 --bitrate 4500 --vbv-maxrate 4950 --vbv-bufsize 9900 --min-keyint %GOP% --keyint %GOP% --scenecut 0 %input%
echo.

echo Encoding 720p 3000kbps
x264 --output 264/h264_720p_3000k.264 --fps %framerate% --preset slow --profile high --level 3.1 --bitrate 3000 --vbv-maxrate 3300 --vbv-bufsize 6600 --min-keyint %GOP% --keyint %GOP% --scenecut 0 --video-filter "resize:width=1280,height=720,method=bicubic" %input%
echo.

echo Encoding 540p 2000kbps
x264 --output 264/h264_540p_2000k.264 --fps %framerate% --preset slow --profile high --level 3.1 --bitrate 2000 --vbv-maxrate 2200 --vbv-bufsize 4400 --min-keyint %GOP% --keyint %GOP% --scenecut 0 --video-filter "resize:width=960,height=540,method=bicubic" %input%
echo.

echo Encoding 360p 1000kbps
x264 --output 264/h264_360p_1000k.264 --fps %framerate% --preset slow --profile high --level 3.0 --bitrate 1000 --vbv-maxrate 1100 --vbv-bufsize 2200 --min-keyint %GOP% --keyint %GOP% --scenecut 0 --video-filter "resize:width=640,height=360,method=bicubic" %input%
echo.

echo All encoding completed, press any key to exit...

pause > nul

exit /b
