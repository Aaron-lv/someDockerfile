#!/usr/bin/env bash

function initPythonEnv() {
    echo "开始安装运行jd_bot需要的python环境及依赖..."
    sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
    pip config --global set global.index-url https://pypi.mirrors.ustc.edu.cn/simple
    echo "开始安装jd_bot依赖..."
    cp -f /jds/jd_scripts/bot/jd_bot /scripts/docker/bot/
    cd /scripts/docker/bot
    pip3 install --upgrade pip
    pip3 install -r requirements.txt
    python3 setup.py install
}

function run_hangup() {
    if [[ -s "$COOKIES_LIST" && -f "/usr/local/bin/spnode" ]]; then
        if [ -z "$CFD_LOOP_NUM" ]; then
            export JD_COOKIE="$(cat $COOKIES_LIST | grep -v "#\|^$"| paste -s -d '&')"
        else
            export JD_COOKIE="$(cat $COOKIES_LIST | head -n $CFD_LOOP_NUM | grep -v "#\|^$"| paste -s -d '&')"
        fi
    elif [[ 0"$JD_COOKIE" != "0" && ! -f "/usr/local/bin/spnode" ]]; then
        if [ -n "$CFD_LOOP_NUM" ]; then
            export JD_COOKIE="$(echo $JD_COOKIE | sed "s/[ &]/\\n/g" | sed "/^$/d" | head -n $CFD_LOOP_NUM | grep -v "#\|^$"| paste -s -d '&')"
        fi
    fi
    if [ 0"$JD_COOKIE" != "0" ]; then
        cd /scripts
        for file in $@; do
            _file="$(echo $file | awk -F "." '{print $1}')"
            if [ -f "/scripts/$file" ]; then
                echo "$_file开启挂机"
                if type pm2 > /dev/null 2>&1; then
                    if [ "$(pm2 list | grep "$_file" | grep "root")" == "" ]; then
                        pm2 flush
                        pm2 start -a $file --watch "$file" --name=$_file
                    else
                        pm2 stop $_file
                        pm2 flush
                        pm2 start -a $_file
                    fi
                else
                    eval $(ps -ef | grep "$_file" | grep -v "grep" | awk '{print "kill "$1}')
                    echo '' > /scripts/logs/$_file.log
                    $CMD /scripts/$_file.js |ts >> /scripts/logs/$_file.log 2>&1 &
                fi
            else
                echo "$_file脚本不存在，跳过挂机"
            fi
        done
    else
        echo "未添加COOKIE不启用挂机"
    fi
}

#启动tg bot交互前置条件成立，开始安装配置环境
if [ "$1" == "True" ]; then
    initPythonEnv
    if [ -z "$DISABLE_SPNODE" ]; then
        cp -f /jds/jd_scripts/shell_spnode.sh /usr/local/bin/spnode
        chmod +x /usr/local/bin/spnode
    fi
    echo "spnode需要使用，cookie写入文件，该文件同时也为jd_bot扫码自动获取cookie服务"
    if [ 0"$JD_COOKIE" == "0" ]; then
        if [ ! -f "$COOKIES_LIST" ]; then
            echo "" > $COOKIES_LIST
            echo "未配置JD_COOKIE环境变量，$COOKIES_LIST 文件已生成,请将cookies写入 $COOKIES_LIST 文件，格式每个Cookie一行"
        fi
    else
        if [ -f "$COOKIES_LIST" ]; then
            echo "cookies.conf文件已经存在跳过,如果需要更新cookie请修改 $COOKIES_LIST 文件内容"
        else
            echo "环境变量 cookies写入 $COOKIES_LIST 文件,如果需要更新cookie请修改cookies.conf文件内容"
            echo $JD_COOKIE | sed "s/[ &]/\\n/g" | sed "/^$/d" > $COOKIES_LIST
        fi
    fi
fi

echo "定义定时任务合并处理用到的文件路径..."
defaultListFile="/scripts/docker/$DEFAULT_LIST_FILE"
echo "默认文件定时任务文件路径为 $defaultListFile"
mergedListFile="/scripts/docker/merged_list_file.sh"
echo "合并后定时任务文件路径为 $mergedListFile"

echo "第1步将默认定时任务列表添加到合并后定时任务文件..."
cat $defaultListFile >$mergedListFile

