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

REM Include temp directory for first of two pass encode
if not exist "temp" mkdir "temp"
mkdir "mp4"

:Resolution

echo Please select a video resolution:
echo.
echo 1. Press [1] for 1080p && echo.
echo 2. Press [2] for 720p && echo.
echo 3. Press [3] for 480p && echo.
echo 4. Press [4] for 360p && echo.

set /p op=Type option:
if "%op%"=="1" goto m1080p
if "%op%"=="2" goto m720p
if "%op%"=="3" goto m480p
if "%op%"=="4" goto m360p

echo Please select an option:
goto Resoluion

:m1080p

echo. && echo FFmpeg will now encode the source file at 1080p for streaming, press any key to continue... && echo.

pause > nul

goto 1080p

:m720p

echo. && echo FFmpeg will now encode the source file at 720p for streaming, press any key to continue... && echo.

pause > nul

goto 720p

:m480p

echo. && echo FFmpeg will now encode the source file at 480p for streaming, press any key to continue... && echo.

pause > nul

goto 480p

:m360p

echo. && echo FFmpeg will now encode the source file at 360p for streaming, press any key to continue... && echo.

pause > nul

goto 360p

REM See https://developer.apple.com/streaming/examples/ for bitrate values
REM MPEG DASH encoding recommendations are CBR or VBR with VBR Max 110% and Buffer double VBR Max

:1080p

echo Encoding 1080p 7500k && echo.
ffmpeg -i %input% -an ^
-r %framerate% ^
-c:v libx264 ^
-b:v 7500k -maxrate 7500k -bufsize 7500k ^
-preset slow ^
-vf "scale=-2:1080" ^
-force_key_frames "expr:eq(mod(n,%GOP%),0)" ^
-x264-params rc-lookahead=%GOP%:keyint=%DoubleGOP%:min-keyint=%GOP% ^
-vstats_file logs/1080p_07500k.log ^
-pass 1 ^
-f mp4 ^
-y temp/null

ffmpeg -i %input% -an ^
-movflags +faststart ^
-metadata:s:v:0 language=eng ^
-r %framerate% ^
-c:v libx264 ^
-b:v 7500k -maxrate 7500k -bufsize 7500k ^
-preset slow ^
-vf "scale=-2:1080" ^
-force_key_frames "expr:eq(mod(n,%GOP%),0)" ^
-x264-params rc-lookahead=%GOP%:keyint=%DoubleGOP%:min-keyint=%GOP% ^
-vstats_file logs/1080p_07500k.log ^
-pass 2 ^
-y mp4/1080p_07500k.mp4
echo.

echo Encoding 1080p 6000k && echo.
ffmpeg -i %input% -an ^
-r %framerate% ^
-c:v libx264 ^
-b:v 6000k -maxrate 6600k -bufsize 13200k ^
-preset slow ^
-vf "scale=-2:1080" ^
-force_key_frames "expr:eq(mod(n,%GOP%),0)" ^
-x264-params rc-lookahead=%GOP%:keyint=%DoubleGOP%:min-keyint=%GOP% ^
-vstats_file logs/1080p_06000k.log ^
-pass 1 ^
-f mp4 ^
-y temp/null

ffmpeg -i %input% -an ^
-movflags +faststart ^
-metadata:s:v:0 language=eng ^
-r %framerate% ^
-c:v libx264 ^
-b:v 6000k -maxrate 6600k -bufsize 13200k ^
-preset slow ^
-vf "scale=-2:1080" ^
-force_key_frames "expr:eq(mod(n,%GOP%),0)" ^
-x264-params rc-lookahead=%GOP%:keyint=%DoubleGOP%:min-keyint=%GOP% ^
-vstats_file logs/1080p_06000k.log ^
-pass 2 ^
-y mp4/1080p_06000k.mp4
echo.

echo Encoding 1080p 4500k && echo.
ffmpeg -i %input% -an ^
-r %framerate% ^
-c:v libx264 ^
-b:v 4500k -maxrate 4500k -bufsize 4500k ^
-preset slow ^
-vf "scale=-2:1080" ^
-force_key_frames "expr:eq(mod(n,%GOP%),0)" ^
-x264-params rc-lookahead=%GOP%:keyint=%DoubleGOP%:min-keyint=%GOP% ^
-vstats_file logs/1080p_04500k.log ^
-pass 1 ^
-f mp4 ^
-y temp/null

