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
echo 3. Press [3] for 360p && echo.

set /p op=Type option:
if "%op%"=="1" goto m1080p
if "%op%"=="2" goto m720p
if "%op%"=="3" goto m360p

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

:m360p

echo. && echo FFmpeg will now encode the source file at resolutions up to 360p for streaming, press any key to continue... && echo.

pause > nul

goto 360p

:1080p

echo Encoding 1080p 6000k
ffmpeg -i %input% -an ^
-movflags +faststart ^
-metadata:s:v:0 language=eng ^
-c:v libx264 -profile:v high -level:v 4.1 ^
-preset slow ^
-vf "scale=-2:1080" ^
-r %framerate% ^
-b:v 6000k -maxrate 6000k -bufsize 6000k ^
-force_key_frames "expr:eq(mod(n,%GOP%),0)" ^
-x264-params rc-lookahead=%GOP%:keyint=%DoubleGOP%:min-keyint=%GOP% ^
-vstats_file logs/1080p_6000k.log ^
-y mp4/06000k_1080p_h264.mp4
echo.

echo Encoding 1080p 5000k
ffmpeg -i %input% -an ^
-movflags +faststart ^
-metadata:s:v:0 language=eng ^
-c:v libx264 -profile:v high -level:v 4.1 ^
-preset slow ^
-vf "scale=-2:1080" ^
-r %framerate% ^
-b:v 5000k -maxrate 5000k -bufsize 5000k ^
-force_key_frames "expr:eq(mod(n,%GOP%),0)" ^
-x264-params rc-lookahead=%GOP%:keyint=%DoubleGOP%:min-keyint=%GOP% ^
-vstats_file logs/1080p_5000k.log ^
-y mp4/05000k_1080p_h264.mp4
echo.

echo Encoding 1080p 4000k
ffmpeg -i %input% -an ^
-movflags +faststart ^
-metadata:s:v:0 language=eng ^
-c:v libx264 -profile:v high -level:v 4.1 ^
-preset slow ^
-vf "scale=-2:1080" ^
-r %framerate% ^
-b:v 4000k -maxrate 4000k -bufsize 4000k ^
-force_key_frames "expr:eq(mod(n,%GOP%),0)" ^
-x264-params rc-lookahead=%GOP%:keyint=%DoubleGOP%:min-keyint=%GOP% ^
-vstats_file logs/1080p_4000k.log ^
-y mp4/04000k_1080p_h264.mp4
echo.

echo Encoding 1080p 3000k
ffmpeg -i %input% -an ^
-movflags +faststart ^
-metadata:s:v:0 language=eng ^
-c:v libx264 -profile:v high -level:v 4.1 ^
-preset slow ^
-vf "scale=-2:1080" ^
-r %framerate% ^
-b:v 3000k -maxrate 3000k -bufsize 3000k ^
-force_key_frames "expr:eq(mod(n,%GOP%),0)" ^
-x264-params rc-lookahead=%GOP%:keyint=%DoubleGOP%:min-keyint=%GOP% ^
-vstats_file logs/1080p_3000k.log ^
-y mp4/03000k_1080p_h264.mp4
echo.

:720p

echo Encoding 720p 2000k
ffmpeg -i %input% -an ^
-movflags +faststart ^
-metadata:s:v:0 language=eng ^
-vf "scale=-2:720" ^
-c:v libx264 -profile:v high -level:v 3.1 ^
-preset slow ^
-r %framerate% ^
-b:v 2000k -maxrate 2000k -bufsize 2000k ^
-force_key_frames "expr:eq(mod(n,%GOP%),0)" ^
-x264-params rc-lookahead=%GOP%:keyint=%DoubleGOP%:min-keyint=%GOP% ^
-vstats_file logs/720p_2000k.log ^
-y mp4/02000k_720p_h264.mp4
echo.

:360p

echo Encoding 360p 1000k
ffmpeg -i %input% -an ^
-movflags +faststart ^
-metadata:s:v:0 language=eng ^
-c:v libx264 -profile:v high -level:v 3.0 ^
-preset slow ^
-vf "scale=-2:360" ^
-r %framerate% ^
-b:v 1000k -maxrate 1000k -bufsize 1000k ^
-force_key_frames "expr:eq(mod(n,%GOP%),0)" ^
-x264-params rc-lookahead=%GOP%:keyint=%DoubleGOP%:min-keyint=%GOP% ^
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
