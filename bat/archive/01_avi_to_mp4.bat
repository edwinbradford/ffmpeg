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
REM MPEG DASH GOP recommendation is 2 to 4 times framerate
set /a GOP=%framerate%*2

REM Check for input and output directories and update them
if exist "mp4" echo mp4 directory already exists. Files with the same name will be overwritten. && echo. && pause && echo.

if not exist "mp4" mkdir "mp4"
if not exist "logs" mkdir "logs"

echo Ready to encode video to mp4, press any key to continue... && echo.

pause > nul

REM See https://developer.apple.com/streaming/examples/ for bitrate values validated by crf tests
REM MPEG DASH encoding recommendations are CBR or VBR with VBR Max 110% and Buffer double VBR Max

echo Encoding aac_low 128kbps audio see logs/aac_lc_128k.log
ffmpeg -i %input% -vn ^
-metadata:s:a:0 language=eng ^
-profile:a aac_low -ac 2 -b:a 128k ^
-y mp4/aac_lc_128k.mp4
echo.

echo Encoding 1080p 7800kbps see logs/h264_1080p_07800k.log
ffmpeg -i %input% -an ^
-vf "scale=-2:1080" ^
-c:v libx264 -profile:v main -level:v 4.2 ^
-x264opts scenecut=0:open_gop=0:min-keyint=%GOP%:keyint=%GOP% ^
-minrate 7800k -maxrate 7800k -bufsize 7800k -b:v 7800k ^
-y mp4/h264_1080p_07800k.mp4
echo.

echo Encoding 1080p 6000kbps see logs/h264_1080p_06000k.log
ffmpeg -i %input% -an ^
-vf "scale=-2:1080" ^
-c:v libx264 -profile:v main -level:v 4.2 ^
-x264opts scenecut=0:open_gop=0:min-keyint=%GOP%:keyint=%GOP% ^
-minrate 6000k -maxrate 6000k -bufsize 6000k -b:v 6000k ^
-y mp4/h264_1080p_06000k.mp4
echo.

echo Encoding 1080p 4500kbps see logs/h264_1080p_04500k.log
ffmpeg -i %input% -an ^
-vf "scale=-2:1080" ^
-c:v libx264 -profile:v main -level:v 4.2 ^
-x264opts scenecut=0:open_gop=0:min-keyint=%GOP%:keyint=%GOP% ^
-minrate 4500k -maxrate 4500k -bufsize 4500k -b:v 4500k ^
-y mp4/h264_1080p_04500k.mp4
echo.

echo Encoding 720p 3000kbps see logs/h264_720p_03000k.log
ffmpeg -i %input% -an ^
-vf "scale=-2:720" ^
-c:v libx264 -profile:v main -level:v 4.0 ^
-x264opts scenecut=0:open_gop=0:min-keyint=%GOP%:keyint=%GOP% ^
-minrate 3000k -maxrate 3000k -bufsize 3000k -b:v 3000k ^
-y mp4/h264_720p_03000k.mp4
echo.

echo Encoding 540p 2000kbps see logs/h264_540p_02000k.log
ffmpeg -i %input% -an ^
-vf "scale=-2:540" ^
-c:v libx264 -profile:v main -level:v 4.0 ^
-x264opts scenecut=0:open_gop=0:min-keyint=%GOP%:keyint=%GOP% ^
-minrate 2000k -maxrate 2000k -bufsize 2000k -b:v 2000k ^
-y mp4/h264_540p_02000k.mp4
echo.

echo Encoding 360p 1000kbps see logs/h264_360p_01000k.log
ffmpeg -i %input% -an ^
-vf "scale=-2:360" ^
-c:v libx264 -profile:v baseline -level:v 3.0 ^
-x264opts scenecut=0:open_gop=0:min-keyint=%GOP%:keyint=%GOP% ^
-minrate 1000k -maxrate 1000k -bufsize 1000k -b:v 1000k ^
-y mp4/h264_360p_01000k.mp4
echo.

echo All encoding completed, press any key to exit...

pause > nul

exit /b
