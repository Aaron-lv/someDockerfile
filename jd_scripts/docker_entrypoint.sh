#!/bin/sh
set -e

#获取配置的自定义参数
if [ -n "$1" ]; then
    run_cmd=$1
fi

(
echo "设定远程仓库地址..."
cd /scripts
git remote set-url origin $REPO_URL
echo "git pull拉取最新代码..."
git -C /scripts reset --hard
git -C /scripts pull origin $REPO_BRANCH --rebase
echo "npm install 安装最新依赖..."
npm install --loglevel error --prefix /scripts

function initjds() {
    mkdir /jds
    cd /jds
    git init
    git remote add origin https://github.com/Aaron-lv/someDockerfile
    git config core.sparsecheckout true
    echo jd_scripts >> /jds/.git/info/sparse-checkout
    git pull origin master --rebase
}

if [ ! -d "/jds/" ]; then
    echo "未检查到jds仓库，初始化下载..."
    initjds
else
    echo "更新jds仓库文件..."
    git -C /jds reset --hard
    git -C /jds pull origin master --rebase
fi

echo "替换执行文件..."
if [ -n "$(ls /jds/jd_scripts/)" ]; then
    jds_cp="default_task.sh&docker_entrypoint.sh&proc_file.sh"
    arr=${jds_cp//&/ }
    for item in $arr; do
        cp -f /jds/jd_scripts/$item /scripts/docker
    done
fi
echo "替换完成。"
) || exit 0

#默认启动telegram交互机器人的条件
#确认容器启动时调用的docker_entrypoint.sh
#必须配置TG_BOT_TOKEN、TG_USER_ID，
#且未配置DISABLE_BOT_COMMAND禁用交互，
#且未配置自定义TG_API_HOST，因为配置了该变量，说明该容器环境可能并不能科学的连到telegram服务器
if [[ -n "$run_cmd" && -n "$TG_BOT_TOKEN" && -n "$TG_USER_ID" && -z "$DISABLE_BOT_COMMAND" && -z "$TG_API_HOST" ]]; then
    ENABLE_BOT_COMMAND=True
else
    ENABLE_BOT_COMMAND=False
fi

echo "------------------------------------------------执行定时任务任务shell脚本------------------------------------------------"
sh -x /scripts/docker/default_task.sh $ENABLE_BOT_COMMAND $run_cmd
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
