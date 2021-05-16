#!/bin/sh
set -e

echo "定义定时任务合并处理用到的文件路径..."
defaultListFile="/pss/AutoSignMachine/$DEFAULT_LIST_FILE"
echo "默认文件定时任务文件路径为 ${defaultListFile}"
if [ $CUSTOM_LIST_FILE ]; then
    customListFile="/pss/AutoSignMachine/$CUSTOM_LIST_FILE"
    echo "自定义定时任务文件路径为 ${customListFile}"
fi
mergedListFile="/pss/AutoSignMachine/merged_list_file.sh"
echo "合并后定时任务文件路径为 ${mergedListFile}"

echo "第1步将默认定时任务列表添加到合并后定时任务文件..."
cat $defaultListFile >$mergedListFile

echo "第2步执行scripts_update.sh脚本任务..."
sh -x /pss/AutoSignMachine/scripts_update.sh

echo "第3步判断是否存在自定义任务任务列表并追加..."
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

echo "第4步判断是否配置了默认脚本更新任务..."
if [ $(grep -c "docker_entrypoint.sh" $mergedListFile) -eq '0' ]; then
    echo "合并后的定时任务文件，未包含必须的默认定时任务，增加默认定时任务..."
    echo "" >>$mergedListFile
    echo "# 默认定时任务" >>$mergedListFile
    echo "52 */1 * * * docker_entrypoint.sh >> /logs/default_task.log 2>&1" >>$mergedListFile
else
    echo "合并后的定时任务文件，已包含必须的默认定时任务，跳过执行..."
fi

echo "第5步增加 |ts 任务日志输出时间戳..."
sed -i "/\( ts\| |ts\|| ts\)/!s/>>/\|ts >>/g" $mergedListFile

echo "第6步加载最新的定时任务文件..."
crontab $mergedListFile

echo "第7步将仓库的docker_entrypoint.sh脚本更新至系统/usr/local/bin/docker_entrypoint.sh内..."
cat /pss/AutoSignMachine/docker_entrypoint.sh >/usr/local/bin/docker_entrypoint.sh
