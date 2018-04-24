#!/bin/bash

# create transparent PNG files containing one line of text in the bottom
# (also with shadow and outline) to use with Openshot video editor as
# mixed-in subtitles
#
XSIZE=1280
YSIZE=720
PSIZE=64   # character font size
SSIZE=5    # shadow distance
OKCMD="ls -l"
FONT="-weight bold"

# Japanese font, if needed, has to be explicitly specified
#FONT="$FONT -font /usr/share/fonts/truetype/hanazono/HanaMinA.ttf"
FONT="$FONT -font /usr/share/fonts/truetype/dejima-mincho/dejima-mincho-r227.ttf"

out=1
while read msg
do
  if [ "$msg" != "" ]
  then
    fname=`printf lettering%02d.png $out`
    convert -size $XSIZE"x"$YSIZE xc:none -fill transparent -gravity center   \
      -gravity south -stroke blue -fill yellow -pointsize $PSIZE              \
      -encoding utf-8 $FONT -annotate 0 "$msg" -background none               \
      -shadow $XSIZE"x"$SSIZE+0+0 xc:none $FONT -composite -pointsize $PSIZE  \
      -annotate 0 "$msg" $fname
    $OKCMD $fname
    out=$[$out + 1]
  fi
done

