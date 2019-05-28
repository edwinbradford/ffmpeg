# ffshell
ffshell is a collection of shell scripts that re-encode media using FFmpeg. They have been tested on macOS and Windows and should work on Unix. Windows users need to install bash either by installing Git Bash or Windows Subsystem for Linux (WSL) on Windows 10.

The scripts are:

crf.sh\
dnxhd.sh\
ffv1.sh \
fmp4.sh\
fps.sh\
prores.sh

crf.sh\
Encodes media as H264 using a Constant Rate Factor (CRF) prioritising quality over bitrate. This script is suitable for generating online videos that will be self hosted or uploaded to a video platform such as YouTube.

dnxhd.sh\
Encodes media using the intraframe (spatial) industry standard and open source DNxHD codec. Use this script for saving media in a high quality cross platform format intended for importing into a video editor. Media is saved in natively cross platform mxf format using the DNxHD 90 preset which is 1080p and 60 fps.

fmp4.sh\
Encodes media as fragmented mp4 (fmp4) and packages it for adaptive bitrate streaming as MPEG-DASH and HLS streams. Currently the streams validate but do not play back with consistent results in MPEG-DASH and HLS players. I'm unable to find any errors and therefore put the inconsistency down to fmp4 streaming being at an early stages of development.

fps.sh\
Designed to re-encode Variable Frame Rate (VFR) media with a Constant Frame Rate (CFR) maintain audio sync and save it as an mp4. This script is helpful if you are having green or missing frames issues with Variable Frame Rate source media.

ffv1.sh\
Encodes media with a lossless FFV1 codec and saves it in the open source and cross platform mkv matroska container.

prores.sh\
Encodes media using Apple's intraframe (spatial) ProRes family of codecs and saves it in an Apple mov container. As with dnxhd.sh above this script is intended for saving media in a high quality intraframe (spatial) format intended for importing into a video editor. DNxHD has now become the standard format for broadcast media but Apple ProRes is still common. 
