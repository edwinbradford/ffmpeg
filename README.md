# ffshell
ffshell is a collection of bash shell scripts that re-encode media with FFmpeg. They have been tested on macOS and Windows and should work on Unix. Windows users need to install bash to run the scripts.

The scripts are:

crf.sh\
dnxhd.sh\
fmp4.sh\
fps.sh

fmp4.sh\
Encodes media as fragmented mp4 (fmp4) and packages it for adaptive bitrate streaming as MPEG-DASH and HLS streams. Currently the streams validate but do not play back with consistent results in MPEG-DASH and HLS players. I'm unable to find any errors and put the inconsistency down to one or more bugs somewhere between ffmpeg and the media players.

crf.sh\
Encodes media as H264 using a Constant Rate Factor (CRF) prioritising quality over bitrate. This script is suitable for generating online videos that will be self hosted or uploaded to a video platform such as YouTube. Four preset resolutions are included: 1080p, 720p, 480p and 360p.

fps.sh\
Re-encodes Variable Frame Rate (VFR) media as Constant Frame Rate (CFR) media whilst maintaining audio sync. This script is helpful if you are having issues when editing VFR media such as green or missing frames.

dnxhd.sh\
Encodes media using the intraframe (spatial) industry standard and open source codec DNxHD. This script is helpful for saving video in a cross platform format intended for video editing. The current version of this script uses DNxHD 90 which creates 1080p media at 60 frames per second. Files are saved in the cross platform mxf format.
