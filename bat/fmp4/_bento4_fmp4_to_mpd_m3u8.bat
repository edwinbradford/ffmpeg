<<<<<<< HEAD
@echo off

REM Check if mpd directory exists
if not exist "mpd" mkdir "mpd" && goto Stream

rmdir "mpd" /s /q && mkdir "mpd"

:Stream

echo Ready to package files for streaming, press any key to continue...

pause > nul

echo.

REM Create Dash and HLS content
REM Store input files as space separated array in a variable
setlocal enabledelayedexpansion enableextensions
set list=
for %%x in (fmp4\*) do set list=!list! %%x
set list=%list:~1%

REM YouTube use the Live Profile
REM mp4dash closes the batch on completion so is called in a new shell
cmd /c mp4dash --verbose --output-dir=mpd --force --mpd-name=media.mpd --hls --hls-master-playlist-name=media.m3u8 --hls-media-playlist-name=media.m3u8  --hls-iframes-playlist-name=iframe.m3u8 --profiles=live --use-segment-template-number-padding %list%

echo. && echo Adaptive Bitrate Streams complete, all streams were packaged in mpd/, press any key to exit...

pause > nul

exit /b
=======
@echo off

REM Check if mpd directory exists
if not exist "mpd" mkdir "mpd" && goto Stream

rmdir "mpd" /s /q && mkdir "mpd"

:Stream

echo Ready to package files for streaming, press any key to continue...

pause > nul

echo.

REM Create Dash and HLS content
REM Store input files as space separated array in a variable
setlocal enabledelayedexpansion enableextensions
set list=
for %%x in (fmp4\*) do set list=!list! %%x
set list=%list:~1%

REM YouTube use the Live Profile
REM mp4dash closes the batch on completion so is called in a new shell
cmd /c mp4dash --verbose --output-dir=mpd --force --mpd-name=stream.mpd --hls --hls-master-playlist-name=stream.m3u8 --hls-media-playlist-name=media.m3u8  --hls-iframes-playlist-name=iframe.m3u8 --profiles=live --use-segment-template-number-padding %list%

echo. && echo Adaptive Bitrate Streams complete, all streams were packaged in mpd/, press any key to exit...

pause > nul

exit /b
>>>>>>> 1307abd0f5b8059d9ab697a10e3671557f2fc6ca
