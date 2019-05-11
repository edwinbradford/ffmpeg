@echo off

REM See https://developer.apple.com/streaming/examples/ for bitrate values

REM Jump to this directory
pushd "%~dp0"

REM Title
echo. && echo fmp4 audio encoder && echo.

REM Check if FFmpeg exists
for %%x in (ffmpeg.exe) do if not [%%~$PATH:x]==[] goto source

echo Can't find FFmpeg. Press any key to exit...
echo.

pause > nul

exit /b

:source

REM Empty space after %BS% is displayed in console
set /p input="Drag and drop an Avisynth or audio file into this window and press enter: "

if exist %input% echo. && goto encode

if not exist %input% echo. && echo Input file does not exist && echo.

goto source

:encode

if exist "mp4" echo mp4 directory already exists. Files with the same name will be overwritten. && echo. && pause && echo.

if not exist "mp4" mkdir "mp4"

echo Encoding 128k audio
echo.

REM -y (overwrite) -i (input) -vn (ignore video) -metadata:s:a:0 language=eng (metadata stream audio channel 0 language) -profile:a (profile audio) -ac (audio channels) -b:a (bitrate audio)
ffmpeg -y -i %input% -vn -metadata:s:a:0 language=eng -profile:a aac_low -ac 2 -b:a 128k mp4/aac_lc_128k.mp4
echo.

echo Press any key to exit...

pause > nul

exit /b
