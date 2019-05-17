@echo off

REM Jump to this directory
pushd "%~dp0"

REM Title
echo. && echo x264 video encoder && echo.

REM Check if x264 exists
for %%x in (x264.exe) do if not [%%~$PATH:x]==[] goto mp4box

echo. Can't find x264. Press any key to exit...
echo.

pause > nul

exit /b

:mp4box

REM Check if FFmpeg exists
for %%x in (mp4box.exe) do if not [%%~$PATH:x]==[] goto source

echo Can't find mp4box. Press any key to exit...
echo.

pause > nul

exit /b

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
set /a GOP=%framerate%*2
set /a DoubleGOP=%GOP%*2

REM Check for input and output directories and update them
if exist "264" echo 264 directory already exists. Files with the same name will be overwritten. && echo. && pause && echo.

if not exist "264" mkdir "264"
if not exist "logs" mkdir "logs"

echo Ready to encode 264 files, press any key to continue... && echo.

pause > nul

REM See https://developer.apple.com/streaming/examples/ for bitrate values validated by crf tests
REM MPEG DASH encoding recommendations are CBR or VBR with VBR Max 110% and Buffer double VBR Max
REM MPEG DASH GOP recommendation is 2 times framerate
REM --no-scenecut or --scenecut 0 can be omitted for better results if --keyint is double --min-keyint

echo Encoding 1080p 7800 kbps
echo.
x264 --output 264/h264_1080p_07800k.264 --stats logs/x264.log --fps %framerate% --preset slow --profile high --level 4.1 --bitrate 7800 --vbv-maxrate 8580 --vbv-bufsize 17160 --min-keyint %GOP% --keyint %DoubleGOP% %input%
echo.

echo Encoding 1080p 6000 kbps
echo.
x264 --output 264/h264_1080p_06000k.264 --stats logs/x264.log --fps %framerate% --preset slow --profile high --level 4.1 --bitrate 6000 --vbv-maxrate 6600 --vbv-bufsize 13200 --min-keyint %GOP% --keyint %DoubleGOP% %input%
echo.

echo Encoding 1080p 4500 kbps
echo.
x264 --output 264/h264_1080p_04500k.264 --stats logs/x264.log --fps %framerate% --preset slow --profile high --level 4.1 --bitrate 4500 --vbv-maxrate 4950 --vbv-bufsize 9900 --min-keyint %GOP% --keyint %DoubleGOP% %input%
echo.

echo Encoding 720p 3000 kbps
echo.
x264 --output 264/h264_720p_03000k.264 --stats logs/x264.log --fps %framerate% --preset slow --profile high --level 4.1 --bitrate 3000 --vbv-maxrate 3300 --vbv-bufsize 6600 --min-keyint %GOP% --keyint %DoubleGOP% --video-filter "resize:width=1280,height=720,method=bicubic" %input%
echo.

echo Encoding 540p 2000 kbps
echo.
x264 --output 264/h264_540p_02000k.264 --stats logs/x264.log --fps %framerate% --preset slow --profile high --level 4.1 --bitrate 2000 --vbv-maxrate 2200 --vbv-bufsize 4400 --min-keyint %GOP% --keyint %DoubleGOP% --video-filter "resize:width=960,height=540,method=bicubic" %input%
echo.

echo Encoding 360p 1000 kbps
echo.
x264 --output 264/h264_360p_01000k.264 --stats logs/x264.log --fps %framerate% --preset slow --profile high --level 4.1 --bitrate 1000 --vbv-maxrate 1100 --vbv-bufsize 2200 --min-keyint %GOP% --keyint %DoubleGOP% --video-filter "resize:width=640,height=360,method=bicubic" %input%
echo.

echo Encoding 264 files complete && echo.

REM Check for mp4 directory
if exist "mp4" echo mp4 directory already exists. Files with the same name will be overwritten. && echo. && pause && echo.
if not exist "mp4" mkdir "mp4"

REM Define language
set language="en"

echo Ready to mux 264 to mp4, press any key to continue... && echo.

pause > nul

REM MP4Box Add each H264 track to an MP4 container
for %%f in (264\*.*) do (
  MP4Box -add %%f -new -fps %framerate% -lang %language% mp4/%%~nf.mp4 && echo. && echo Moved 264/%%~nf.264 to mp4/%%~nf.mp4
  echo.
)

echo. && echo Muxed 264 to mp4/. Press any key to exit...

pause > nul

exit /b
