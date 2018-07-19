@echo off

:Source

REM variables are local to this batch file
setlocal

set /p input="Drag and drop the source file (.avi, .avs etc.) into this window and press enter: "
echo.

REM check if filetyype is .avs or .avi
FOR %%i IN ("%input%") DO (
  if %%~xi==.avs goto Parameters
  if %%~xi==.avi goto Parameters
)

REM Alert user to file format
echo You are not using an .avs or .avi source file, are you sure you want to continue?
echo.

:AviAvs

set /p m="Enter 'y' for yes or 'n' for no: "
echo.

if %m%==y goto Parameters
if %m%==n exit

REM If neither of the above
goto AviAvs

:Parameters

set /p framerate="Enter the input video framerate: "
echo.

REM MPEG DASH GOP recommendation is 2 to 4 times framerate
set /p fragment="Enter the fragment duration in seconds (Recommended value is 2): "
echo.

REM /a enable arithmetic
set /a GOP=%framerate%*%fragment%
set /a DoubleGOP=%GOP%*2

echo The Group of Pictures (GOP) size will be %GOP%. && echo.

REM Check for input directory
if not exist "mp4" mkdir "mp4" goto Encode

REM Alert user
echo The mp4 directory already exists, all files will be overwritten, is this okay?
echo.

:DeleteMp4

set /p m="Enter 'y' for yes or 'n' for no: "
echo.

if %m%==y goto RemoveMp4
if %m%==n exit

REM If neither of the above
goto DeleteMp4

:RemoveMp4

rmdir "mp4" /s /q && mkdir "mp4"

:Encode

echo FFmpeg will now encode the source file at multiple bitrates for streaming, press any key to continue... && echo.

pause > nul

REM See https://developer.apple.com/streaming/examples/ for bitrate values
REM MPEG DASH encoding recommendations are CBR or VBR with VBR Max 110% and Buffer double VBR Max

echo Encoding aac_low 160k audio
ffmpeg -i %input% -vn ^
-metadata:s:a:0 language=eng ^
-profile:a aac_low -ac 2 -b:a 160k ^
-y mp4/00160k_aac_lc.mp4
echo.

echo Encoding 1080p 7800k
ffmpeg -i %input% -an ^
-movflags +faststart ^
-metadata:s:v:0 language=eng ^
-c:v libx264 -profile:v high -level:v 4.1 ^
-preset slow ^
-vf "scale=-2:1080" ^
-r %framerate% ^
-b:v 7800k -minrate 7800k -maxrate 8500k -bufsize 17160k ^
-force_key_frames "expr:eq(mod(n,%GOP%),0)" ^
-x264-params rc-lookahead=%GOP%:keyint=%DoubleGOP%:min-keyint=%GOP% ^
-vstats_file logs/1080p_7800k.log ^
-y mp4/07800k_1080p_h264.mp4
echo.

echo Encoding 1080p 6000k
ffmpeg -i %input% -an ^
-movflags +faststart ^
-metadata:s:v:0 language=eng ^
-c:v libx264 -profile:v high -level:v 4.1 ^
-preset slow ^
-vf "scale=-2:1080" ^
-r %framerate% ^
-b:v 6000k -minrate 6000k -maxrate 6600k -bufsize 13200k ^
-force_key_frames "expr:eq(mod(n,%GOP%),0)" ^
-x264-params rc-lookahead=%GOP%:keyint=%DoubleGOP%:min-keyint=%GOP% ^
-vstats_file logs/1080p_6000k.log ^
-y mp4/06000k_1080p_h264.mp4
echo.

echo Encoding 1080p 4500k
ffmpeg -i %input% -an ^
-movflags +faststart ^
-metadata:s:v:0 language=eng ^
-c:v libx264 -profile:v high -level:v 4.1 ^
-preset slow ^
-vf "scale=-2:1080" ^
-r %framerate% ^
-b:v 4500k -minrate 4500k -maxrate 4950k -bufsize 9900k ^
-force_key_frames "expr:eq(mod(n,%GOP%),0)" ^
-x264-params rc-lookahead=%GOP%:keyint=%DoubleGOP%:min-keyint=%GOP% ^
-vstats_file logs/1080p_4500k.log ^
-y mp4/04500k_1080p_h264.mp4
echo.

echo Encoding 720p 3000k
ffmpeg -i %input% -an ^
-movflags +faststart ^
-metadata:s:v:0 language=eng ^
-c:v libx264 -profile:v high -level:v 3.1 ^
-preset slow ^
-vf "scale=-2:720" ^
-r %framerate% ^
-b:v 3000k -minrate 3000k -maxrate 3300k -bufsize 6600k ^
-force_key_frames "expr:eq(mod(n,%GOP%),0)" ^
-x264-params rc-lookahead=%GOP%:keyint=%DoubleGOP%:min-keyint=%GOP% ^
-vstats_file logs/720p_3000k.log ^
-y mp4/03000k_720p_h264.mp4
echo.

echo Encoding 540p 2000k
ffmpeg -i %input% -an ^
-movflags +faststart ^
-metadata:s:v:0 language=eng ^
-c:v libx264 -profile:v high -level:v 3.1 ^
-preset slow ^
-vf "scale=-2:540" ^
-r %framerate% ^
-b:v 2000k -minrate 2000k -maxrate 2200k -bufsize 4400k ^
-force_key_frames "expr:eq(mod(n,%GOP%),0)" ^
-x264-params rc-lookahead=%GOP%:keyint=%DoubleGOP%:min-keyint=%GOP% ^
-vstats_file logs/540p_2000k.log ^
-y mp4/02000k_540p_h264.mp4
echo.

echo Encoding 360p 1000k
ffmpeg -i %input% -an ^
-movflags +faststart ^
-metadata:s:v:0 language=eng ^
-c:v libx264 -profile:v high -level:v 3.0 ^
-preset slow ^
-vf "scale=-2:360" ^
-r %framerate% ^
-b:v 1000k -minrate 1000k -maxrate 1100k -bufsize 2200k ^
-force_key_frames "expr:eq(mod(n,%GOP%),0)" ^
-x264-params rc-lookahead=%GOP%:keyint=%DoubleGOP%:min-keyint=%GOP% ^
-vstats_file logs/360p_1000k.log ^
-y mp4/01000k_360p_h264.mp4
echo.

REM Change the fragment variable from local to global so the next batch file can access it
endlocal & (
  set "fragment=%fragment%"
)

echo Finished encoding the source file at multiple bitrates, all files were saved to mp4/. && echo.

exit /b
