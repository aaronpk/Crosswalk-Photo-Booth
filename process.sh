crosswalks=(crosswalks/*.jpg)

for fn in "1-inbox/*.jpg"
do
  fn=$(basename $fn)
  echo Processing: $fn

  # Back up the original photo
  cp 1-inbox/$fn original/$fn

  # 1->2 adjust contrast and make grayscale
  echo "  converting to grayscale"
  mogrify -type Grayscale -path 2-grayscale -normalize -brightness-contrast 0x30 1-inbox/$fn

  # 2->3 tint to green
  echo "  tinting green"
  mogrify -path 3-green +level-colors ,Lime 2-grayscale/$fn
  rm 2-grayscale/$fn

  # 3->4 resize
  echo "  resizing"
  convert 3-green/$fn -resize 3000x680 4-resized/$fn
  rm 3-green/$fn

  # 4->5 stained glass
  echo "  applying stained glass effect"
  ./stainedglass -k hexagon -b 100 -t 1 -s 7 4-resized/$fn 5-stained-glass/$fn
  rm 4-resized/$fn

  # 5->6 composite over the crosswalk sign
  # choose a random base image
  crosswalk="${crosswalks[RANDOM % ${#crosswalks[@]}]}"
  echo "  compositing over $crosswalk"
  composite -compose Screen -gravity center 5-stained-glass/$fn $crosswalk 6-composited/$fn
  rm 5-stained-glass/$fn

  # 6->7 queue for upload
  echo "  queuing for upload"
  mv 6-composited/$fn 7-outbox/$fn
done

# upload everything to flickr
ruby flickr-uploader/flickr-uploader.rb -u 7-outbox/ --photoset-id 14987733734 -p
