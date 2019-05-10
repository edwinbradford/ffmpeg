@echo off

:Source

REM variables are local to this batch file
setlocal

set /p input="Drag and drop the source file (.avi, .avs etc.) into this window and press enter: "
echo.

REM check if filetyype is .avs or .avi
FOR %%i IN (%input%) DO (
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
if not exist "logs" mkdir "logs"
if not exist "mp4" goto MakeMp4
if exist "mp4" goto DeleteMp4

:DeleteMp4

REM Alert user
echo The mp4 directory already exists, all files will be overwritten, is this okay?
echo.

set /p m="Enter 'y' for yes or 'n' for no: "
echo.

if %m%==y goto RemoveMp4
if %m%==n exit

REM If neither of the above
goto DeleteMp4

:RemoveMp4

rmdir "mp4" /s /q

:MakeMp4

mkdir "mp4"

:Resolution

echo Please select a video resolution:
echo.
echo 1. Press [1] for 1080p && echo.
echo 2. Press [2] for 720p && echo.
echo 3. Press [3] for 540p && echo.
echo 4. Press [4] for 360p && echo.

set /p op=Type option:
if "%op%"=="1" goto m1080p
if "%op%"=="2" goto m720p
if "%op%"=="3" goto m540p
if "%op%"=="4" goto m360p

echo Please select an option:
goto Resoluion

:m1080p

echo. && echo FFmpeg will now encode the source file at resolutions up to 1080p for streaming, press any key to continue... && echo.

pause > nul

goto 1080p

:m720p

echo. && echo FFmpeg will now encode the source file at resolutions up to 720p for streaming, press any key to continue... && echo.

pause > nul

goto 720p

:m540p

echo. && echo FFmpeg will now encode the source file at resolutions up to 540p for streaming, press any key to continue... && echo.

pause > nul

goto 540p

:m360p

echo. && echo FFmpeg will now encode the source file at resolutions up to 360p for streaming, press any key to continue... && echo.

pause > nul

goto 360p

REM See https://developer.apple.com/streaming/examples/ for bitrate values
REM MPEG DASH encoding recommendations are CBR or VBR with VBR Max 110% and Buffer double VBR Max

:1080p

echo Encoding 1080p 7800k
ffmpeg -i %input% -an ^
-movflags +faststart ^
-metadata:s:v:0 language=eng ^
-c:v libx264 ^
-b:v 7800k -maxrate 8500k -bufsize 17160k ^
-preset slow ^
-vf "scale=-2:1080" ^
-r %framerate% ^
-x264-params scenecut=0:open_gop=0:min-keyint=%GOP%:keyint=%GOP% ^
-vstats_file logs/1080p_7800k.log ^
-y mp4/07800k_1080p_h264.mp4
echo.

echo Encoding 1080p 6000k
ffmpeg -i %input% -an ^
-movflags +faststart ^
-metadata:s:v:0 language=eng ^
-c:v libx264 ^
-b:v 6000k -maxrate 6600k -bufsize 13200k ^
-preset slow ^
-vf "scale=-2:1080" ^
-r %framerate% ^
-x264-params scenecut=0:open_gop=0:min-keyint=%GOP%:keyint=%GOP% ^
-vstats_file logs/1080p_6000k.log ^
-y mp4/06000k_1080p_h264.mp4
echo.

echo Encoding 1080p 4500k
ffmpeg -i %input% -an ^
-movflags +faststart ^
-metadata:s:v:0 language=eng ^
-c:v libx264 ^
-b:v 4500k -maxrate 4950k -bufsize 9900k ^
-preset slow ^
-vf "scale=-2:1080" ^
-r %framerate% ^
-x264-params scenecut=0:open_gop=0:min-keyint=%GOP%:keyint=%GOP% ^
-vstats_file logs/1080p_4500k.log ^
-y mp4/04500k_1080p_h264.mp4
echo.

:720p

echo Encoding 720p 3000k
ffmpeg -i %input% -an ^
-movflags +faststart ^
-metadata:s:v:0 language=eng ^
-c:v libx264 ^
-b:v 3000k -maxrate 3300k -bufsize 6600k ^
-preset slow ^
-vf "scale=-2:720" ^
-r %framerate% ^
-x264-params scenecut=0:open_gop=0:min-keyint=%GOP%:keyint=%GOP% ^
-vstats_file logs/720p_3000k.log ^
-y mp4/03000k_720p_h264.mp4
echo.

:540p

echo Encoding 540p 2000k
ffmpeg -i %input% -an ^
-movflags +faststart ^
-metadata:s:v:0 language=eng ^
-c:v libx264 ^
-b:v 2000k -maxrate 2200k -bufsize 4400k ^
-preset slow ^
-vf "scale=-2:540" ^
-r %framerate% ^
-x264-params scenecut=0:open_gop=0:min-keyint=%GOP%:keyint=%GOP% ^
-vstats_file logs/540p_2000k.log ^
-y mp4/02000k_540p_h264.mp4
echo.

:360p

echo Encoding 360p 1000k
ffmpeg -i %input% -an ^
-movflags +faststart ^
-metadata:s:v:0 language=eng ^
-c:v libx264 ^
-b:v 1000k -maxrate 1100k -bufsize 2200k ^
-preset slow ^
-vf "scale=-2:360" ^
-r %framerate% ^
-x264-params scenecut=0:open_gop=0:min-keyint=%GOP%:keyint=%GOP% ^
-vstats_file logs/360p_1000k.log ^
-y mp4/01000k_360p_h264.mp4
echo.

:Audio

echo Encoding aac_low 160k audio
ffmpeg -i %input% -vn ^
-metadata:s:a:0 language=eng ^
-profile:a aac_low -ac 2 -b:a 160k ^
-y mp4/00160k_aac_lc.mp4
echo.

REM Change the fragment variable from local to global so the next batch file can access it
endlocal & (
  set "fragment=%fragment%"
)

echo Finished encoding the source file to mp4/. && echo.

exit /b
