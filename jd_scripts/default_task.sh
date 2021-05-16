#!/bin/sh
set -e

function initPythonEnv() {
    echo "开始安装运行jd_bot需要的python环境及依赖..."
    sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
    mkdir -p /root/.pip
    (
        cat <<EOF
[global]
timeout = 6000
index-url = https://pypi.mirrors.ustc.edu.cn/simple
EOF
    ) > /root/.pip/pip.conf
    echo "开始安装jd_bot依赖..."
    cd /scripts/docker/bot
    pip3 install --upgrade pip
    pip3 install -r requirements.txt
    python3 setup.py install
}

#启动tg bot交互前置条件成立，开始安装配置环境
if [ "$1" == "True" ]; then
    initPythonEnv
    if [ -z "$DISABLE_SPNODE" ]; then
        echo "增加命令组合spnode ，使用该命令spnode jd_xxxx.js 执行js脚本会读取cookies.conf里面的jd cokie账号来执行脚本"
        (
            cat <<EOF
#!/bin/sh
set -e
first=\$1
cmd=\$*
echo \${cmd/\$1/}
if [ \$1 == "conc" ]; then
    for job in \$(cat \$COOKIES_LIST | grep -v "#" | paste -s -d ' '); do
        { export JD_COOKIE=\$job && node \${cmd/\$1/}
        }&
    done
elif [ -n "\$(echo \$first | sed -n "/^[0-9]\+\$/p")" ]; then
    echo "\$(echo \$first | sed -n "/^[0-9]\+\$/p")"
    { export JD_COOKIE=\$(sed -n "\${first}p" \$COOKIES_LIST) && node \${cmd/\$1/}
    }&
elif [ -n "\$(cat \$COOKIES_LIST  | grep "pt_pin=\$first")" ];then
    echo "\$(cat \$COOKIES_LIST  | grep "pt_pin=\$first")"
    { export JD_COOKIE=\$(cat \$COOKIES_LIST | grep "pt_pin=\$first") && node \${cmd/\$1/}
    }&
else
    { export JD_COOKIE=\$(cat \$COOKIES_LIST | grep -v "#" | paste -s -d '&') && node \$*
    }&
fi
EOF
        ) > /usr/local/bin/spnode
        chmod +x /usr/local/bin/spnode
    fi

    echo "spnode需要使用，cookie写入文件，该文件同时也为jd_bot扫码自动获取cookie服务"
    if [ -z "$JD_COOKIE" ]; then
        if [ ! -f "$COOKIES_LIST" ]; then
            echo "" > $COOKIES_LIST
            echo "未配置JD_COOKIE环境变量，$COOKIES_LIST文件已生成,请将cookies写入$COOKIES_LIST文件，格式每个Cookie一行"
        fi
    else
        if [ -f "$COOKIES_LIST" ]; then
            echo "cookies.conf文件已经存在跳过,如果需要更新cookie请修改$COOKIES_LIST文件内容"
        else
            echo "环境变量 cookies写入$COOKIES_LIST文件,如果需要更新cookie请修改cookies.conf文件内容"
            echo $JD_COOKIE | sed "s/[ &]/\\n/g" | sed "/^$/d" >$COOKIES_LIST
        fi
    fi

    echo "容器jd_bot交互所需环境已配置安装已完成..."
    line=$'\n\n'
    curl -sX POST "https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage" -d "chat_id=$TG_USER_ID&text=恭喜🎉你获得feature$line容器jd_bot交互所需环境已配置安装已完成，并启用。请发送 /help 查看使用帮助。如需禁用请在 docker-compose.yml配置 DISABLE_BOT_COMMAND=True" >>/dev/null

fi

echo "定义定时任务合并处理用到的文件路径..."
defaultListFile="/scripts/docker/$DEFAULT_LIST_FILE"
echo "默认文件定时任务文件路径为 $defaultListFile"
mergedListFile="/scripts/docker/merged_list_file.sh"
echo "合并后定时任务文件路径为 $mergedListFile"

echo "第1步将默认定时任务列表添加到合并后定时任务文件..."
cat $defaultListFile >$mergedListFile

