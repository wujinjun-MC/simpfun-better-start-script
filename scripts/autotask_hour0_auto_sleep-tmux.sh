#!/bin/bash
autotask_hour0_auto_sleep=${autotask_hour0_auto_sleep:-1}
flag_file=~/autotask_hour0_auto_sleep
if [ "$autotask_hour0_auto_sleep"x = "1"x ]; then
    touch "$flag_file"
elif [ "$autotask_hour0_auto_sleep"x = "-1"x ]; then
    rm -f "$flag_file"
fi
while true
do
    if [ -f "$flag_file" ]; then
        current_hour=$(date +%H)
        current_minute=$(date +%M)

        if [ "$current_hour"x = "00"x ] && [ "$current_minute"x = "00"x ]
        then
            echo "检测到0点整，正在创建睡眠标志文件并发送停止命令，以保护服务器..."
            touch "$fileCheckIfAutoTaskHour0AutoSleep"
            "$tmux" send-keys -t mcserver_console "minecraft:stop" Enter
            # 360秒后也会自动移除睡眠标志文件，如果没有正确触发睡眠，手动stop时不会进入睡眠
            sleep 360
            rm "$fileCheckIfAutoTaskHour0AutoSleep"
        fi
    fi
    sleep 60
done
