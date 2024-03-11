#!/usr/local/bin/bash

BRAIN_PATH="$HOME/second-brain"
IMG_STORE="$HOME/public-brain/assets/images"
IMG_STORE_NAME="/images"

find $BRAIN_PATH -type f -name "pub-*.md" -exec cp {} ~/public-brain/content/posts/ \;

# For each post file in public-brain/content/posts get the image path and copy it to public-brain/static/images.
# Then replace the image path in the post file with the new path.

for file in ~/public-brain/content/posts/pub-*.md; do
  echo "Processing $file"
  images=$(cat ${file} | grep -E '!\[.*\(.*assets/.*' | grep -o "/.*.png\|/.*.jpeg\|/.*.jpg")
  for img_path in $images; do
    echo $img_path
    img_name=$(basename $img_path)
    echo "BASENAME: $img_name"
    cp ${img_path} ${IMG_STORE}/${img_name}
    sed -i "s|${img_path}|${IMG_STORE_NAME}/${img_name}|g" $file
  done
done
