#!/bin/sh

mergedListFile="/scripts/docker/merged_list_file.sh"
shareCodesUrl="https:\/\/pd.zwc365.com\/seturl\/https:\/\/raw.githubusercontent.com\/Aaron-lv\/updateTeam\/master\/shareCodes\\"
shareCodesCfd="$shareCodesUrl/cfd.json"
shareCodeszz="$shareCodesUrl/jd_zz.json"
shareCodesCash="$shareCodesUrl/jd_updateCash.json"
shareCodesBeanHome="$shareCodesUrl/jd_updateBeanHome.json"
shareCodesFactoryTuanId="$shareCodesUrl/jd_updateFactoryTuanId.json"
shareCodesSmallHomeInviteCode="$shareCodesUrl/jd_updateSmallHomeInviteCode.json"

if [[ -f /usr/bin/jd_bot && -z "$DISABLE_SPNODE" ]]; then
   CMD="spnode"
else
   CMD="node"
fi

echo "处理jd_crazy_joy_coin任务..."
if [ ! $CRZAY_JOY_COIN_ENABLE ]; then
   echo "默认启用jd_crazy_joy_coin,杀掉jd_crazy_joy_coin任务，并重启"
   eval $(ps -ef | grep "jd_crazy_joy_coin" | grep -v "grep" | awk '{print "kill "$1}')
   echo '' >/scripts/logs/jd_crazy_joy_coin.log
   $CMD /scripts/jd_crazy_joy_coin.js |ts >>/scripts/logs/jd_crazy_joy_coin.log 2>&1 &
   echo "默认jd_crazy_joy_coin,重启完成"
else
   if [ $CRZAY_JOY_COIN_ENABLE = "Y" ]; then
      echo "配置启用jd_crazy_joy_coin,杀掉jd_crazy_joy_coin任务，并重启"
      eval $(ps -ef | grep "jd_crazy_joy_coin" | grep -v "grep" | awk '{print "kill "$1}')
      echo '' >/scripts/logs/jd_crazy_joy_coin.log
      $CMD /scripts/jd_crazy_joy_coin.js |ts >>/scripts/logs/jd_crazy_joy_coin.log 2>&1 &
      echo "配置jd_crazy_joy_coin,重启完成"
   else
      eval $(ps -ef | grep "jd_crazy_joy_coin" | grep -v "grep" | awk '{print "kill "$1}')
      echo "已配置不启用jd_crazy_joy_coin任务,不处理"
   fi
fi


## 修改京喜财富岛定时
sed -i "/jd_cfd.js/s/$(sed "s/\*/\\\*/g" $mergedListFile | sed "s/\//\\\\\//g" | grep jd_cfd.js | awk '{print $1,$2,$3,$4,$5}')/10 *\/2 * * */g" $mergedListFile
## 修改闪购盲盒定时
sed -i "/jd_sgmh.js/s/$(sed "s/\*/\\\*/g" $mergedListFile | sed "s/\//\\\\\//g" | grep jd_sgmh.js | awk '{print $1,$2,$3,$4,$5}')/55 8,23 * * */g" $mergedListFile
## 修改京东家庭号定时
sed -i "/jd_family.js/s/$(sed "s/\*/\\\*/g" $mergedListFile | sed "s/\//\\\\\//g" | grep jd_family.js | awk '{print $1,$2,$3,$4,$5}')/30 6,15 * * */g" $mergedListFile
## 修改美丽颜究院定时
sed -i "/jd_beauty.js/s/$(sed "s/\*/\\\*/g" $mergedListFile | sed "s/\//\\\\\//g" | grep jd_beauty.js | awk '{print $1,$2,$3,$4,$5}')/30 8,13,20 * * */g" $mergedListFile
## 修改口袋书店定时
sed -i "/jd_bookshop.js/s/$(sed "s/\*/\\\*/g" $mergedListFile | sed "s/\//\\\\\//g" | grep jd_bookshop.js | awk '{print $1,$2,$3,$4,$5}')/20 8,12,18 * * */g" $mergedListFile
## 修改东东小窝定时
sed -i "/jd_small_home.js/s/$(sed "s/\*/\\\*/g" $mergedListFile | sed "s/\//\\\\\//g" | grep jd_small_home.js | awk '{print $1,$2,$3,$4,$5}')/33 6,23 * * */g" $mergedListFile
## 修改京喜工厂定时
sed -i "/jd_dreamFactory.js/s/$(sed "s/\*/\\\*/g" $mergedListFile | sed "s/\//\\\\\//g" | grep jd_dreamFactory.js | awk '{print $1,$2,$3,$4,$5}')/45 * * * */g" $mergedListFile
## 修改取关京东店铺商品定时
sed -i "/jd_unsubscribe.js/s/$(sed "s/\*/\\\*/g" $mergedListFile | sed "s/\//\\\\\//g" | grep jd_unsubscribe.js | awk '{print $1,$2,$3,$4,$5}')/45 *\/6 * * */g" $mergedListFile
## 修改京东极速版红包定时
sed -i "/jd_speed_redpocke.js/s/$(sed "s/\*/\\\*/g" $mergedListFile | sed "s/\//\\\\\//g" | grep jd_speed_redpocke.js | awk '{print $1,$2,$3,$4,$5}')/15 0,23 * * */g" $mergedListFile

