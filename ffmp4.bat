@echo off

REM Jump to this directory
pushd "%~dp0"

echo. && echo %cd% && echo.

REM Title
echo FFfmp4 && echo.

REM Check if FFmpeg exists
for %%x in (ffmpeg.exe) do if not [%%~$PATH:x]==[] goto Initialized

echo Can't find FFmpeg, install FFmpeg then try again, press any key to exit...
echo.

pause > nul

exit /b

:Initialized

if not exist "logs" mkdir "logs"

if not exist "media" goto MakeMedia

REM Alert user
echo The media directory already exists, all files will be overwritten, is this okay?
echo.

:QueryRemoveMedia

set /p m="Enter 'y' for yes or 'n' for no: "
echo.

if %m%==y goto RemoveMedia
if %m%==n exit

REM If neither of the above
goto QueryRemoveMedia

:RemoveMedia

rmdir "media" /s /q

:MakeMedia

mkdir "media"
mkdir "media\chunks"
mkdir "media\inits"

:Source

set /p input="Drag the source file into this window and press enter: "
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

echo Enter the source video's framerate. && echo.
set /p framerate="Framerate : "
echo.

REM MPEG DASH GOP recommendation is 2 to 4 times framerate
echo Enter the stream fragment size. Recommended values are 2 - 4.  && echo.
set /p fragment="Fragment size : "
echo.

echo Enter the stream segment length (secs.) e.g. 4.  && echo.
set /p segment="Segment length (secs) : "

REM /a enable arithmetic
set /a GOP=%framerate%*%fragment%

echo. && echo FFmpeg will now encode the source file at resolutions up to 1080p for streaming, press any key to continue... && echo.

pause > nul

goto 1080p

:1080p

ffmpeg ^
-channel_layout stereo ^
-i %input% ^
-map 0:0 ^
-map 0:0 ^
-map 0:0 ^
-map 0:0 ^
-map 0:1 ^
-r %framerate% ^
-preset slow ^
-vstats_file logs/ffmp4.log ^
-c:a aac ^
-profile:a aac_low ^
-ac 2 ^
-b:a:0 160k ^
-metadata:s:a language=eng ^
-c:v libx264 ^
-b:v:0 4000k ^
-b:v:1 3000k ^
-b:v:2 2000k ^
-b:v:3 1000k ^
-s:v:2 1280x720 ^
-s:v:3 640x360 ^
-profile:v:0 high ^
-profile:v:1 high ^
-profile:v:2 high ^
-profile:v:3 high ^
-bf 1 ^
-keyint_min %GOP% ^
-g %GOP% ^
-seg_duration %segment% ^
-sc_threshold 0 ^
-b_strategy 0 ^
-use_template 1 ^
-use_timeline 0 ^
-adaptation_sets "id=0,streams=v id=1,streams=a" ^
-media_seg_name chunks/$RepresentationID$_$Number%%05d$.m4s ^
-init_seg_name inits/$RepresentationID$.m4s ^
-hls_playlist 1 ^
-f dash media/media.mpd || goto Error

echo. && echo Finished encoding. && echo.

REM Use DOS to rename "master.m3u8" to "media.m3u8"
ren "media\master.m3u8" "media.m3u8"

if exist "media\media.m3u8" goto PassRename

echo Could not rename "master.m3u8" to "media.m3u8" && echo.

goto Close

:PassRename

echo Renamed "master.m3u8" to "media.m3u8" && echo.

:Close

echo Streams were saved in media/. && echo.

pause > nul

exit /b

:Error

echo. && echo FFmpeg found something wrong... && echo.

pause > nul

exit /b