ffmpeg -i %input% -an ^
-movflags +faststart ^
-metadata:s:v:0 language=eng ^
-r %framerate% ^
-c:v libx264 ^
-b:v 4500k -maxrate 4500k -bufsize 4500k ^
-preset slow ^
-vf "scale=-2:1080" ^
-force_key_frames "expr:eq(mod(n,%GOP%),0)" ^
-x264-params rc-lookahead=%GOP%:keyint=%DoubleGOP%:min-keyint=%GOP% ^
-vstats_file logs/1080p_04500k.log ^
-pass 2 ^
-y mp4/1080p_04500k.mp4
echo.

echo Encoding 1080p 3000k && echo.
ffmpeg -i %input% -an ^
-r %framerate% ^
-c:v libx264 ^
-b:v 3000k -maxrate 3000k -bufsize 3000k ^
-preset slow ^
-vf "scale=-2:1080" ^
-force_key_frames "expr:eq(mod(n,%GOP%),0)" ^
-x264-params rc-lookahead=%GOP%:keyint=%DoubleGOP%:min-keyint=%GOP% ^
-vstats_file logs/1080p_03000k.log ^
-pass 1 ^
-f mp4 ^
-y temp/null

ffmpeg -i %input% -an ^
-movflags +faststart ^
-metadata:s:v:0 language=eng ^
-r %framerate% ^
-c:v libx264 ^
-b:v 3000k -maxrate 3000k -bufsize 3000k ^
-preset slow ^
-vf "scale=-2:1080" ^
-force_key_frames "expr:eq(mod(n,%GOP%),0)" ^
-x264-params rc-lookahead=%GOP%:keyint=%DoubleGOP%:min-keyint=%GOP% ^
-vstats_file logs/1080p_03000k.log ^
-pass 2 ^
-y mp4/1080p_03000k.mp4
echo.

goto Audio

:720p

echo Encoding 720p 4000k && echo.
ffmpeg -i %input% -an ^
-r %framerate% ^
-c:v libx264 ^
-b:v 4000k -maxrate 4000k -bufsize 4000k ^
-preset slow ^
-vf "scale=-2:720" ^
-force_key_frames "expr:eq(mod(n,%GOP%),0)" ^
-x264-params rc-lookahead=%GOP%:keyint=%DoubleGOP%:min-keyint=%GOP% ^
-vstats_file logs/720p_04000k.log ^
-pass 1 ^
-f mp4 ^
-y temp/null

ffmpeg -i %input% -an ^
-movflags +faststart ^
-metadata:s:v:0 language=eng ^
-r %framerate% ^
-c:v libx264 ^
-b:v 4000k -maxrate 4000k -bufsize 4000k ^
-preset slow ^
-vf "scale=-2:720" ^
-force_key_frames "expr:eq(mod(n,%GOP%),0)" ^
-x264-params rc-lookahead=%GOP%:keyint=%DoubleGOP%:min-keyint=%GOP% ^
-vstats_file logs/720p_04000k.log ^
-pass 2 ^
-y mp4/720p_04000k.mp4
echo.

echo Encoding 720p 3000k && echo.
ffmpeg -i %input% -an ^
-r %framerate% ^
-c:v libx264 ^
-b:v 3000k -maxrate 3000k -bufsize 3000k ^
-preset slow ^
-vf "scale=-2:720" ^
-force_key_frames "expr:eq(mod(n,%GOP%),0)" ^
-x264-params rc-lookahead=%GOP%:keyint=%DoubleGOP%:min-keyint=%GOP% ^
-vstats_file logs/720p_03000k.log ^
-pass 1 ^
-f mp4 ^
-y temp/null

ffmpeg -i %input% -an ^
-movflags +faststart ^
-metadata:s:v:0 language=eng ^
-r %framerate% ^
-c:v libx264 ^
-b:v 3000k -maxrate 3000k -bufsize 3000k ^
-preset slow ^
-vf "scale=-2:720" ^
-force_key_frames "expr:eq(mod(n,%GOP%),0)" ^
-x264-params rc-lookahead=%GOP%:keyint=%DoubleGOP%:min-keyint=%GOP% ^
-vstats_file logs/720p_03000k.log ^
-pass 2 ^
-y mp4/720p_03000k.mp4
echo.

echo Encoding 720p 2000k && echo.
ffmpeg -i %input% -an ^
-r %framerate% ^
-c:v libx264 ^
-b:v 2000k -maxrate 2000k -bufsize 2000k ^
-preset slow ^
-vf "scale=-2:720" ^
-force_key_frames "expr:eq(mod(n,%GOP%),0)" ^
-x264-params rc-lookahead=%GOP%:keyint=%DoubleGOP%:min-keyint=%GOP% ^
-vstats_file logs/720p_02000k.log ^
-pass 1 ^
-f mp4 ^
-y temp/null