echo "第2步判断是否存在自定义定时任务列表并追加..."
if [ -n "$CUSTOM_LIST_FILE" ]; then
    echo "您配置了自定义任务文件： $CUSTOM_LIST_FILE ，自定义任务类型为： $CUSTOM_LIST_MERGE_TYPE"
    customListFile="/scripts/docker/custom_list_file.sh"
    if expr "$CUSTOM_LIST_FILE" : 'http.*' &>/dev/null; then
        echo "自定义任务文件为远程脚本，开始下载自定义远程任务..."
        function customList() {
            re="$(echo $CUSTOM_LIST_FILE | grep ^https://raw.githubusercontent.com/)"
            if [ -z "$re" ]; then
                wget -O $customListFile $CUSTOM_LIST_FILE
            else
                CUSTOM_LIST_FILE="$(echo $CUSTOM_LIST_FILE | sed "s/raw.githubusercontent.com/pd.zwc365.com\/https:\/\/&/g")"
                wget -O $customListFile $CUSTOM_LIST_FILE
            fi
        }
        customList
        if [ $? -ne 0 ]; then
            echo "更新自定义定时任务列表出错❌，跳过"
        else
            echo "更新自定义定时任务列表成功✅"
        fi
    elif [ -f "/scripts/docker/$CUSTOM_LIST_FILE" ]; then
        echo "自定义任务文件为本地挂载。"
        cp -f /scripts/docker/$CUSTOM_LIST_FILE $customListFile
    elif [ -f "/data/$CUSTOM_LIST_FILE" ]; then
        echo "自定义任务文件为本地挂载。"
        cp -f /data/$CUSTOM_LIST_FILE $customListFile
    fi

    if [ -f "$customListFile" ]; then
        if [ "$CUSTOM_LIST_MERGE_TYPE" == "append" ]; then
            echo "合并默认定时任务文件： $DEFAULT_LIST_FILE 和 自定义定时任务文件： $CUSTOM_LIST_FILE"
            echo -e "" >>$mergedListFile
            cat $customListFile >>$mergedListFile
        elif [ "$CUSTOM_LIST_MERGE_TYPE" == "overwrite" ]; then
            echo "配置了自定义任务文件： $CUSTOM_LIST_FILE ，自定义任务类型为： $CUSTOM_LIST_MERGE_TYPE"
            cat $customListFile >$mergedListFile
        else
            echo "配置配置了错误的自定义定时任务类型： $CUSTOM_LIST_MERGE_TYPE ，自定义任务类型为只能为append或者overwrite..."
        fi
    else
        echo "配置的自定义任务文件： $CUSTOM_LIST_FILE 未找到，使用默认配置 $DEFAULT_LIST_FILE"
    fi
else
    echo "当前只使用了默认定时任务文件 $DEFAULT_LIST_FILE"
fi

echo "第3步判断是否配置了默认定时任务..."
if [ $(grep -c "docker_entrypoint.sh" "$mergedListFile") -eq '0' ]; then
    echo "合并后的定时任务文件，未包含必须的默认定时任务，增加默认定时任务..."
    sed -i "1i # 默认定时任务" $mergedListFile
    sed -i "1a 52 *\/1 * * * docker_entrypoint.sh >> \/scripts\/logs\/default_task.log 2>&1" $mergedListFile
else
    echo "合并后的定时任务文件，已包含必须的默认定时任务，跳过执行..."
fi

echo "第4步判断是否配置自定义shell脚本..."
if [ 0"$CUSTOM_SHELL_FILE" = "0" ]; then
    echo "未配置自定shell脚本文件，跳过执行。"
else
    if expr "$CUSTOM_SHELL_FILE" : 'http.*' &>/dev/null; then
        echo "自定义shell脚本为远程脚本，开始下载自定义远程脚本..."
        function customShell() {
            re="$(echo $CUSTOM_SHELL_FILE | grep ^https://raw.githubusercontent.com/)"
            if [ -z "$re" ]; then
                wget -O /scripts/docker/shell_script_mod.sh $CUSTOM_SHELL_FILE
            else
                CUSTOM_SHELL_FILE="$(echo $CUSTOM_SHELL_FILE | sed "s/raw.githubusercontent.com/pd.zwc365.com\/https:\/\/&/g")"
                wget -O /scripts/docker/shell_script_mod.sh $CUSTOM_SHELL_FILE
            fi
        }
        customShell
        if [ $? -ne 0 ]; then
            echo "更新自定义shell脚本出错❌，跳过"
        else
            echo "更新自定义shell脚本成功✅"
        fi
        echo "" >> $mergedListFile
        echo "##############远程脚本##############" >> $mergedListFile
        chmod 777 /scripts/docker/shell_script_mod.sh
        . /scripts/docker/shell_script_mod.sh
        echo "自定义远程shell脚本下载并执行结束。"
    else
        if [ ! -f "$CUSTOM_SHELL_FILE" ]; then
            echo "自定义shell脚本为挂载的脚本文件，但是指定挂载文件不存在，跳过执行。"
        else
            echo "挂载的自定shell脚本，开始执行..."
            echo "" >>$mergedListFile
            echo "##############远程脚本##############" >> $mergedListFile
            chmod 777 $CUSTOM_SHELL_FILE
            . $CUSTOM_SHELL_FILE
            echo "挂载的自定shell脚本，执行结束。"
        fi
    fi
fi

if [ -f "/data/diy_shell.sh" ]; then
    chmod 777 /data/diy_shell.sh
    . /data/diy_shell.sh
fi

echo "第5步执行 proc_file.sh 脚本任务..."
. /jds/jd_scripts/proc_file.sh

