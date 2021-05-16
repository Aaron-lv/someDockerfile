#!/bin/sh
set -e

function initCdn() {
    sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
}

#获取配置的自定义参数
if [ $1 ]; then
    run_cmd=$1
    initCdn
fi

(
cd /updateTeam_scripts
echo "设定远程仓库地址..."
git remote set-url origin $REPO_URL
echo "git pull拉取最新代码..."
git reset --hard
git pull origin $REPO_BRANCH --rebase
echo "复制脚本到运行目录..."
rm -rf /scripts/*.*
cp -f /updateTeam_scripts/*.* /scripts
echo "npm install 安装最新依赖..."
npm install --loglevel error --prefix /scripts

cd /jds
echo "更新jds仓库文件..."
git reset --hard
git pull origin master --rebase
) || exit 0

echo "------------------------------------------------执行定时任务任务shell脚本------------------------------------------------"
sh -x /jds/updateTeam/default_task.sh
echo "--------------------------------------------------默认定时任务执行完成---------------------------------------------------"

if [ $run_cmd ]; then
    echo "启动crondtab定时任务主进程..."
    crond -f
else
    echo "默认定时任务执行结束。"
fi
echo -e "\n\n"
