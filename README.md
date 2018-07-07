# Bakeware
Bakeware is a set of Windows batch files that will encode media in fragmented mp4 format then package it for streaming as MPEG DASH and HLS. Hopefully in the future Apple will finally support MPEG DASH and it will not no longer be necessary to package HLS just for Apple devices.

I apologize that Bakeware only runs on Windows. If I was starting the project again I'd write it in a format that runs in a unix shell but when I started the project I didn't want to have to rely on a Unix environment like Cygwin.

To use Bakeware download the directory to wherever you want to store your media then launch the bakeware.bat file which will call other batch files and tools as necessary. Bakeware requires Python, Bento4, FFmpeg and probably other tools too. It should warn you if you are missing a required package before attempting the next stage.

This project was never designed to be a publicly available toolset but it works for me locally and you're welcome to use it as you feel fit.
