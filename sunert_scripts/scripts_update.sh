#!/bin/sh

mergedListFile="/pss/sunert_scripts/merged_list_file.sh"

echo "git 拉取最新代码..."
git -C /Scripts reset --hard
git -C /Scripts pull origin master --rebase
npm install --loglevel error --prefix /Scripts

#判断百度极速版相关变量存在，才会配置定时任务
if [ 0"$BAIDU_COOKIE" = "0" ]; then
    echo "没有配置百度极速版，相关环境变量参数，跳过配置定时任务"
else
    if [ 0"$BAIDU_CRON" = "0" ]; then
        BAIDU_CRON="*/20 6-22/1 * * *"
    fi
    echo "#百度极速版" >>$mergedListFile
    echo "$BAIDU_CRON node /Scripts/Task/baidu_speed.js >> /logs/baidu_speed.log 2>&1" >>$mergedListFile
fi

#判断中青看点极速版相关变量存在，才会配置定时任务
if [ 0"$YOUTH_HEADER" = "0" ]; then
    echo "没有配置中青看点极速版youth，相关环境变量参数，跳过配置定时任务"
else
    sed -i 's/"false"/"true"/g' /Scripts/Task/youth.js
    if [ 0"$YOUTH_CRON" = "0" ]; then
        YOUTH_CRON="*/15 */1 * * *"
    fi
    echo "#中青看点极速版" >>$mergedListFile
    echo "$YOUTH_CRON node /Scripts/Task/youth.js >> /logs/youth.log 2>&1" >>$mergedListFile
fi

if [ 0"$YOUTH_START" = "0" ]; then
    echo "没有配置中青看点极速版youth_gain，相关环境变量参数，跳过配置定时任务"
else
    if [ 0"$YOUTH_GAIN_CRON" = "0" ]; then
        YOUTH_GAIN_CRON="0 8 * * *"
    fi
    echo "$YOUTH_GAIN_CRON node /Scripts/Task/youth_gain.js >> /logs/youth_gain.log 2>&1" >>$mergedListFile
fi

if [ 0"$YOUTH_READ2" = "0" ]; then
    if [ 0"$YOUTH_READ" = "0" ]; then
        echo "没有配置中青看点极速版youth_read，相关环境变量参数，跳过配置定时任务"
    else
        if [ 0"$YOUTH_READ_CRON" = "0" ]; then
            YOUTH_READ_CRON="5 9-21/3 * * *"
        fi
        echo "$YOUTH_READ_CRON node /Scripts/Task/Youth_Read.js >> /logs/Youth_Read.log 2>&1" >>$mergedListFile
    fi
else
    cp -f /Scripts/Task/Youth_Read.js /Scripts/Task/Youth_Read2.js
    sed -i 's/YOUTH_READ/YOUTH_READ2/g' /Scripts/Task/Youth_Read2.js
    
    if [ 0"$YOUTH_READ_CRON" = "0" ]; then
        YOUTH_READ_CRON="5 9-21/3 * * *"
    fi
    echo "$YOUTH_READ_CRON node /Scripts/Task/Youth_Read.js >> /logs/Youth_Read.log 2>&1 && node /Scripts/Task/Youth_Read2.js >> /logs/Youth_Read2.log 2>&1" >>$mergedListFile
fi

#判断快手极速版相关变量存在，才会配置定时任务
if [ 0"$KS_TOKEN" = "0" ]; then
    echo "没有配置快手极速版，相关环境变量参数，跳过配置定时任务"
else
    if [ 0"$KS_CRON" = "0" ]; then
        KS_CRON="0 8 * * *"
    fi
    echo "#快手极速版" >>$mergedListFile
    echo "$KS_CRON node /Scripts/Task/kuaishou.js >> /logs/kuaishou.log 2>&1" >>$mergedListFile
fi
