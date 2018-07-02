@echo off

REM See https://developer.apple.com/streaming/examples/ for bitrate values
REM MPEG DASH encoding recommendations are VBR and VBR Max 110% or CBR
REM Recommended Buffer is double Max VBR
REM MPEG DASH GOP recommendation is 2 times framerate

REM Jump to this directory
pushd "%~dp0"

REM Title
echo. && echo fmp4 video encoder && echo.

REM Check if x264 exists
for %%x in (x264.exe) do if not [%%~$PATH:x]==[] goto audio

echo. Can't find x264. Press any key to exit...
echo.

pause > nul

exit /b

:audio

REM Check if FFmpeg exists
for %%x in (ffmpeg.exe) do if not [%%~$PATH:x]==[] goto source

echo Can't find FFmpeg. Press any key to exit...
echo.

pause > nul

exit /b

:source

set /p input="Drag and drop an Avisynth (.avs) file into this window and press enter: "
echo.

REM check if filetyype is .avs
setlocal
FOR %%i IN ("%input%") DO (
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

echo Encoding 1080p crf 18
echo.
x264 --output 264/h264_1080p_crf_18.264 --stats logs/x264.log --fps %framerate% --preset slow --profile high --level 4.1 --crf 18 --min-keyint %GOP% --keyint %DoubleGOP% %input%
echo.

echo Encoding 1080p crf 20
echo.
x264 --output 264/h264_1080p_crf_20.264 --stats logs/x264.log --fps %framerate% --preset slow --profile high --level 4.1 --crf 20 --min-keyint %GOP% --keyint %DoubleGOP% %input%
echo.

echo Encoding 1080p crf 22
echo.
x264 --output 264/h264_1080p_crf_22.264 --stats logs/x264.log --fps %framerate% --preset slow --profile high --level 4.1 --crf 22 --min-keyint %GOP% --keyint %DoubleGOP% %input%
echo.

echo Encoding 720p crf 18
echo.
x264 --output 264/h264_720p_crf_18.264 --stats logs/x264.log --fps %framerate% --preset slow --profile high --level 4.1 --crf 18 --min-keyint %GOP% --keyint %DoubleGOP% --video-filter "resize:width=1280,height=720,method=bicubic" %input%
echo.

echo Encoding 720p crf 20
echo.
x264 --output 264/h264_720p_crf_20.264 --stats logs/x264.log --fps %framerate% --preset slow --profile high --level 4.1 --crf 20 --min-keyint %GOP% --keyint %DoubleGOP% --video-filter "resize:width=1280,height=720,method=bicubic" %input%
echo.

echo Encoding 720p crf 22
echo.
x264 --output 264/h264_720p_crf_22.264 --stats logs/x264.log --fps %framerate% --preset slow --profile high --level 4.1 --crf 22 --min-keyint %GOP% --keyint %DoubleGOP% --video-filter "resize:width=1280,height=720,method=bicubic" %input%
echo.

echo Encoding 540p crf 18
echo.
x264 --output 264/h264_540p_crf_18.264 --stats logs/x264.log --fps %framerate% --preset slow --profile high --level 4.1 --crf 18 --min-keyint %GOP% --keyint %DoubleGOP% --video-filter "resize:width=960,height=540,method=bicubic" %input%
echo.

echo Encoding 540p crf 20
echo.
x264 --output 264/h264_540p_crf_20.264 --stats logs/x264.log --fps %framerate% --preset slow --profile high --level 4.1 --crf 20 --min-keyint %GOP% --keyint %DoubleGOP% --video-filter "resize:width=960,height=540,method=bicubic" %input%
echo.

echo Encoding 540p crf 22
echo.
x264 --output 264/h264_540p_crf_22.264 --stats logs/x264.log --fps %framerate% --preset slow --profile high --level 4.1 --crf 22 --min-keyint %GOP% --keyint %DoubleGOP% --video-filter "resize:width=960,height=540,method=bicubic" %input%
echo.

echo Encoding 360p crf 18
echo.
x264 --output 264/h264_360p_crf_18.264 --stats logs/x264.log --fps %framerate% --preset slow --profile high --level 4.1 --crf 18 --min-keyint %GOP% --keyint %DoubleGOP% --video-filter "resize:width=640,height=360,method=bicubic" %input%
echo.

echo Encoding 360p crf 20
echo.
x264 --output 264/h264_360p_crf_20.264 --stats logs/x264.log --fps %framerate% --preset slow --profile high --level 4.1 --crf 20 --min-keyint %GOP% --keyint %DoubleGOP% --video-filter "resize:width=640,height=360,method=bicubic" %input%
echo.

echo Encoding 360p crf 22
echo.
x264 --output 264/h264_360p_crf_22.264 --stats logs/x264.log --fps %framerate% --preset slow --profile high --level 4.1 --crf 22 --min-keyint %GOP% --keyint %DoubleGOP% --video-filter "resize:width=640,height=360,method=bicubic" %input%
echo.

echo Encoded 264 files in 264/ && echo.

REM Check for mp4 directory
if exist "mp4" echo mp4 directory already exists. Files with the same name will be overwritten. && echo. && pause && echo.
if not exist "mp4" mkdir "mp4"

echo Ready to mux 264 to mp4, press any key to continue... && echo.

pause > nul

REM Mux 264 files
for %%f in (264\*.*) do (
  REM REM -y (overwrite) -r (force framerate) -i (input) -c:v copy (codec video copy)
  ffmpeg -y -loglevel warning -r 30 -i %%f -c:v copy mp4/%%~nf.mp4 && echo Muxed mp4/%%~nf.mp4 && echo.
)

echo. && echo Muxed 264 to mp4/. Press any key to exit...

pause > nul

exit /b
