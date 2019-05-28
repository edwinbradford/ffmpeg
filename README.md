# ffshell
ffshell is a collection of shell scripts that re-encode media using FFmpeg. They have been tested on macOS and Windows and should work on Unix. Windows users need to install bash either by installing Git Bash or Windows Subsystem for Linux (WSL) on Windows 10.

The scripts are:

crf.sh\
dnxhd.sh\
fmp4.sh\
fps.sh\
ffv1.sh

crf.sh\
Encodes media as H264 using a Constant Rate Factor (CRF) prioritising quality over bitrate. This script is suitable for generating online videos that will be self hosted or uploaded to a video platform such as YouTube.

dnxhd.sh\
Encodes media using the intraframe (spatial) industry standard and open source DNxHD codec. Use this script for saving media in a high quality cross platform format intended for importing into a video editor. The current version of this script uses the DNxHD 90 preset which creates media at 1080p and 60 frames per second. The compressed media is saved as mxf files which are natively cross platform.

fmp4.sh\
Encodes media as fragmented mp4 (fmp4) and packages it for adaptive bitrate streaming as MPEG-DASH and HLS streams. Currently the streams validate but do not play back with consistent results in MPEG-DASH and HLS players. I'm unable to find any errors and therefore put the inconsistency down to fmp4 streaming being at an early stages of development.

fps.sh\
Re-encodes Variable Frame Rate (VFR) media at a Constant Frame Rate (CFR) whilst maintaining audio sync. This script is helpful if you are having issues such as green or missing frames when editing media encoded with a VFR.

ffv1.sh\
Encodes media with a lossless FFV1 codec and saves it in an open source cross platform matroska container.
