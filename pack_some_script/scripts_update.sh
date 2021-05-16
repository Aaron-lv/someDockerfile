#!/bin/sh

mergedListFile="/pss/pack_some_script/merged_list_file.sh"

##喜马拉雅极速版
function initxmly() {
    mkdir /xmly_speed
    cd /xmly_speed
    git init
    git remote add origin https://github.com/Zero-S1/xmly_speed
    git config core.sparsecheckout true
    echo rsa >>/xmly_speed/.git/info/sparse-checkout
    echo xmly_speed.py >>/xmly_speed/.git/info/sparse-checkout
    echo requirements.txt >>/xmly_speed/.git/info/sparse-checkout
    git pull origin master --rebase
    pip3 install --upgrade pip
    pip3 install -r requirements.txt
}

##火山极速版
function inithotsoon() {
    mkdir /hotsoon
    cd /hotsoon
    git init
    git remote add origin https://github.com/Ariszy/Private-Script
    git config core.sparsecheckout true
    echo Scripts/hotsoon_old.js >>/hotsoon/.git/info/sparse-checkout
    git pull origin master --rebase
    wget -O /hotsoon/package.json https://pd.zwc365.com/seturl/https://raw.githubusercontent.com/Aaron-lv/sync/JavaScript/package.json
    npm install
}

