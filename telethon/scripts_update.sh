#!/bin/sh

if [ -f "/telethon/diy.py" ]; then
    echo "脚本存在，配置启用脚本..."
    eval $(ps -ef | grep "diy" | grep -v "grep" | awk '{print "kill "$1}')
    python3 -u /telethon/diy.py |ts >> /logs/diy.log 2>&1 &
    echo "脚本执行完成..."
else
    eval $(ps -ef | grep "diy" | grep -v "grep" | awk '{print "kill "$1}')
    echo "脚本不存在，跳过执行..."
fi

if [ -f "/telethon/jd_json.py" ]; then
    echo "脚本存在，配置启用脚本..."
    eval $(ps -ef | grep "jd_json" | grep -v "grep" | awk '{print "kill "$1}')
    python3 -u /telethon/jd_json.py |ts >> /logs/jd_json.log 2>&1 &
    echo "脚本执行完成..."
else
    eval $(ps -ef | grep "jd_json" | grep -v "grep" | awk '{print "kill "$1}')
    echo "脚本不存在，跳过执行..."
fi

if [ -f "/telethon/jf.py" ]; then
    echo "脚本存在，配置启用脚本..."
    eval $(ps -ef | grep "jf" | grep -v "grep" | awk '{print "kill "$1}')
    python3 -u /telethon/jf.py |ts >> /logs/jf.log 2>&1 &
    echo "脚本执行完成..."
else
    eval $(ps -ef | grep "jf" | grep -v "grep" | awk '{print "kill "$1}')
    echo "脚本不存在，跳过执行..."
fi
