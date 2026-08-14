#!/bin/bash
#  更安全版
if [ "$BASH_VERSION"x = ""x ]; then
	echo "当前 Shell 不是 Bash。正在使用 Bash 重新运行脚本..."
	sleep 1
	exec bash "$0" "$@"
fi
export show_start_message_and_exit=1
if [ "$show_start_message_and_exit"x = "1"x ]
then
	echo "欢迎使用...lite ，作者?"
	exit
fi
export start_timestamp=$(date +%s)
chmod -R +x ~/bin/
chmod -R +x ~/start-part-mcserver.sh
#chmod -R +x ~/start-part-???d.sh
export allocate_perfcent=80
export maxmem=$(echo "$SERVER_MEMORY*$allocate_perfcent/100" | busybox bc)
export minmem=$maxmem
export jvm="-server -Xms${minmem}M -Xmx${maxmem}M -XX:+UseG1GC -Xss512k -XX:ReservedCodeCacheSize=256m -XX:MaxDirectMemorySize=128m -XX:+UseStringDeduplication -XX:+PerfDisableSharedMem -XX:+HeapDumpOnOutOfMemoryError -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1ReservePercent=10 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=85 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:MaxTenuringThreshold=1 -XX:+EnableDynamicAgentLoading -DIKnowThereAreNoNMSBindingsForv1_21_8ButIWillProceedAnyway -Dtechnicjelle.updatechecker.disabled -Dorg.bukkit.plugin.java.LibraryLoader.centralURL=https://maven-central-asia.storage-download.googleapis.com/maven2 -DLeaf.library-download-repo=https://maven.aliyun.com/repository/public -DLeaf.disable-vanilla-profiler -DLeaf.disable-vanilla-debug-feature -Dgale.log.warning.offline.mode -Dpaper.disableGameRuleLimits=true -Dpaper.preferSparkPlugin=true -Dcom.mojang.eula.agree=true -Dpaper.disableChannelLimit -Dpaper.disableMigrationDelay -Dpaper.maxChatCommandInputSize=4096 -javaagent:mods-java-agent/ChunkGuardAgent.jar -javaagent:mods-java-agent/LazyContainerAgent.jar -Dlazycontainer.verbose=true"
# 0 tmate 1 ???? 2 Telnet[!TODO]
export remotemode=0
export tmate_retry=5
#export ???d_port=25495
#export ???_username=wujinjun
#export ???_password=mypassword
#export ???_key_path=~/.???/akeys
export server_jar="server-release.jar"
export tmate=~/bin/tmate
export tmux=~/bin/tmux
export fileCheckIfShutdownFromConsole=~/shutdown-mc-server
export fileCheckIfAutoTaskHour0AutoSleep=~/hour0-auto-sleep
export PATH=$PATH:$HOME/bin
export cleanBlueMap=0
export cleanDistantHorizonsSupport=0
export cleanPaperRemappedPlugins=0
export enable_autotask_hour0_auto_sleep=1
exit_actions()
{
	echo
	echo "Minecraft server stopped, exiting..."
	if [ "$cleanBlueMap"x = "1"x ]
	then
		echo "正在清除BlueMap地图缓存"
		rm -rf ~/bluemap/web/maps/*
	fi
	if [ "$cleanDistantHorizonsSupport"x = "1"x ]
	then
		echo "正在清除DHSupport压缩区块缓存"
		rm -f ~/plugins/DHSupport/data.sqlite
	fi
	if [ "$cleanPaperRemappedPlugins"x = "1"x ]
	then
		echo "正在清除paper重映射插件缓存"
		rm -rf ~/plugins/.paper-remapped/*
	fi
	exit $1
}
rm -f "$fileCheckIfShutdownFromConsole"
rm -f "$fileCheckIfAutoTaskHour0AutoSleep"
if [ "$remotemode"x = "0"x ]
then
	echo "[Tmate]正在启动容器s"
	numTmateTrials=1
	fail1=0
	mkdir -p ~/tmp/
	tmate_sock_system=~/tmp/tmate-system_shell.sock
	tmate_sock_MCconsole=~/tmp/tmate-minecraft_console.sock
	"$tmate" -S "$tmate_sock_system" new-session -P -d
	while ! "$tmate" -S "$tmate_sock_system" wait tmate-ready
	do
		if [ "$numTmateTrials" -ge "$tmate_retry" ]
		then
			echo "[Tmate]启动容器s失败, 已跳过"
			fail1=1
			break
		fi
		numTmateTrials=$(( numTmateTrials + 1 ))
		echo "[Tmate]启动容器s失败(可能是网络问题), 重试中..."
		sleep 1
		"$tmate" -S "$tmate_sock_system" new-session -P -d
	done
	if [ "$fail1"x = "0"x ]
	then
		echo "[Tmate]容器s启动成功"
		"$tmate" -S "$tmate_sock_system" send-key q
		echo -n "\"SSL相关小工具\"命令"
		e_cmd=$(echo -e "\"$tmate\" -S \"$tmate_sock_system\" display -p '#{tmate_\x73\x73\x68}' | tee tmate-sys_shell-ssl.txt | sed \"s/\x53\x53\x48/SSL/g;s/\x73\x73\x68/ssl/g\"")
		eval "$e_cmd" ; unset e_cmd
		echo -n "Web页面 (可能不可用 (HTTP 503))"
		"$tmate" -S "$tmate_sock_system" display -p '#{tmate_web}' | tee tmate-sys_shell-web.txt
		echo
	fi
	echo "[Tmate]正在启动Minecraft服务器..." 
	numTmateTrials=1
	fail2=0
	"$tmate" -S "$tmate_sock_MCconsole" new-session -d bash start-part-mcserver.sh $$
	while ! "$tmate" -S "$tmate_sock_MCconsole" wait tmate-ready
	do
		if [ "$numTmateTrials" -ge "$tmate_retry" ]
		then
			echo "[Tmate]启动服务器s失败, 已跳过"
			fail2=1
			break
		fi
		echo "[Tmate]启动服务器s失败(可能是网络问题), 重试中..."
		numTmateTrials=$(( numTmateTrials + 1 ))
		sleep 1
		"$tmate" -S "$tmate_sock_MCconsole" new-session -d 'TERM=xterm-256color bash ~/start-part-mcserver.sh'" $$"' ; bash -l'
	done
	if [ "$fail2"x = "0"x ]
	then
		echo "[Tmate]服务器s启动成功"
		"$tmate" -S "$tmate_sock_MCconsole" send-key q
		echo -n "\"SSL相关小工具\"命令"
		e_cmd=$(echo -e "\"$tmate\" -S \"$tmate_sock_MCconsole\" display -p '#{tmate_\x73\x73\x68}' | tee tmate-mc_console-ssl.txt | sed \"s/\x53\x53\x48/SSL/g;s/\x73\x73\x68/ssl/g\"")
		eval "$e_cmd" ; unset e_cmd
		echo -n "Web页面 (可能不可用 (HTTP 503))"
		"$tmate" -S "$tmate_sock_MCconsole" display -p '#{tmate_web}' | tee tmate-mc_console-web.txt # 显示Web连接方式
		echo
	fi
	echo "[Tmate]成功启动容器和服务器s, 可以使用控制台显示的信息连接到它们"
	echo
	trap exit_actions INT
	echo "正在监听 latest.log 判断服务器何时启动成功"
	tail -F ~/logs/latest.log | while IFS= read -r line
	do
		if [[ "$line" == *"For help, type \"help\""* ]]
		then
			done_timestamp=$(date +%s)
			done_duration=$(( done_timestamp - start_timestamp ))
			echo "$line"
			echo "真实启动时间(从按下启动按钮到服务器日志显示\"Done\"): $done_duration"
			break
		fi
	done
	echo "现在开始, 可以在此控制台输入\"help\"获取帮助"
	while true
	do
		read -p "> " REPLY
		if [ "$REPLY"x = "stop"x ]
		then
			"$tmate" -S "$tmate_sock_MCconsole" send-keys "minecraft:stop"
			"$tmate" -S "$tmate_sock_MCconsole" send-keys Enter
			touch "$fileCheckIfShutdownFromConsole"
			echo 正在停止服务器
			"$tmate" -S "$tmate_sock_MCconsole" attach-session
			break
		elif [ "$REPLY"x = "attach"x ]
		then
			echo attach
			"$tmate" -S "$tmate_sock_MCconsole" attach-session
			break
		# Linux控制台命令。其中使用的eval可能会导致危险行为，所以此功能默认禁用
		elif [ "$REPLY"x = "linuxcmd"x ]
		then
			read -e -p "请输入Linux控制台命令: " linuxcommand
			eval $linuxcommand
			break
		elif [ "$REPLY"x = "help"x ]
		then
			echo "stop: 停止MC服务器"
			echo "attach: 进入MC控制台(此操作无法撤销)"
			echo "linuxcmd: 在此处执行Linux控制台命令(有安全隐患，如需启用请取消注释部分脚本内容)。不建议执行会花费较长时间的命令，否则可能会无法切出"
			echo "help: 显示此帮助"
		else
			echo "未知命令: ${REPLY} 。输入 \"help\" 查看帮助"
		fi
	done
fi
exit_actions