##ZIYE_JavaScript
function initziye {
    mkdir /ZIYE_JavaScript
    cd /ZIYE_JavaScript
    git init
    git remote add origin https://github.com/Aaron-lv/sync
    git config core.sparsecheckout true
    echo package.json >>/ZIYE_JavaScript/.git/info/sparse-checkout
    echo Task/*.js >>/ZIYE_JavaScript/.git/info/sparse-checkout
    git pull origin JavaScript --rebase
    npm install
}

##判断小米运动相关变量存在，才会更新相关任务脚本
if [ 0"$XMYD_USER" = "0" ]; then
    echo "没有配置小米运动，相关环境变量参数，跳过配置定时任务"
else
    if [ ! -d "/xmSports/" ]; then
        echo "未检查到xmSports脚本相关文件，初始化下载相关脚本"
        git clone https://github.com/FKPYW/mimotion /xmSports
    else
        echo "更新xmSports脚本相关文件"
        git -C /xmSports reset --hard
        git -C /xmSports pull origin main --rebase
    fi
    if [ 0"$XM_CRON" = "0" ]; then
        XM_CRON="10 22 * * *"
    fi
    echo "#小米运动刷步数" >>$mergedListFile
    echo "$XM_CRON python3 /xmSports/main.py >> /logs/xmSports.log 2>&1" >>$mergedListFile
fi

##判断喜马拉雅极速版相关变量存在，才会更新相关任务脚本
if [ 0"$XMLY_SPEED_COOKIE" = "0" ]; then
    echo "没有配置喜马拉雅极速版，相关环境变量参数，跳过下载配置定时任务"
else
    if [ ! -d "/xmly_speed/" ]; then
        echo "未检查到xmly_speed脚本相关文件，初始化下载相关脚本"
        initxmly
    else
        echo "更新xmly_speed脚本相关文件"
        git -C /xmly_speed reset --hard
        git -C /xmly_speed pull origin master --rebase
        cd /xmly_speed
        pip3 install -r requirements.txt
    fi
    wget -O /xmly_speed/util.py https://pd.zwc365.com/seturl/https://raw.githubusercontent.com/whyour/hundun/master/quanx/util.py
    wget -O /xmly_speed/xmly_speed.py https://pd.zwc365.com/seturl/https://raw.githubusercontent.com/whyour/hundun/master/quanx/xmly_speed.py
    sed -i 's/BARK/BARK_PUSH/g' /xmly_speed/util.py
    sed -i 's/SCKEY/PUSH_KEY/g' /xmly_speed/util.py
    sed -i 's/if\ XMLY_ACCUMULATE_TIME.*$/if\ os.environ["XMLY_ACCUMULATE_TIME"]=="1":/g' /xmly_speed/xmly_speed.py
    sed -i "s/\(xmly_speed_cookie\.split('\)\\\n/\1\|/g" /xmly_speed/xmly_speed.py
    sed -i 's/cookiesList.append(line)/cookiesList.append(line.replace(" ",""))/g' /xmly_speed/xmly_speed.py
    sed -i 's/if int(_notify_time.split.*$/if _notify_time.split()[0] == os.environ["XMLY_NOTIFY_TIME"]\ and\ int(_notify_time.split()[1]) < 10:/g' /xmly_speed/xmly_speed.py
    
    sed -i "s/message += f\"【账户】.*$/message += f\"[{i[0].replace\(' ',''\):<9}]: {i[1]:<6.2f} \(＋{i[2]:<4.2f}\) {i[3]:<7.2f} {i[4]}\\\\\\\30\\\n\"/g" /xmly_speed/xmly_speed.py
    sed -i 's/    message += f"【当前剩余】.*$/message += "⭕tips:第30天需要手动签到 by zero_s1, (*^_^*)欢迎打赏 "/g' /xmly_speed/xmly_speed.py
    sed -i 's/    message += f"【今天】.*$/if len(table) <= 20:/g' /xmly_speed/xmly_speed.py
    sed -i 's/message += f"【历史】.*$/message = "【账户】| 当前剩余 | 今天 | 历史 | 连续签到\\n"+message/g' /xmly_speed/xmly_speed.py
    sed -i '/message += f"【连续签到】.*$/d' /xmly_speed/xmly_speed.py
    sed -i '/message += f"\\n".*$/d' /xmly_speed/xmly_speed.py
    if [ 0"$XMLY_CRON" = "0" ]; then
        XMLY_CRON="*/30 * * * *"
    fi
    echo "#喜马拉雅极速版">>$mergedListFile
    echo "$XMLY_CRON python3 /xmly_speed/xmly_speed.py >> /logs/xmly_speed.log 2>&1" >>$mergedListFile
fi

##判断火山极速版相关变量存在，才会更新相关任务脚本
if [ 0"$HOTSOONSIGNHEADER" = "0" ]; then
    echo "没有配置火山极速版，相关环境变量参数，跳过配置定时任务"
else
    if [ ! -d "/hotsoon/" ]; then
        echo "未检查到hotsoon脚本相关文件，初始化下载相关脚本"
        inithotsoon
    else
        echo "更新hotsoon脚本相关文件"
        git -C /hotsoon reset --hard
        git -C /hotsoon pull origin master --rebase
        wget -O /hotsoon/package.json https://pd.zwc365.com/seturl/https://raw.githubusercontent.com/Aaron-lv/sync/JavaScript/package.json
        npm install --loglevel error --prefix /hotsoon
    fi
    wget -O /hotsoon/Scripts/sendNotify.js https://pd.zwc365.com/seturl/https://raw.githubusercontent.com/Ariszy/script/master/sendNotify.js
    if [ 0"$HOTSOON_CRON" = "0" ]; then
        HOTSOON_CRON="*/5 1-23/1 * * *"
    fi
    echo "#火山极速版" >>$mergedListFile
    echo "$HOTSOON_CRON node /hotsoon/Scripts/hotsoon_old.js >> /logs/hotsoon.log 2>&1" >>$mergedListFile
fi

##判断ZIYE_JavaScript相关变量存在，才会更新相关任务脚本
if [ 0"$COOKIES_SPLIT" = "0" ]; then
    echo "没有配置ZIYE_JavaScript，相关环境变量参数，跳过配置定时任务"
else
    if [ ! -d "/ZIYE_JavaScript/" ]; then
        echo "未检查到ZIYE_JavaScript仓库脚本，初始化下载相关脚本"
        initziye
    else
        echo "更新ZIYE_JavaScript脚本相关文件"
        git -C /ZIYE_JavaScript reset --hard
        git -C /ZIYE_JavaScript pull origin JavaScript --rebase
        npm install --loglevel error --prefix /ZIYE_JavaScript
    fi
fi

##判断汽车之家极速版相关变量存在，才会更新相关任务脚本
if [ 0"$QCZJ_GetUserInfoHEADER" = "0" ]; then
    echo "没有配置汽车之家，相关环境变量参数，跳过配置定时任务"
else
    sed -i "s/= GetUserInfoheaderArr\[i]/= GetUserInfoheaderArr\[i].trim()/g" /ZIYE_JavaScript/Task/qczjspeed.js
    sed -i "s/= taskbodyArr\[i]/= taskbodyArr\[i].trim()/g" /ZIYE_JavaScript/Task/qczjspeed.js
    sed -i "s/= activitybodyArr\[i]/= activitybodyArr\[i].trim()/g" /ZIYE_JavaScript/Task/qczjspeed.js
    sed -i "s/= addCoinbodyArr\[i]/= addCoinbodyArr\[i].trim()/g" /ZIYE_JavaScript/Task/qczjspeed.js
    sed -i "s/= addCoin2bodyArr\[i]/= addCoin2bodyArr\[i].trim()/g" /ZIYE_JavaScript/Task/qczjspeed.js

    sed -i "s/CASH = ''/CASH = '', CASHTYPE = ''/g" /ZIYE_JavaScript/Task/qczjspeed.js
    sed -i "s/CASH = process.env.QCZJ_CASH || 0;/CASH = process.env.QCZJ_CASH || 0;\n CASHTYPE = process.env.QCZJ_CASHTYPE || 3;/g" /ZIYE_JavaScript/Task/qczjspeed.js
    sed -i "s/cashtype=3/cashtype=\${CASHTYPE}/g" /ZIYE_JavaScript/Task/qczjspeed.js
    if [ 0"$QCZJ_CRON" = "0" ]; then
        QCZJ_CRON="*/20 * * * *"
    fi
    echo "#汽车之家极速版" >>$mergedListFile
    echo "$QCZJ_CRON node /ZIYE_JavaScript/Task/qczjspeed.js >> /logs/qczjspeed.log 2>&1" >>$mergedListFile
fi

##判断笑谱相关变量存在，才会更新相关任务脚本
if [ 0"$XP_refreshTOKEN" = "0" ]; then
    echo "没有配置笑谱，相关环境变量参数，跳过配置定时任务"
else
    sed -i "s/notifyttt == 1.*$/notifyttt == 1 \&\& \$.isNode() \&\& (nowTimes.getHours() === 12 || nowTimes.getHours() === 22) \&\& (nowTimes.getMinutes() >= 0 \&\& nowTimes.getMinutes() <= 30))/g" /ZIYE_JavaScript/Task/iboxpay.js
    if [ 0"$XP_CRON" = "0" ]; then
        XP_CRON="0 9-22/1 * * *"
    fi
    echo "#笑谱" >>$mergedListFile
    echo "$XP_CRON node /ZIYE_JavaScript/Task/iboxpay.js >> /logs/iboxpay.log 2>&1" >>$mergedListFile
fi

##判断返利网相关变量存在，才会更新相关任务脚本
if [ 0"$FL_flwHEADER" = "0" ]; then
    echo "没有配置返利网，相关环境变量参数，跳过配置定时任务"
else
    sed -i "s/nowTimes.getHours() === 10/nowTimes.getHours() === 11/g" /ZIYE_JavaScript/Task/flw.js
    sed -i "s/new Date().getTimezoneOffset() \* 60 \* 1000) \/ 1000).toString();/new Date().getTimezoneOffset() \* 60 \* 1000 +\n      8 \* 60 \* 60 \* 1000) \/ 1000).toString();/g" /ZIYE_JavaScript/Task/flw.js
    if [ 0"$FL_CRON" = "0" ]; then
        FL_CRON="0 8,11,17,23 * * *"
    fi
    echo "#返利网" >>$mergedListFile
    echo "$FL_CRON node /ZIYE_JavaScript/Task/flw.js >> /logs/flw.log 2>&1" >>$mergedListFile
fi

##判断芝嫲视频相关变量存在，才会更新相关任务脚本
if [ 0"$ZM_zhimabody" = "0" ]; then
    echo "没有配置芝嫲视频，相关环境变量参数，跳过配置定时任务"
else
    if [ 0"$ZM_CRON" = "0" ]; then
        ZM_CRON="*/30 * * * *"
    fi
    echo "#芝嫲视频" >>$mergedListFile
    echo "$ZM_CRON node /ZIYE_JavaScript/Task/zhima.js >> /logs/zhima.log 2>&1" >>$mergedListFile
fi

##判断全民悦动相关变量存在，才会更新相关任务脚本
if [ 0"$QMYD_qmydTOKEN" = "0" ]; then
    echo "没有配置全民悦动，相关环境变量参数，跳过配置定时任务"
else
    if [ 0"$QMYD_CRON" = "0" ]; then
        QMYD_CRON="*/20 * * * *"
    fi
    echo "#全民悦动" >>$mergedListFile
    echo "$QMYD_CRON node /ZIYE_JavaScript/Task/qmyd.js >> /logs/qmyd.log 2>&1" >>$mergedListFile
fi

##判断多多爱运动相关变量存在，才会更新相关任务脚本
if [ 0"$DDAYD_ddaydCK" = "0" ]; then
    echo "没有配置多多爱运动，相关环境变量参数，跳过配置定时任务"
else
    wget -O /ZIYE_JavaScript/Task/ddayd.js https://pd.zwc365.com/seturl/https://raw.githubusercontent.com/Aaron-lv/sync/2a9d66a462c0a150768bd18936fb083dab79d1b6/Task/ddayd.js
    if [ 0"$DDAYD_CRON" = "0" ]; then
        DDAYD_CRON="10 * * * *"
    fi
    echo "#多多爱运动" >>$mergedListFile
    echo "$DDAYD_CRON node /ZIYE_JavaScript/Task/ddayd.js >> /logs/ddayd.log 2>&1" >>$mergedListFile
fi