## 清理日志
sed -i "s/find.*$/find \/scripts\/logs -name '\*.log' \| grep -v 'sharecodeCollection' \| xargs -i rm -rf {}/g" $mergedListFile

## 超级直播间
sed -i "/jd_live_redrain.js/s/^.*$/#&/g" $mergedListFile
if [ "$(date +%-H)" == "23" ]; then
   sed -i "/jd_super_redrain.js/s/$(sed "s/\*/\\\*/g" $mergedListFile | sed "s/\//\\\\\//g" | grep jd_super_redrain.js | awk '{print $1,$2,$3,$4,$5}')/0,1 0-23\/1 * * */g" $mergedListFile
fi

## 赚京豆
sed -i "s/https:\/\/a.nz.lu\/jd_zz.json/$shareCodeszz/g" /scripts/jd_syj.js
sed -i "s/https:\/\/raw.githubusercontent.com\/gitupdate\/updateTeam\/master\/shareCodes\/jd_zz.json/$shareCodeszz/g" /scripts/jd_syj.js
## 京喜财富岛
sed -i "s/https:\/\/cdn.jsdelivr.net\/gh\/gitupdate\/updateTeam@master\/shareCodes\/cfd.json/$shareCodesCfd/g" /scripts/jd_cfd.js
sed -i "s/https:\/\/raw.githubusercontent.com\/gitupdate\/updateTeam\/master\/shareCodes\/cfd.json/$shareCodesCfd/g" /scripts/jd_cfd.js
## 签到领现金
sed -i "s/\`eU9YL5XqGLxSmRSAkwxR@eU9YaO7jMvwh-W_VzyUX0Q@.*$/\`aUNmM6_nOP4j-W4@eU9Yau3kZ_4g-DiByHEQ0A@eU9YaOvnM_4k9WrcnnAT1Q@eU9Yar-3M_8v9WndniAQhA@f0JyJuW7bvQ@IhM0bu-0b_kv8W6E@eU9YKpnxOLhYtQSygTJQ@-oaWtXEHOrT_bNMMVso@eU9YG7XaD4lXsR2krgpG\`,/g" /scripts/jd_cash.js
sed -i "s/\`-4msulYas0O2JsRhE-2TA5XZmBQ@.*$/\`aUNmM6_nOP4j-W4@eU9Yau3kZ_4g-DiByHEQ0A@eU9YaOvnM_4k9WrcnnAT1Q@eU9Yar-3M_8v9WndniAQhA@f0JyJuW7bvQ@IhM0bu-0b_kv8W6E@eU9YKpnxOLhYtQSygTJQ@-oaWtXEHOrT_bNMMVso@eU9YG7XaD4lXsR2krgpG\`,/g" /scripts/jd_cash.js
sed -i "s/https:\/\/a.nz.lu\/jd_cash.json/$shareCodesCash/g" /scripts/jd_cash.js
sed -i "s/https:\/\/cdn.jsdelivr.net\/gh\/gitupdate\/updateTeam@master\/shareCodes\/jd_updateCash.json/$shareCodesCash/g" /scripts/jd_cash.js
## 领京豆
sed -i "s/https:\/\/a.nz.lu\/bean.json/$shareCodesBeanHome/g" /scripts/jd_bean_home.js
sed -i "s/https:\/\/cdn.jsdelivr.net\/gh\/gitupdate\/updateTeam@master\/shareCodes\/jd_updateBeanHome.json/$shareCodesBeanHome/g" /scripts/jd_bean_home.js
## 京喜工厂
sed -i "s/https:\/\/a.nz.lu\/factory.json/$shareCodesFactoryTuanId/g" /scripts/jd_dreamFactory.js
sed -i "s/https:\/\/raw.githubusercontent.com\/gitupdate\/updateTeam\/master\/shareCodes\/jd_updateFactoryTuanId.json/$shareCodesFactoryTuanId/g" /scripts/jd_dreamFactory.js
sed -i "s/https:\/\/cdn.jsdelivr.net\/gh\/gitupdate\/updateTeam@master\/shareCodes\/jd_updateFactoryTuanId.json/$shareCodesFactoryTuanId/g" /scripts/jd_dreamFactory.js
## 东东小窝
sed -i "s/https:\/\/cdn.jsdelivr.net\/gh\/gitupdate\/updateTeam@master\/shareCodes\/jd_updateSmallHomeInviteCode.json/$shareCodesSmallHomeInviteCode/g" /scripts/jd_small_home.js
sed -i "s/https:\/\/raw.githubusercontent.com\/LXK9301\/updateTeam\/master\/jd_updateSmallHomeInviteCode.json/$shareCodesSmallHomeInviteCode/g" /scripts/jd_small_home.js
## 口袋书店
sed -i "s/'28a699ac78d74aa3b31f7103597f8927@.*$/'6f46a1538969453d9a730ee299f2fc41@3ad242a50e9c4f2d9d2151aee38630b1',/g" /scripts/jd_bookshop.js
