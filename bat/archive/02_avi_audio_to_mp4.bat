@echo off

REM Jump to this directory
pushd "%~dp0"

REM Title
echo. && echo Make mp4 && echo.

set /p input="Drag and drop an Avisynth (.avs) file into this window and press enter: "
echo.

REM check if filetyype is .avs
setlocal
FOR %%i IN ("%input%") DO (
if %%~xi==.avs goto framerate
)
endlocal

echo. && echo Oops, not an Avisynth file. && echo.

goto source

:framerate

echo Encoding 128k audio
echo.

REM -y (overwrite) -i (input) -vn (ignore video) -metadata:s:a:0 language=eng (metadata stream audio channel 0 language) -profile:a (profile audio) -ac (audio channels) -b:a (bitrate audio)
ffmpeg -y -i %input% -vn -metadata:s:a:0 language=eng -profile:a aac_low -ac 2 -b:a 128k mp4/aac_lc_128k.mp4
echo.

echo Encoded audio to aac_lc_128k mp4. && echo.

echo All encoding completed, press any key to exit...

pause > nul

exit /b
