#!/bin/sh
set -e

echo "定义定时任务合并处理用到的文件路径..."
defaultListFile="/pss/sunert_scripts/$DEFAULT_LIST_FILE"
echo "默认文件定时任务文件路径为 ${defaultListFile}"
if [ $CUSTOM_LIST_FILE ]; then
    customListFile="/pss/sunert_scripts/$CUSTOM_LIST_FILE"
    echo "自定义定时任务文件路径为 ${customListFile}"
fi
mergedListFile="/pss/sunert_scripts/merged_list_file.sh"
echo "合并后定时任务文件路径为 ${mergedListFile}"

echo "第1步将默认定时任务列表添加到合并后定时任务文件..."
cat $defaultListFile >$mergedListFile

echo "第2步执行scripts_update.sh脚本任务..."
sh -x /pss/sunert_scripts/scripts_update.sh

echo "第3步判断是否配置自定义shell脚本..."
if [ 0"$CUSTOM_SHELL_FILE" = "0" ]; then
    echo "未配置自定shell脚本文件，跳过执行。"
else
    if expr "$CUSTOM_SHELL_FILE" : 'http.*' &>/dev/null; then
        echo "自定义shell脚本为远程脚本，开始下载自定义远程脚本..."
        re="$(echo $CUSTOM_SHELL_FILE | grep ^https://raw.githubusercontent.com/)"
        if [ -z $re ]; then
            wget -O /pss/sunert_scripts/pss_shell_mod.sh $CUSTOM_SHELL_FILE
        else
            CUSTOM_SHELL_FILE="$(echo $CUSTOM_SHELL_FILE | sed "s/raw.githubusercontent.com/pd.zwc365.com\/https:\/\/&/g")"
            wget -O /pss/sunert_scripts/pss_shell_mod.sh $CUSTOM_SHELL_FILE
        fi
        echo "下载完成，开始执行..."
        sh -x /pss/sunert_scripts/pss_shell_mod.sh
        echo "自定义远程shell脚本下载并执行结束。"
    else
        if [ ! -f $CUSTOM_SHELL_FILE ]; then
            echo "自定义shell脚本为挂载的脚本文件，但是指定挂载文件不存在，跳过执行。"
        else
            echo "挂载的自定义shell脚本，开始执行..."
            sh -x $CUSTOM_SHELL_FILE
            echo "挂载的自定义shell脚本，执行结束。"
        fi
    fi
fi

echo "第4步判断是否存在自定义任务任务列表并追加..."
if [ $CUSTOM_LIST_FILE ]; then
    echo "您配置了自定义任务文件：$CUSTOM_LIST_FILE，自定义任务类型为：$CUSTOM_LIST_MERGE_TYPE..."
    if [ -f "$customListFile" ]; then
        if [ $CUSTOM_LIST_MERGE_TYPE == "append" ]; then
            echo "合并默认定时任务文件：$DEFAULT_LIST_FILE 和 自定义定时任务文件：$CUSTOM_LIST_FILE"
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

echo "第5步判断是否配置了默认脚本更新任务..."
if [ $(grep -c "docker_entrypoint.sh" $mergedListFile) -eq '0' ]; then
    echo "合并后的定时任务文件，未包含必须的默认定时任务，增加默认定时任务..."
    echo "" >>$mergedListFile
    echo "# 默认定时任务" >>$mergedListFile
    echo "52 */1 * * * docker_entrypoint.sh >> /logs/default_task.log 2>&1" >>$mergedListFile
else
    echo "合并后的定时任务文件，已包含必须的默认定时任务，跳过执行..."
fi

echo "第6步增加 |ts 任务日志输出时间戳..."
sed -i "/\( ts\| |ts\|| ts\)/!s/>>/\|ts >>/g" $mergedListFile

echo "第7步加载最新的定时任务文件..."
crontab $mergedListFile

echo "第8步将仓库的docker_entrypoint.sh脚本更新至系统/usr/local/bin/docker_entrypoint.sh内..."
cat /pss/sunert_scripts/docker_entrypoint.sh >/usr/local/bin/docker_entrypoint.sh
