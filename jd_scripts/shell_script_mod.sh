#!/bin/sh

mergedListFile="/scripts/docker/merged_list_file.sh"

## 添加定时
function addCron() {
    jsnames="$(cd /scripts && ls [a-z]*_*.js)"
    for jsname in $jsnames; do
        if [ $(grep -c "$jsname" "$mergedListFile") -eq '0' ]; then
            if [ "$jsname" == "jd_crazy_joy_coin.js" ]; then
                continue
            else
                jsname_log="$(echo $jsname | cut -d \. -f1)"
                jsname_cn="$(cat /scripts/$jsname | grep -oE "/?/?new Env\('.*'\)" | cut -d\' -f2)"
                [[ -z "$jsname_cn" ]] && jsname_cn="$(cat /scripts/$jsname | grep -oE "/?/?tag\=.*" | cut -d"=" -f2)"
                [[ -z "$jsname_cn" ]] && jsname_cn=$jsname_log
                jscron="$(cat /scripts/$jsname | grep -oE "/?/?cron \".*\"" | cut -d\" -f2)"
                if [ -z "$jscron" ]; then
                    jscron="$(cat /scripts/$jsname | grep ^[0-9] | awk '{print $1,$2,$3,$4,$5}' | egrep -v "[a-zA-Z]|:|\." | sort | uniq | head -n 1)"
                fi
                test -n "$jscron" && test -n "$jsname_cn" && echo "# $jsname_cn" >> $mergedListFile
                test -n "$jscron" && echo "$jscron node /scripts/$jsname >> /scripts/logs/$jsname_log.log 2>&1" >> $mergedListFile
                test -n "$jscron" && echo $jsname
            fi
        fi
    done
}

if [ $(grep -c "docker_entrypoint.sh" $mergedListFile) -eq '0' ]; then
    wget -O /scripts/docker/remote_task.sh https://pd.zwc365.com/seturl/https://raw.githubusercontent.com/Aaron-lv/someDockerfile/master/jd_scripts/docker_entrypoint.sh
    echo "# 远程定时任务" >> $mergedListFile
    echo "*/1 */1 * * * sh -x /scripts/docker/remote_task.sh >> /scripts/logs/remote_task.log 2>&1" >> $mergedListFile
    cat /scripts/docker/remote_task.sh > /scripts/docker/docker_entrypoint.sh
fi

## 克隆monk-coder仓库
if [ ! -d "/monk-coder/" ]; then
    echo "未检查到monk-coder仓库脚本，初始化下载相关脚本..."
    git clone -b dust https://github.com/Aaron-lv/sync /monk-coder
else
    echo "更新monk-coder仓库脚本..."
    git -C /monk-coder reset --hard
    git -C /monk-coder pull origin dust --rebase
fi

## 克隆Aaron-lv仓库
if [ ! -d "/Aaron-lv/" ]; then
    echo "未检查到Aaron-lv仓库脚本，初始化下载相关脚本..."
    git clone https://github.com/Aaron-lv/JavaScript /Aaron-lv
else
    echo "更新Aaron-lv仓库脚本..."
    git -C /Aaron-lv reset --hard
    git -C /Aaron-lv pull origin master --rebase
fi

## 克隆passerby-b仓库
if [ ! -z $JDDJ_COOKIE ]; then
    if [ ! -d "/passerby-b/" ]; then
        echo "未检查到passerby-b仓库脚本，初始化下载相关脚本..."
        git clone https://github.com/passerby-b/JDDJ /passerby-b
    else
        echo "更新passerby-b仓库脚本..."
        git -C /passerby-b reset --hard
        git -C /passerby-b pull origin main --rebase
    fi
fi

## 删除运行目录中不在定时文件里的脚本
jsnames="$(cd /scripts && ls [a-z]*_*.js)"
for jsname in $jsnames; do
    if [ $(grep -c "$jsname" "$mergedListFile") -eq '0' ]; then
        if [[ "$jsname" == "jd_speed.js" || "$jsname" == "jd_crazy_joy_coin.js" ]]; then
            continue
        else
            rm -rf /scripts/$jsname
        fi
    fi
done

## 复制monk-coder仓库脚本到运行目录
js_dir="car&i-chenzhe&member&normal"
arr=${js_dir//&/ }
for item in $arr; do
    if [ -n "$(ls /monk-coder/$item/[a-z]*_*.js)" ]; then
        cp -f /monk-coder/$item/[a-z]*_*.js /scripts
    fi
done

## 复制Aaron-lv仓库脚本到运行目录
if [ -n "$(ls /Aaron-lv/Task/[a-z]*_*.js)" ]; then
    cp -f /Aaron-lv/Task/[a-z]*_*.js /scripts
fi

## 删除不运行脚本
if [ -n "$(ls /scripts/[!jA-Z]*_*.js)" ]; then
    js_del="z_health_community&z_health_energy&z_marketLottery&z_shake&z_xmf&jx_cfdtx"
    arr=${js_del//&/ }
    for item in $arr; do
        rm -rf /scripts/$item.js
    done
fi

## wget方式添加脚本
## 京东试用
if [ $jd_try_ENABLE = "Y" ]; then
    wget -O /scripts/jd_try.js https://pd.zwc365.com/seturl/https://raw.githubusercontent.com/ZCY01/daily_scripts/main/jd/jd_try.js
fi

## 添加远程脚本定时
if [ -n "$(ls /scripts/[a-z]*_*.js)" ]; then
    echo "添加远程脚本,脚本列表:"
    addCron
fi

## 复制passerby-b仓库脚本到运行目录并添加定时
if [ -n "$(ls /passerby-b/[a-z]*_*.js)" ]; then
    cp -rf /passerby-b/[a-z]*_*.js /scripts
    echo -e "\n##############京东到家##############" >> $mergedListFile
    echo "添加passerby-b仓库脚本,脚本列表:"
    addCron
fi

## 复制挂载脚本到运行目录并添加定时
if [ ! -d "/diy/" ]; then
    echo "未检查到挂载文件夹，请挂载本地文件夹到容器/diy文件夹..."
else
    if [ -n "$(ls /diy/[a-z]*_*.js)" ]; then
        cp -rf /diy/[a-z]*_*.js /scripts
        echo -e "\n##############挂载脚本##############" >> $mergedListFile
        echo "添加挂载脚本,脚本列表:"
        addCron
    else
        echo "/diy文件夹为空，请将脚本放入挂载的本地文件夹内..."
    fi
fi
