#/bin/bash

. ./colors.sh

for ((i=1; i<16; i++)); do
  output="../textures/maidroid_maidroid_mk${i}_egg.png"
  color=${arr[i]}
  convert +level-colors $color,White img/maidroid_egg_pattern.png img/maidroid_egg_pattern_tmp.png
  composite img/maidroid_egg_pattern_tmp.png img/maidroid_empty_egg.png $output

  rm img/maidroid_egg_pattern_tmp.png
done