echo "第2步判断是否存在自定义任务任务列表并追加..."
if [ $CUSTOM_LIST_FILE ]; then
    echo "您配置了自定义任务文件：$CUSTOM_LIST_FILE，自定义任务类型为：$CUSTOM_LIST_MERGE_TYPE..."
    customListFile="/scripts/docker/custom_list_file.sh"
    if expr "$CUSTOM_LIST_FILE" : 'http.*' &>/dev/null; then
        echo "自定义任务文件为远程脚本，开始下载自定义远程任务..."
        re="$(echo $CUSTOM_LIST_FILE | grep https://raw.githubusercontent.com/)"
        if [ $re == "" ]; then
            wget -O $customListFile $CUSTOM_LIST_FILE
        else
            CUSTOM_LIST_FILE="$(echo $CUSTOM_LIST_FILE | sed "s/raw.githubusercontent.com/pd.zwc365.com\/seturl\/https:\/\/&/g")"
            wget -O $customListFile $CUSTOM_LIST_FILE
        fi
        echo "下载完成。"
    elif [ -f /scripts/docker/$CUSTOM_LIST_FILE ]; then
        echo "自定义任务文件为本地挂载。"
        cp -f /scripts/docker/$CUSTOM_LIST_FILE $customListFile
    fi

    if [ -f "$customListFile" ]; then
        if [ $CUSTOM_LIST_MERGE_TYPE == "append" ]; then
            echo "合并默认定时任务文件：$DEFAULT_LIST_FILE 和 自定义定时任务文件：$CUSTOM_LIST_FILE"
            echo -e "" >>$mergedListFile
            cat $customListFile >>$mergedListFile
        elif [ $CUSTOM_LIST_MERGE_TYPE == "overwrite" ]; then
            echo "配置了自定义任务文件：$CUSTOM_LIST_FILE，自定义任务类型为：$CUSTOM_LIST_MERGE_TYPE..."
            cat $customListFile >$mergedListFile
        else
            echo "配置配置了错误的自定义定时任务类型：$CUSTOM_LIST_MERGE_TYPE，自定义任务类型为只能为append或者overwrite..."
        fi
    else
        echo "配置的自定义任务文件：$CUSTOM_LIST_FILE未找到，使用默认配置$DEFAULT_LIST_FILE..."
    fi
else
    echo "当前只使用了默认定时任务文件 $DEFAULT_LIST_FILE ..."
fi

echo "第3步判断是否配置了默认定时任务..."
if [ $(grep -c "docker_entrypoint.sh" $mergedListFile) -eq '0' ]; then
    echo "合并后的定时任务文件，未包含必须的默认定时任务，增加默认定时任务..."
    echo "# 默认定时任务" >>$mergedListFile
    echo "52 */1 * * * docker_entrypoint.sh >> /scripts/logs/default_task.log 2>&1" >>$mergedListFile
else
    echo "合并后的定时任务文件，已包含必须的默认定时任务，跳过执行..."
fi

echo "第4步判断是否配置自定义shell脚本..."
if [ 0"$CUSTOM_SHELL_FILE" = "0" ]; then
    echo "未配置自定shell脚本文件，跳过执行。"
else
    if expr "$CUSTOM_SHELL_FILE" : 'http.*' &>/dev/null; then
        echo "自定义shell脚本为远程脚本，开始下载自定义远程脚本..."
        re="$(echo $CUSTOM_SHELL_FILE | grep https://raw.githubusercontent.com/)"
        if [ $re == "" ]; then
            wget -O /scripts/docker/shell_script_mod.sh $CUSTOM_SHELL_FILE
        else
            CUSTOM_SHELL_FILE="$(echo $CUSTOM_SHELL_FILE | sed "s/raw.githubusercontent.com/pd.zwc365.com\/seturl\/https:\/\/&/g")"
            wget -O /scripts/docker/shell_script_mod.sh $CUSTOM_SHELL_FILE
        fi
        echo "下载完成，开始执行..."
        echo "" >>$mergedListFile
        echo "##############远程脚本##############" >>$mergedListFile
        sh /scripts/docker/shell_script_mod.sh
        echo "自定义远程shell脚本下载并执行结束。"
    else
        if [ ! -f $CUSTOM_SHELL_FILE ]; then
            echo "自定义shell脚本为挂载的脚本文件，但是指定挂载文件不存在，跳过执行。"
        else
            echo "挂载的自定shell脚本，开始执行..."
            echo "" >>$mergedListFile
            echo "##############远程脚本##############" >>$mergedListFile
            sh $CUSTOM_SHELL_FILE
            echo "挂载的自定shell脚本，执行结束。"
        fi
    fi
