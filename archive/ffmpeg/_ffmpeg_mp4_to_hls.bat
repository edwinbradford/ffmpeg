@echo off

REM Jump to this directory
pushd "%~dp0"

REM Title
echo. && echo FFmpeg HLS && echo.

if exist "mp4" goto initialized

REM Check if mp4 directory exists
if not exist "mp4" echo Can not find the source 'mp4' directory, please run the add video batch file before this one. && echo. && echo Press any key to exit...
echo.

pause > nul

exit /b

:initialized

REM Delete old temp files and create temp folder
if exist "ffmpeg" rmdir "ffmpeg" /s /q
mkdir "ffmpeg"

echo Ready to fragment mp4 files, press any key to continue... && echo.

pause > nul

REM Fragment mp4 files
for %%f in (mp4\*.*) do (
  ffmpeg -i %%f -start_number 0 -hls_time 2 -hls_list_size 0 -hls_segment_type fmp4 -f hls ffmpeg/media.m3u8
)

echo. && echo All processes complete, press any key to exit...

pause > nul

exit /b
