#!/usr/bin/env bash

function syncRepo() {
    cd /jds
    echo "git pull拉取最新代码..."
    git reset --hard
    git pull origin master
}

#获取配置的自定义参数
if [ "$1" ]; then
    run_cmd=$1
fi

syncRepo
if [ $? -ne 0 ]; then
    echo "更新仓库代码出错❌，跳过"
else
    echo "更新仓库代码成功✅"
fi

echo "-------------------------------------------------执行定时任务shell脚本--------------------------------------------------"
. /jds/sign/default_task.sh
if [ $? -ne 0 ]; then
    echo "定时任务shell脚本执行失败❌，exit，restart"
    exit 1
else
    echo "定时任务shell脚本执行成功✅"
fi
echo "--------------------------------------------------默认定时任务执行完成---------------------------------------------------"
if [ -n "$run_cmd" ]; then
    echo "启动crontab定时任务主进程..."
    crond -f
else
    echo "默认定时任务执行结束。"
fi
echo -e "\n\n"
