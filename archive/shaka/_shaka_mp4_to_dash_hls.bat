@echo off

REM Jump to this directory
pushd "%~dp0"

REM Title
echo. && echo Shaka MPD M3U8 && echo.

if exist "mp4" goto initialized

REM Check if mp4 directory exists
if not exist "mp4" echo Can not find the source 'mp4' directory, please run the add video batch file before this one. && echo. && echo Press any key to exit...
echo.

pause > nul

exit /b

:initialized

REM Delete old temp files and create temp folder
if exist "fmp4" rmdir "fmp4" /s /q
mkdir "fmp4"

echo Ready to package mp4 files, press any key to continue... && echo.

pause > nul

set k00128="aac_lc_128k"
set k01000="h264_360p_01000k"
set k02000="h264_540p_02000k"
set k03000="h264_720p_03000k"
set k04000="h264_1080p_04000k"
set k05000="h264_1080p_05000k"
set k06000="h264_1080p_06000k"

REM Package mp4
packager-win ^
in=mp4/%k00128%.mp4,stream=audio,output=fmp4/%k00128%.mp4,playlist_name=audio.m3u8,hls_group_id=audio,hls_name=ENGLISH ^
in=mp4/%k01000%.mp4,stream=video,output=fmp4/%k01000%.mp4,playlist_name=%k01000%.m3u8,iframe_playlist_name=%k01000%_iframe.m3u8 ^
in=mp4/%k02000%.mp4,stream=video,output=fmp4/%k02000%.mp4,playlist_name=%k02000%.m3u8,iframe_playlist_name=%k02000%_iframe.m3u8 ^
in=mp4/%k03000%.mp4,stream=video,output=fmp4/%k03000%.mp4,playlist_name=%k03000%.m3u8,iframe_playlist_name=%k03000%_iframe.m3u8 ^
in=mp4/%k04000%.mp4,stream=video,output=fmp4/%k04000%.mp4,playlist_name=%k04000%.m3u8,iframe_playlist_name=%k04000%_iframe.m3u8 ^
in=mp4/%k05000%.mp4,stream=video,output=fmp4/%k05000%.mp4,playlist_name=%k05000%.m3u8,iframe_playlist_name=%k05000%_iframe.m3u8 ^
in=mp4/%k06000%.mp4,stream=video,output=fmp4/%k06000%.mp4,playlist_name=%k06000%.m3u8,iframe_playlist_name=%k06000%_iframe.m3u8 ^
--hls_master_playlist_output fmp4/media.m3u8 ^
--mpd_output fmp4/media.mpd

echo. && echo Press any key to exit...

pause > nul

exit /b
