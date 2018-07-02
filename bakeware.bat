@echo off

REM Jump to this directory
pushd "%~dp0"

echo. && echo %cd% && echo.

REM Title
echo This batch file encodes video into fmp4 format and generates the MPEG DASH and HLS streams. && echo.

REM Check if FFmpeg exists
for %%x in (ffmpeg.exe) do if not [%%~$PATH:x]==[] goto Python

echo Can't find FFmpeg, install FFmpeg then try again, press any key to exit...
echo.

pause > nul

exit /b

:Python

REM Check if Python exists
for %%x in (python.exe) do if not [%%~$PATH:x]==[] goto Initialized

echo Can't find Python, install Python then try again, press any key to exit...
echo.

pause > nul

exit /b

:Initialized

REM Use the next line for debugging when the first batch file is not called
REM set fragment="2"

REM Call batch files one after the other and pass the fragment variable from the first to the second
call bat/fmp4/_ffmpeg_scenecut.bat
call bat/fmp4/_bento4_mp4_to_fmp4.bat %fragment%
call bat/fmp4/_bento4_fmp4_to_mpd_m3u8.bat