echo "第6步判断是否配置了随即延迟参数..."
if [ -n "$RANDOM_DELAY_MAX" ]; then
    if [ "$RANDOM_DELAY_MAX" -ge "1" ]; then
        echo "已设置随机延迟为 $RANDOM_DELAY_MAX , 设置延迟任务中..."
        sed -i "/jd_bean_sign.js\|jd_blueCoin.js\|jd_joy_reward.js\|jd_joy_steal.js\|jd_joy_feedPets.js\|jd_car.js\|jd_car_exchange.js\|jd_shop_sign.js\|jd_super_redrain.js\|jd_half_redrain.js\|jd_super_mh.js\|jd_carnivalcity.js\|jd_xtg.js\|jd_xtg_help.js\|jd_big_winner.js\|jd_cfdtx.js$MY_RANDOM/!s/node/sleep \$((RANDOM % $RANDOM_DELAY_MAX)); node/g" $mergedListFile
    fi
else
    echo "未配置随即延迟对应的环境变量，故不设置延迟任务..."
fi

echo "第7步判断是否开启了自动互助..."
if [ "$ENABLE_AUTO_HELP" = "true" ]; then
    echo "已开启自动互助，设置互助参数中..."
    sed -i "/jd_fruit.js\|jd_pet.js\|jd_plantBean.js\|jd_dreamFactory.js\|jd_jdfactory.js\|jd_crazy_joy.js\|jd_cfd.js\|jd_jxnc.js\|jd_jdzz.js\|jd_bookshop.js\|jd_cash.js\|jd_sgmh.js\|jd_health.js/s/node/. \/scripts\/docker\/auto_help.sh export > \/scripts\/logs\/auto_help_export.log \&\& node/g" $mergedListFile
else
    echo "未开启自动互助，跳过设置互助参数..."
fi

echo "第8步判断是否配置了不运行的脚本..."
if [ -n "$DO_NOT_RUN_SCRIPTS" ]; then
    echo "您配置了不运行的脚本：$DO_NOT_RUN_SCRIPTS"
    arr=${DO_NOT_RUN_SCRIPTS//&/ }
    for item in $arr; do
        sed -ie "s/^[^\]*${item}.js*/# &/g" $mergedListFile
    done
fi

echo "第9步增加 |ts 任务日志输出时间戳..."
sed -i "/\( ts\| |ts\|| ts\)/!s/>>/\|ts >>/g" $mergedListFile

echo "第10步加载最新的定时任务文件..."
if [[ -f "/usr/bin/jd_bot" && -z "$DISABLE_SPNODE" ]]; then
    echo "bot交互与spnode前置条件成立，替换任务列表的 node 指令为 spnode "
    sed -i "s/ node / spnode /g" $mergedListFile
    sed -i "/jd_blueCoin.js\|jd_joy_reward.js\|jd_carnivalcity.js\|jd_xtg.js$MY_CONC/s/spnode/spnode conc/g" $mergedListFile
    CMD="spnode"
else
    CMD="node"
fi
crontab $mergedListFile

echo "第11步处理挂机脚本任务..."
# run_file=("jd_crazy_joy_coin.js" "jd_cfd_loop.js")
# if [[ -n "$CRZAY_JOY_COIN_ENABLE" && "$CRZAY_JOY_COIN_ENABLE" != "Y" ]]; then
#     for i in ${run_file[@]}; do
#         if [[ "$i" == "jd_crazy_joy_coin.js" ]]; then
#             run_file=(${run_file[@]/jd_crazy_joy_coin.js})
#         fi
#     done
# fi
# if [[ -n "$CFD_LOOP_ENABLE" && "$CFD_LOOP_ENABLE" != "Y" ]]; then
#     for i in ${run_file[@]}; do
#         if [[ "$i" == "jd_cfd_loop.js" ]]; then
#             run_file=(${run_file[@]/jd_cfd_loop.js})
#         fi
#     done
# fi
# for i in ${run_file[@]}; do
#     run_hangup $i
# done

echo "第12步将仓库的 docker_entrypoint.sh 脚本更新至系统 /usr/local/bin/docker_entrypoint.sh 内..."
cat /jds/jd_scripts/docker_entrypoint.sh > /usr/local/bin/docker_entrypoint.sh

if [[ -f "/usr/bin/jd_bot" && -z "$DISABLE_SPNODE" ]]; then
    echo "第13步将仓库的 shell_spnode.sh 脚本更新至系统 /usr/local/bin/spnode 内..."
    cat /jds/jd_scripts/shell_spnode.sh > /usr/local/bin/spnode
    if [ -f "/jds/jd_scripts/code_gen_conf.list" ]; then
        echo "第14步生成互助消息需要使用的 code_gen_conf.list 文件..."
        [[ -z "$GEN_CODE_CONF" ]] && GEN_CODE_CONF="/scripts/logs/code_gen_conf.list"
        cp -f /jds/jd_scripts/code_gen_conf.list $GEN_CODE_CONF
    fi
fi
