@echo off

REM Jump to this directory
pushd "%~dp0"

echo. && echo %cd% && echo.

REM Title
echo This batch file encodes video to mp4 format for progressive download. && echo.

REM Check if FFmpeg exists
for %%x in (ffmpeg.exe) do if not [%%~$PATH:x]==[] goto Source

echo Can't find FFmpeg, install FFmpeg then try again, press any key to exit...
echo.

pause > nul

exit /b


:Source

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

echo. && echo Ready to encode the source file at 1080p, press any key to continue... && echo.

pause > nul

goto 1080p

:m720p

echo. && echo Ready to encode the source file at 720p, press any key to continue... && echo.

pause > nul

goto 720p

:m480p

echo. && echo Ready to encode the source file at 480p, press any key to continue... && echo.

pause > nul

goto 480p

:m360p

echo. && echo Ready to encode the source file at 360p, press any key to continue... && echo.

pause > nul

goto 360p

:1080p

md "mp4\1080p"

echo Encoding 1080p && echo.
ffmpeg -i %input% ^
-movflags +faststart ^
-metadata:s:v:0 language=eng ^
-metadata:s:a:0 language=eng ^
-r %framerate% ^
-c:v libx264 ^
-crf 20 ^
-preset slow ^
-vf "scale=-2:1080" ^
-profile:a aac_low -ac 2 -b:a 160k ^
-y mp4/1080p/media.mp4
echo.

goto Finished

:720p

md "mp4\720p"

echo Encoding 720p && echo.
ffmpeg -i %input% ^
-movflags +faststart ^
-metadata:s:v:0 language=eng ^
-metadata:s:a:0 language=eng ^
-r %framerate% ^
-c:v libx264 ^
-crf 20 ^
-preset slow ^
-vf "scale=-2:720" ^
-profile:a aac_low -ac 2 -b:a 160k ^
-y mp4/720p/media.mp4
echo.

goto Finished

:480p

md "mp4\480p"

echo Encoding 480p && echo.
ffmpeg -i %input% ^
-movflags +faststart ^
-metadata:s:v:0 language=eng ^
-metadata:s:a:0 language=eng ^
-r %framerate% ^
-c:v libx264 ^
-crf 20 ^
-preset slow ^
-vf "scale=-2:480" ^
-profile:a aac_low -ac 2 -b:a 160k ^
-y mp4/480p/media.mp4
echo.

goto Finished

:360p

md "mp4\360p"

echo Encoding 360p && echo.
ffmpeg -i %input% ^
-movflags +faststart ^
-metadata:s:v:0 language=eng ^
-metadata:s:a:0 language=eng ^
-r %framerate% ^
-c:v libx264 ^
-crf 20 ^
-preset slow ^
-vf "scale=-2:360" ^
-profile:a aac_low -ac 2 -b:a 160k ^
-y mp4/360p/media.mp4
echo.

:Finished

echo Finished encoding the source file to mp4/. Press any key to exit... && echo.

pause > nul

exit /b
