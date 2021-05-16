#!/bin/sh

mergedListFile="/jds/updateTeam/merged_list_file.sh"

function initupdateTeam() {
    git config --global user.name "$name"
    git config --global user.email "$email"
    echo -e "$SSH_PRIVATE_KEY" > /root/.ssh/id_rsa
    mkdir /updateTeam
    cd /updateTeam
    git init
    git remote add origin $updateTeam_URL
    git pull origin $updateTeam_BRANCH --rebase
}

if [ 0"$updateTeam_URL" = "0" ]; then
    echo "没有配置远程仓库地址，跳过初始化。"
else
    if [ ! -d "/updateTeam/" ]; then
        echo "未检查到updateTeam仓库，初始化下载..."
        initupdateTeam
    else
        cd /updateTeam
        echo "更新updateTeam仓库文件..."
        git reset --hard
        git pull origin $updateTeam_BRANCH --rebase
    fi
fi

##京喜工厂自动开团
if [ $jd_jxFactoryCreateTuan_ENABLE = "Y" ]; then
    echo "# 京喜工厂自动开团" >> $mergedListFile
    echo "0 * * * * cd /scripts && node jd_jxFactoryCreateTuan.js >> logs/jd_jxFactoryCreateTuan.log 2>&1" >> $mergedListFile
fi

##更新抢京豆邀请码
if [ $jd_updateBeanHome_ENABLE = "Y" ]; then
    echo "# 更新抢京豆邀请码" >> $mergedListFile
    echo "0 * * * * cd /scripts && node jd_updateBeanHome.js >> logs/jd_updateBeanHome.log 2>&1" >> $mergedListFile
fi

##京东签到领现金
if [ $jd_updateCash_ENABLE = "Y" ]; then
    echo "# 京东签到领现金" >> $mergedListFile
    echo "0 0 * * * cd /scripts && node jd_updateCash.js >> logs/jd_updateCash.log 2>&1" >> $mergedListFile
fi

##京喜财富岛
if [ $jd_updateCfd_ENABLE = "Y" ]; then
    echo "# 京喜财富岛" >> $mergedListFile
    echo "0 0 * * * cd /scripts && sleep 30 && node jd_updateCfd.js >> logs/jd_updateCfd.log 2>&1" >> $mergedListFile
fi

##更新东东小窝邀请码
if [ $jd_updateSmallHome_ENABLE = "Y" ]; then
    echo "# 更新东东小窝邀请码" >> $mergedListFile
    echo "0 0 * * * cd /scripts && node jd_updateSmallHome.js >> logs/jd_updateSmallHome.log 2>&1" >> $mergedListFile
fi

##赚京豆小程序
if [ $jd_zzUpdate_ENABLE = "Y" ]; then
    echo "# 赚京豆小程序" >> $mergedListFile
    echo "0 * * * * cd /scripts && node jd_zzUpdate.js >> logs/jd_zzUpdate.log 2>&1" >> $mergedListFile
fi

cp -rf /scripts/shareCodes /updateTeam
echo "提交updateTeam仓库文件..."
cd /updateTeam
git add -A
git commit -m "更新JSON文件"
git push origin $updateTeam_BRANCH