ffmpeg -i %input% -an ^
-movflags +faststart ^
-metadata:s:v:0 language=eng ^
-r %framerate% ^
-c:v libx264 ^
-b:v 2000k -maxrate 2000k -bufsize 2000k ^
-preset slow ^
-vf "scale=-2:720" ^
-force_key_frames "expr:eq(mod(n,%GOP%),0)" ^
-x264-params rc-lookahead=%GOP%:keyint=%DoubleGOP%:min-keyint=%GOP% ^
-vstats_file logs/720p_02000k.log ^
-pass 2 ^
-y mp4/720p_02000k.mp4
echo.

goto Audio

:480p

echo Encoding 480p 2000k && echo.
ffmpeg -i %input% -an ^
-r %framerate% ^
-c:v libx264 ^
-b:v 2000k -maxrate 2000k -bufsize 2000k ^
-preset slow ^
-vf "scale=-2:480" ^
-force_key_frames "expr:eq(mod(n,%GOP%),0)" ^
-x264-params rc-lookahead=%GOP%:keyint=%DoubleGOP%:min-keyint=%GOP% ^
-vstats_file logs/480p_02000k.log ^
-pass 1 ^
-f mp4 ^
-y temp/null

ffmpeg -i %input% -an ^
-movflags +faststart ^
-metadata:s:v:0 language=eng ^
-r %framerate% ^
-c:v libx264 ^
-b:v 2000k -maxrate 2000k -bufsize 2000k ^
-preset slow ^
-vf "scale=-2:480" ^
-force_key_frames "expr:eq(mod(n,%GOP%),0)" ^
-x264-params rc-lookahead=%GOP%:keyint=%DoubleGOP%:min-keyint=%GOP% ^
-vstats_file logs/480p_02000k.log ^
-pass 2 ^
-y mp4/480p_02000k.mp4
echo.

echo Encoding 480p 1000k && echo.
ffmpeg -i %input% -an ^
-r %framerate% ^
-c:v libx264 ^
-b:v 1000k -maxrate 1000k -bufsize 1000k ^
-preset slow ^
-vf "scale=-2:480" ^
-force_key_frames "expr:eq(mod(n,%GOP%),0)" ^
-x264-params rc-lookahead=%GOP%:keyint=%DoubleGOP%:min-keyint=%GOP% ^
-vstats_file logs/480p_01000k.log ^
-pass 1 ^
-f mp4 ^
-y temp/null

ffmpeg -i %input% -an ^
-movflags +faststart ^
-metadata:s:v:0 language=eng ^
-r %framerate% ^
-c:v libx264 ^
-b:v 1000k -maxrate 1000k -bufsize 1000k ^
-preset slow ^
-vf "scale=-2:480" ^
-force_key_frames "expr:eq(mod(n,%GOP%),0)" ^
-x264-params rc-lookahead=%GOP%:keyint=%DoubleGOP%:min-keyint=%GOP% ^
-vstats_file logs/480p_01000k.log ^
-pass 2 ^
-y mp4/480p_01000k.mp4
echo.

goto Audio

:360p

echo Encoding 360p 1000k && echo.
ffmpeg -i %input% -an ^
-r %framerate% ^
-c:v libx264 ^
-b:v 1000k -maxrate 1000k -bufsize 1000k ^
-preset slow ^
-vf "scale=-2:360" ^
-force_key_frames "expr:eq(mod(n,%GOP%),0)" ^
-x264-params rc-lookahead=%GOP%:keyint=%DoubleGOP%:min-keyint=%GOP% ^
-vstats_file logs/360p_01000k.log ^
-pass 1 ^
-f mp4 ^
-y temp/null

ffmpeg -i %input% -an ^
-movflags +faststart ^
-metadata:s:v:0 language=eng ^
-r %framerate% ^
-c:v libx264 ^
-b:v 1000k -maxrate 1000k -bufsize 1000k ^
-preset slow ^
-vf "scale=-2:360" ^
-force_key_frames "expr:eq(mod(n,%GOP%),0)" ^
-x264-params rc-lookahead=%GOP%:keyint=%DoubleGOP%:min-keyint=%GOP% ^
-vstats_file logs/360p_01000k.log ^
-pass 2 ^
-y mp4/360p_01000k.mp4
echo.

:Audio

echo Encoding aac_low 160k audio && echo.
ffmpeg -i %input% -vn ^
-metadata:s:a:0 language=eng ^
-profile:a aac_low -ac 2 -b:a 160k ^
-y mp4/00160k_aac_lc.mp4
echo.

REM Delete the first pass folder and contents
if exist "temp" rmdir "temp" /s /q

REM Change the fragment variable from local to global so the next batch file can access it
endlocal & (
  set "fragment=%fragment%"
)

echo Finished encoding the source file to mp4/. && echo.

exit /b
