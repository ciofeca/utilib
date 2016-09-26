#!/bin/sh

INPUTFILE=/media/ubuntuser/movies/random_scaring_scifi_movie.mkv

OUTPUTFILE=movie-for-surface-rt.mp4

SKIPSTARTSECONDS="-ss 120"

RESIZE="-s 1366x768"   #"-s 1366x576"

BITRATEVIDEOAUDIO="-b:v 1800k -b:a 192k"

ffmpeg $SKIPSTARTSECONDS -i $INPUTFILE $RESIZE $BITRATEVIDEOAUDIO -vcodec h264 -acodec libmp3lame $OUTPUTFILE

