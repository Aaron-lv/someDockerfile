#!/usr/bin/env bash

mergedListFile="/scripts/docker/merged_list_file.sh"

## 修改京东家庭号定时
sed -i "/jd_family.js/s/$(sed "s/\*/\\\*/g" $mergedListFile | sed "s/\//\\\\\//g" | grep jd_family.js | awk '{print $1,$2,$3,$4,$5}')/30 6,15 * * */g" $mergedListFile
## 修改美丽颜究院定时
sed -i "/jd_beauty.js/s/$(sed "s/\*/\\\*/g" $mergedListFile | sed "s/\//\\\\\//g" | grep jd_beauty.js | awk '{print $1,$2,$3,$4,$5}')/30 8,13,20 * * */g" $mergedListFile
## 修改口袋书店定时
sed -i "/jd_bookshop.js/s/$(sed "s/\*/\\\*/g" $mergedListFile | sed "s/\//\\\\\//g" | grep jd_bookshop.js | awk '{print $1,$2,$3,$4,$5}')/20 8,12,18 * * */g" $mergedListFile
## 修改东东小窝定时
sed -i "/jd_small_home.js/s/$(sed "s/\*/\\\*/g" $mergedListFile | sed "s/\//\\\\\//g" | grep jd_small_home.js | awk '{print $1,$2,$3,$4,$5}')/33 6,23 * * */g" $mergedListFile
## 修改取关京东店铺商品定时
sed -i "/jd_unsubscribe.js/s/$(sed "s/\*/\\\*/g" $mergedListFile | sed "s/\//\\\\\//g" | grep jd_unsubscribe.js | awk '{print $1,$2,$3,$4,$5}')/45 *\/6 * * */g" $mergedListFile

## 清理日志
sed -i "s/find.*$/find \/scripts\/logs -name '\*.log' \| grep -v 'sharecodeCollection' \| xargs -i rm -rf {}/g" $mergedListFile

## 超级直播间
sed -i "/jd_live_redrain.js/s/^.*$/# &/g" $mergedListFile
if [ "$(date +%-H)" == "23" ]; then
   sed -i "/jd_super_redrain.js/s/$(sed "s/\*/\\\*/g" $mergedListFile | sed "s/\//\\\\\//g" | grep jd_super_redrain.js | awk '{print $1,$2,$3,$4,$5}')/0,1 0-23\/1 * * */g" $mergedListFile
fi
