#!/bin/bash

# 服务器核心文件路径
server_jar="server-release.jar"

from_pid=$1
# 这些jdk默认在环境变量提供，如果没有，请修改为正确的路径
# openjdk8="/usr/bin/jdk/jdk1.8.0_361/bin/java"
# openjdk11="/usr/bin/jdk/jdk-11.0.18/bin/java"
# openjdk17="/usr/bin/jdk/jdk-17.0.6/bin/java"
# openjdk19="/usr/bin/jdk/jdk-19.0.2/bin/java"
# openjdk21="/usr/bin/jdk/jdk-21.0.2/bin/java"

# 这些参数已经在start.sh设置为环境变量，这个脚本将使用环境变量的值
# maxmem=$((${SERVER_MEMORY} - 1500))
# minmem=$((${maxmem} / 2))
# fileCheckIfShutdownFromConsole=~/shutdown-mc-server

exit_actions()
{
	kill -n 2 $from_pid
	exit
}

# trap exit_actions INT

# jvm1(deprecated)
# jvm="-server -Xms${minmem}M -Xmx${maxmem}M -Xnoclassgc -XX:+UseG1GC -XX:+UseStringDeduplication -XX:+PerfDisableSharedMem -XX:+ParallelRefProcEnabled -XX:+UnlockExperimentalVMOptions -XX:MaxInlineLevel=16 -XX:MaxGCPauseMillis=200 -XX:+UseCompressedOops -XX:+UseLargePages -XX:+ExplicitGCInvokesConcurrent -XX:FreqInlineSize=325 -XX:MaxInlineSize=35 -XX:InlineSmallCode=2000 -XX:MaxRecursiveInlineLevel=1 -XX:MaxTenuringThreshold=1 -XX:SurvivorRatio=32 -XX:-DontCompileHugeMethods -XX:-CompactStrings -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true"
# jvm2(better) 详情: https://g.co/gemini/share/def3167e45bc
jvm="-server -Xms${minmem}M -Xmx${maxmem}M -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true"


while true
do
	trap '' INT # 防止 Ctrl-C 意外停止服务器
	${openjdk21} $jvm -jar "$server_jar"
	trap exit_actions INT # 恢复 Ctrl-C 功能
	if [ -f "$fileCheckIfShutdownFromConsole" ]
	then
		break
	fi
	echo "服务器已停止或崩溃，30秒后自动重启。输入 \"stop\" 立即停止；输入 \"jvm\" ，然后输入JVM参数以使用自定义JVM参数重启；输入 \"sleep\" ，然后输入时间(秒, 默认10000000)，则等待此时间后停止；输入其他内容则立即重启"
	read -t 30 REPLY
	if [ "$REPLY"x = "stop"x ]
	then
	    break
	elif [ "$REPLY"x = "jvm"x ]
	then
		read -e -p "请输入JVM参数: " -i "$jvm" jvm
	elif [ "$REPLY"x = "sleep"x ]
	then
		read -e -p "等待时间(秒): " -i "10000000" sleep_time
		sleep $sleep_time
	fi
done
wait
exit_actions
