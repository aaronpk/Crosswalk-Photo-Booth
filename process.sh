#!/bin/bash

crosswalks=(crosswalks/*.jpg)

if ls 1-inbox/*.JPG >/dev/null 2>&1
then

  for fn in 1-inbox/*.JPG
  do
    fn=$(basename $fn)
    echo Processing: $fn
    crosswalk="${crosswalks[RANDOM % ${#crosswalks[@]}]}"

    # Back up the original photo
    cp 1-inbox/$fn original/$fn

    # crop and resize
    echo "  cropping and resizing"
    # crop: WxH+x+y (width x height + offset x + offset y)
    convert 1-inbox/$fn -crop '1358x1440+272+0' -resize `cat "$crosswalk".size` 2-resized/$fn   #-resize 3000x1100 2-resized/$fn

    # adjust contrast and make grayscale
    echo "  converting to grayscale"
    mogrify -type Grayscale -path 3-grayscale -normalize -brightness-contrast -10x30 2-resized/$fn
    rm 2-resized/$fn

    # vignette
    echo "  vignette"
    convert 3-grayscale/$fn -background black -vignette 50x6500 4-vignette/$fn
    rm 3-grayscale/$fn

    # tint to green
    echo "  tinting green"
    mogrify -path 5-green +level-colors ,Lime 4-vignette/$fn
    rm 4-vignette/$fn

    # stained glass
    echo "  applying stained glass effect"
    ./stainedglass -k hexagon -b 100 -t 1 -s 8 5-green/$fn 6-stained-glass/$fn
    rm 5-green/$fn
    
    # composite over the crosswalk sign
    # choose a random base image
    echo "  compositing over $crosswalk"
    composite -compose Screen -gravity northwest -geometry `cat "$crosswalk".offset` 6-stained-glass/$fn $crosswalk 7-composited/$fn
    rm 6-stained-glass/$fn

    # queue for upload
    echo "  queuing for upload"
    mv 7-composited/$fn 8-outbox/$fn
    rm 1-inbox/$fn
  done

  # upload everything to flickr
  ruby flickr-uploader/flickr-uploader.rb -u 8-outbox/ --photoset-id 72157648551257797 -p

else
  exit 1
fi

