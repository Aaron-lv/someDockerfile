#!/usr/bin/env bash

function syncRepo() {
    cd /scripts
    echo "设定远程仓库地址..."
    git remote set-url origin $REPO_URL
    echo "git pull拉取最新代码..."
    git reset --hard
    git pull origin $REPO_BRANCH
    echo "git pull拉取shell最新代码..."
    git -C /jds reset --hard
    git -C /jds pull origin master
}

if [ -d "/data" ]; then
    if [ -f "/data/env.sh" ]; then
        echo "检测到环境变量配置文件 /data/env.sh 存在，使用该文件内环境变量..."
        chmod 777 /data/env.sh
        . /data/env.sh
    fi
fi

#获取配置的自定义参数
if [ "$1" ]; then
    run_cmd=$1
fi

[[ -f "/scripts/package.json" ]] && before_package_json="$(cat /scripts/package.json)"

syncRepo
if [ $? -ne 0 ]; then
    echo "更新仓库代码出错❌，跳过"
else
    echo "更新仓库代码成功✅"
fi

if [ ! -d "/scripts/node_modules" ]; then
    echo "容器首次启动，执行npm install..."
    pnpm install --prod
    if [ $? -ne 0 ]; then
        echo "npm首次启动安装依赖失败❌，exit，restart"
        exit 1
    else
        echo "npm首次启动安装依赖成功✅"
    fi
else
    if [ "$before_package_json" != "$(cat /scripts/package.json)" ]; then
        echo "package.json有更新，执行npm install..."
        pnpm install --prod
        if [ $? -ne 0 ]; then
            echo "package.json有更新，执行安装依赖失败❌，跳过"
            exit 1
        else
            echo "package.json有更新，执行安装依赖成功✅"
        fi
    else
        echo "package.json无变化，跳过npm install..."
    fi
fi

#默认启动telegram交互机器人的条件
#确认容器启动时调用的docker_entrypoint.sh
#必须配置TG_BOT_TOKEN、TG_USER_ID，
#且未配置DISABLE_BOT_COMMAND禁用交互，
#且未配置自定义TG_API_HOST，因为配置了该变量，说明该容器环境可能并不能科学的连到telegram服务器
if [ "$TG_API_BOT" == "Y" ]; then
    if [[ -n "$run_cmd" && -n "$TG_BOT_TOKEN" && -n "$TG_USER_ID" && -z "$DISABLE_BOT_COMMAND" ]]; then
        ENABLE_BOT_COMMAND=True
    else
        ENABLE_BOT_COMMAND=False
    fi
else
    if [[ -n "$run_cmd" && -n "$TG_BOT_TOKEN" && -n "$TG_USER_ID" && -z "$DISABLE_BOT_COMMAND" && -z "$TG_API_HOST" ]]; then
        ENABLE_BOT_COMMAND=True
    else
        ENABLE_BOT_COMMAND=False
    fi
fi

echo "-------------------------------------------------执行定时任务shell脚本--------------------------------------------------"
. /jds/jd_scripts/default_task.sh $ENABLE_BOT_COMMAND $run_cmd
if [ $? -ne 0 ]; then
    echo "定时任务shell脚本执行失败❌，exit，restart"
    exit 1
else
    echo "定时任务shell脚本执行成功✅"
fi
echo "--------------------------------------------------默认定时任务执行完成---------------------------------------------------"

if [ -n "$run_cmd" ]; then
    #增加一层jd_bot指令已经正确安装成功校验
    #以上条件都满足后会启动jd_bot交互，否则还是按照以前的模式启动，最大程度避免现有用户改动调整
    if [[ "$ENABLE_BOT_COMMAND" == "True" && -f "/usr/bin/jd_bot" ]]; then
        echo "启动crontab定时任务主进程..."
        crond
        echo "启动telegram bot指令交主进程..."
        jd_bot
    else
        echo "启动crontab定时任务主进程..."
        crond -f
    fi
else
    echo "默认定时任务执行结束。"
fi
echo -e "\n\n"
