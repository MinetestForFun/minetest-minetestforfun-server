#/bin/bash

. ./colors.sh

for ((i=1; i<16; i++)); do
  type=$(($i % 3 + 1))
  maidroid_type="img/maidroid_type${type}.png"

  output="../models/maidroid_maidroid_mk${i}.png"
  color=${arr[i]}
  convert +level-colors $color,White img/maidroid_hair.png img/maidroid_hair_tmp.png
  composite img/maidroid_hair_tmp.png $maidroid_type $output

  rm img/maidroid_hair_tmp.png
done
