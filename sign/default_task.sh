#!/usr/bin/env bash

echo "定义定时任务合并处理用到的文件路径..."
defaultListFile="/jds/sign/$DEFAULT_LIST_FILE"
echo "默认文件定时任务文件路径为 $defaultListFile"
mergedListFile="/jds/sign/merged_list_file.sh"
echo "合并后定时任务文件路径为 $mergedListFile"

echo "第1步将默认定时任务列表添加到合并后定时任务文件..."
cat $defaultListFile > $mergedListFile

echo "第2步判断是否配置了默认脚本更新任务..."
if [ $(grep -c "docker_entrypoint.sh" $mergedListFile) -eq '0' ]; then
    echo "合并后的定时任务文件，未包含必须的默认定时任务，增加默认定时任务..."
    echo "" >>$mergedListFile
    echo "# 默认定时任务" >>$mergedListFile
    echo "52 */1 * * * docker_entrypoint.sh >> /logs/default_task.log 2>&1" >>$mergedListFile
else
    echo "合并后的定时任务文件，已包含必须的默认定时任务，跳过执行..."
fi

echo "第3步执行 diy_shell.sh 脚本任务..."
if [ -f "/scripts/diy_shell.sh" ]; then
    chmod 777 /scripts/diy_shell.sh
    . /scripts/diy_shell.sh
fi

echo "第4步增加 |ts 任务日志输出时间戳..."
sed -i "/\( ts\| |ts\|| ts\)/!s/>>/\|ts >>/g" $mergedListFile

echo "第5步加载最新的定时任务文件..."
crontab $mergedListFile

echo "第6步将仓库的 shell_spnode.sh 脚本更新至系统 /usr/local/bin/spnode 内..."
cat /jds/sign/docker_entrypoint.sh > /usr/local/bin/docker_entrypoint.sh
