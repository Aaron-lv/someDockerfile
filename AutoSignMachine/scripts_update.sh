#!/bin/sh

mergedListFile="/pss/AutoSignMachine/merged_list_file.sh"

cd /AutoSignMachine
echo "更新AutoSignMachine仓库脚本..."
git reset --hard
git pull origin main --rebase
echo "安装最新依赖..."
npm install --loglevel error --prefix /AutoSignMachine

cd /UnicomTask
echo "更新AutoSignMachine仓库脚本..."
git reset --hard
git pull origin main --rebase
echo "安装最新依赖..."
pip3 install --upgrade pip
pip3 install -r requirements.txt


if [ $ENABLE_52POJIE ]; then
    echo "10 13 * * * node /AutoSignMachine/index.js 52pojie --htVD_2132_auth=${htVD_2132_auth} --htVD_2132_saltkey=${htVD_2132_saltkey} >> /logs/52pojie.log 2>&1 &" >>$mergedListFile
else
    echo "未配置启用52pojie签到任务环境变量ENABLE_52POJIE，故不添加52pojie定时任务..."
fi

if [ $ENABLE_BILIBILI ]; then
    echo "*/30 7-22 * * * node /AutoSignMachine/index.js bilibili --username ${BILIBILI_ACCOUNT} --password ${BILIBILI_PWD} >> /logs/bilibili.log 2>&1 &" >>$mergedListFile
else
    echo "未配置启用bilibi签到任务环境变量ENABLE_BILIBILI，故不添加Bilibili定时任务..."
fi

if [ $ENABLE_IQIYI ]; then
    echo "*/30 7-22 * * * node /AutoSignMachine/index.js iqiyi --P00001 ${P00001} --P00PRU ${P00PRU} --QC005 ${QC005}  --dfp ${dfp} >> /logs/iqiyi.log 2>&1 &" >>$mergedListFile
else
    echo "未配置启用iqiyi签到任务环境变量ENABLE_IQIYI，故不添加iqiyi定时任务..."
fi

if [ $ENABLE_UNICOM ]; then
    echo "联通配置了UNICOM_SUBDIR_MODE参数，所以使用每个账户自动创建单独目录及配置来执行任务"
    pwds=$(cat ~/.AutoSignMachine/.env | grep UNICOM_PASSWORD | sed -n "s/.*'\(.*\)'.*/\1/p")
    appids=$(cat ~/.AutoSignMachine/.env | grep UNICOM_APPID | sed -n "s/.*'\(.*\)'.*/\1/p")
    i=1
    for username in $(cat ~/.AutoSignMachine/.env | grep UNICOM_USERNAME | sed -n "s/.*'\(.*\)'.*/\1/p" | sed "s/,/ /g"); do
        sub_dir="asm${username:0:4}"
        cp -rf /AutoSignMachine /"$sub_dir"
        echo "$sub_dir"
        pwd=$(echo $pwds | cut -d ',' -f$i)
        appid="$(echo $appids | cut -d ',' -f$i)"
        echo "UNICOM_USERNAME = '$username'" >/"$sub_dir"/config/.env
        echo "UNICOM_PASSWORD = '$pwd'" >>/"$sub_dir"/config/.env
        echo "UNICOM_APPID = '$appid'" >>/"$sub_dir"/config/.env
        echo "ASYNC_TASKS = true" >>/"$sub_dir"/config/.env
        i=$(expr $i + 1)
        echo "*/20 6-23 * * * cd /$sub_dir && node index.js unicom >> /logs/unicom${username:0:4}.log 2>&1 &" >>$mergedListFile
    done
fi

if [ $ENABLE_UNICOMTASK ]; then
    cp -f $USERS_COVER /UnicomTask/config.json
    echo "30 6 * * * cd /UnicomTask && python3 -u main.py >> /logs/UnicomTask.log 2>&1 &" >>$mergedListFile
else
    echo "未配置启用UnicomTask签到任务环境变量ENABLE_UNICOMTASK，故不添加UnicomTask定时任务..."
fi