fi

echo "第5步执行proc_file.sh脚本任务..."
sh /scripts/docker/proc_file.sh

echo "第6步判断是否配置了随即延迟参数..."
if [ $RANDOM_DELAY_MAX ]; then
    if [ $RANDOM_DELAY_MAX -ge 1 ]; then
        echo "已设置随机延迟为 $RANDOM_DELAY_MAX , 设置延迟任务中..."
        sed -i "/jd_bean_sign.js\|jd_blueCoin.js\|jd_joy_reward.js\|jd_joy_steal.js\|jd_joy_feedPets.js\|jd_car.js\|jd_car_exchange.js\|jd_shop_sign.js\|monk_inter_shop_sign.js\|jd_super_redrain.js\|jd_half_redrain.js\|jd_super_mh.js/!s/node/sleep \$((RANDOM % \$RANDOM_DELAY_MAX)); node/g" $mergedListFile
    fi
else
    echo "未配置随即延迟对应的环境变量，故不设置延迟任务..."
fi

echo "第7步判断是否开启了自动互助..."
if [ $ENABLE_AUTO_HELP = "true" ]; then
    echo "已开启自动互助，设置互助参数中..."
    sed -i "/jd_fruit.js\|jd_pet.js\|jd_plantBean.js\|jd_dreamFactory.js\|jd_jdfactory.js\|jd_crazy_joy.js\|jd_cfd.js\|jd_jxnc.js\|jd_jdzz.js\|jd_bookshop.js\|jd_cash.js\|jd_sgmh.js\|jd_health.js/s/node/. \/scripts\/docker\/auto_help.sh export > \/scripts\/logs\/auto_help_export.log \&\& node/g" $mergedListFile
else
    echo "未开启自动互助，跳过设置互助参数..."
fi

echo "第8步判断是否配置了不运行的脚本..."
if [ $DO_NOT_RUN_SCRIPTS ]; then
    echo "您配置了不运行的脚本：$DO_NOT_RUN_SCRIPTS"
    arr=${DO_NOT_RUN_SCRIPTS//&/ }
    for item in $arr; do
        sed -ie "s/^[^\]*${item}.js*/#&/g" $mergedListFile
    done
fi

echo "第9步增加 |ts 任务日志输出时间戳..."
sed -i "/\( ts\| |ts\|| ts\)/!s/>>/\|ts >>/g" $mergedListFile

echo "第10步加载最新的定时任务文件..."
if [[ -f /usr/bin/jd_bot && -z "$DISABLE_SPNODE" ]]; then
    echo "bot交互与spnode前置条件成立，替换任务列表的node指令为spnode"
    sed -i "/jddj_/!s/ node / spnode /g" $mergedListFile
    sed -i "/jd_blueCoin.js\|jd_joy_reward.js/s/spnode/spnode conc/g" $mergedListFile
fi
crontab $mergedListFile

echo "第11步生成互助消息需要使用的 logs/code_gen_conf.list 文件..."
if [ -f "/jds/jd_scripts/code_gen_conf.list" ]; then
    CODE_GEN_CONF=/scripts/logs/code_gen_conf.list
    cp -f /jds/jd_scripts/code_gen_conf.list $CODE_GEN_CONF
fi

echo "第12步将仓库的docker_entrypoint.sh脚本更新至系统/usr/local/bin/docker_entrypoint.sh内..."
cat /scripts/docker/docker_entrypoint.sh >/usr/local/bin/docker_entrypoint.sh
