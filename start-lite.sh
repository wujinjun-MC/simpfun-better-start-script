#!/bin/bash
#  更安全版
if [ "$BASH_VERSION"x = ""x ]; then
	echo "当前 Shell 不是 Bash。正在使用 Bash 重新运行脚本..."
	sleep 1
	exec bash "$0" "$@"
fi
export show_start_message_and_exit=1
if [ "$show_start_message_and_exit"x = "1"x ]; then
	echo "欢迎使用...lite ，作者...(↓)"
	echo "Copyright © 2026 wujinjun-MC, released under GPL 3.0."
	echo "Please accept ToS of this script. You can find it in the full version!"
	exit
fi
export start_timestamp=$(date +%s)
#env > ~/.current_env
#id > ~/.current_id
chmod -R +x ~/bin/
chmod -R +x ~/start-part-*.sh
chmod -R +x ~/.tmux.switch-client.sh
chmod -R +x ~/scripts/*.sh
export PATH=$PATH:$HOME/bin:$HOME/bin/coreutils
export allocate_percent=80
export maxmem=$(echo "$SERVER_MEMORY*$allocate_percent/100" | busybox bc)
export minmem=$maxmem
export jvm="-server -Xms${minmem}M -Xmx${maxmem}M -XX:+UseG1GC -Xss512k -XX:ReservedCodeCacheSize=256m -XX:MaxDirectMemorySize=128m -XX:+UseStringDeduplication -XX:+PerfDisableSharedMem -XX:+HeapDumpOnOutOfMemoryError -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1ReservePercent=10 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=85 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:MaxTenuringThreshold=1 -XX:+EnableDynamicAgentLoading -DIKnowThereAreNoNMSBindingsForv26_2ButIWillProceedAnyway -Dtechnicjelle.updatechecker.disabled -Dorg.bukkit.plugin.java.LibraryLoader.centralURL=https://maven-central-asia.storage-download.googleapis.com/maven2 -DLeaf.library-download-repo=https://maven.aliyun.com/repository/public -DLeaf.disable-vanilla-profiler -DLeaf.disable-vanilla-debug-feature -Dgale.log.warning.offline.mode=false -Dgale.log.warning.root=false -DLeaf.enableFMA" # " -Dpaper.disableGameRuleLimits=true -Dpaper.preferSparkPlugin=true -Dcom.mojang.eula.agree=true -Dpaper.disableChannelLimit -Dpaper.disableMigrationDelay -Dpaper.maxChatCommandInputSize=4096 -javaagent:mods-java-agent/ChunkGuardAgent.jar -Dchunkguard.shadow=true -javaagent:mods-java-agent/LazyContainerAgent.jar -Dlazycontainer.verbose=true -Dlazycontainer.shadow=true -javaagent:plugins/farlandsorigin.jar"
# 0 tmate 1 ???? 2 Handy-???d + Cpolar 3 Telnet [!TODO]
export remotemode=0
export tmate_retry=5
#export ???d_port=25495
#export ???_username=wujinjun
#export ???_password=mypassword
#export ???_key_path=~/.???/akeys
export cpolar_config=~/.cpolar/cpolar.yml
export cpolar_log=~/.cpolar/cpolar.log
export ssld_port=12345
export ssl_username=wujinjun
export ssl_password=mypassword
export ssl_key_path=~/.ssl/akeys
export server_jar="server-release.jar"
export tmate=~/bin/tmate
export tmux=~/bin/tmux
export cpolar=~/bin/cpolar
export fileCheckIfShutdownFromConsole=~/shutdown-mc-server
export fileCheckIfAutoTaskHour0AutoSleep=~/hour0-auto-sleep
export tmux_tmate_attach_safe_exit=1
export autotask_hour0_auto_sleep=1
exit_actions()
{
	echo
	echo "Minecraft server stopped, exiting..."
	bash ~/scripts/cache-cleanup.sh
	exit $1
}
rm -f "$fileCheckIfShutdownFromConsole"
rm -f "$fileCheckIfAutoTaskHour0AutoSleep"
if [ "$remotemode"x = "2"x ]; then
	echo "✅ [定时任务] 启动 \"0点自动关服并等待\" 。"
	bash ~/scripts/autotask_hour0_auto_sleep-tmux.sh &
fi
if [ "$remotemode"x = "0"x ]
then
	echo "[Tmate]正在启动容器s"
	numTmateTrials=1
	fail1=0
	mkdir -p ~/tmp/
	tmate_sock_system=~/tmp/tmate-system_shell.sock
	tmate_sock_MCconsole=~/tmp/tmate-minecraft_console.sock
	"$tmate" -S "$tmate_sock_system" new-session -P -d
	while ! "$tmate" -S "$tmate_sock_system" wait tmate-ready; do
		if [ "$numTmateTrials" -ge "$tmate_retry" ]; then
			echo "[Tmate]启动容器s失败, 已跳过"
			fail1=1
			break
		fi
		numTmateTrials=$(( numTmateTrials + 1 ))
		echo "[Tmate]启动容器s失败(可能是网络问题), 重试中..."
		sleep 1
		"$tmate" -S "$tmate_sock_system" new-session -P -d
	done
	if [ "$fail1"x = "0"x ]; then
		echo "[Tmate]容器s启动成功"
		"$tmate" -S "$tmate_sock_system" send-key q
		echo -n "\"SSL相关小工具\"命令"
		e_cmd=$(echo -e "\"$tmate\" -S \"$tmate_sock_system\" display -p '#{tmate_\x73\x73\x68}' 2>&1 | tee tmate-sys_shell-ssl.txt | sed \"s/\x53\x53\x48/SSL/g;s/\x73\x73\x68/ssl/g\"")
		eval "$e_cmd" ; unset e_cmd
		echo -n "Web页面 (可能不可用 (HTTP 503))"
		"$tmate" -S "$tmate_sock_system" display -p '#{tmate_web}' 2>&1 | tee tmate-sys_shell-web.txt
		echo
	fi
	echo "[Tmate]正在启动Minecraft服务器..." 
	numTmateTrials=1
	fail2=0
	"$tmate" -S "$tmate_sock_MCconsole" new-session -d bash start-part-mcserver.sh $$
	while ! "$tmate" -S "$tmate_sock_MCconsole" wait tmate-ready; do
		if [ "$numTmateTrials" -ge "$tmate_retry" ]; then
			echo "[Tmate]启动服务器s失败, 已跳过"
			fail2=1
			break
		fi
		echo "[Tmate]启动服务器s失败(可能是网络问题), 重试中..."
		numTmateTrials=$(( numTmateTrials + 1 ))
		sleep 1
		"$tmate" -S "$tmate_sock_MCconsole" new-session -d 'TERM=xterm-256color bash ~/start-part-mcserver.sh'" $$"' ; bash -l'
	done
	if [ "$fail2"x = "0"x ]; then
		echo "[Tmate]服务器s启动成功"
		"$tmate" -S "$tmate_sock_MCconsole" send-key q
		echo -n "\"SSL相关小工具\"命令"
		e_cmd=$(echo -e "\"$tmate\" -S \"$tmate_sock_MCconsole\" display -p '#{tmate_\x73\x73\x68}' 2>&1 | tee tmate-mc_console-ssl.txt | sed \"s/\x53\x53\x48/SSL/g;s/\x73\x73\x68/ssl/g\"")
		eval "$e_cmd" ; unset e_cmd
		echo -n "Web页面 (可能不可用 (HTTP 503))"
		"$tmate" -S "$tmate_sock_MCconsole" display -p '#{tmate_web}' 2>&1 | tee tmate-mc_console-web.txt # 显示Web连接方式
		echo
	fi
	echo "[Tmate]成功启动容器和服务器s, 可以使用控制台显示的信息连接到它们"
	echo
	trap exit_actions INT
	echo "正在监听 latest.log 判断服务器何时启动成功"
	tail -F ~/logs/latest.log | while IFS= read -r line; do
		if [[ "$line" == *"For help, type \"help\""* ]]; then
			done_timestamp=$(date +%s)
			done_duration=$(( done_timestamp - start_timestamp ))
			echo "$line"
			echo "真实启动时间(从按下启动按钮到服务器日志显示\"Done\"): $done_duration"
			break
		fi
	done
	echo "服务器启动成功, 已进入 \"pseudo\" 控制台, 输入\"help\"获取帮助"
	while true; do
		read -p "> " REPLY
		if [ "$REPLY"x = "stop"x ]; then
			"$tmate" -S "$tmate_sock_MCconsole" send-keys "minecraft:stop"
			"$tmate" -S "$tmate_sock_MCconsole" send-keys Enter
			touch "$fileCheckIfShutdownFromConsole"
			echo 正在停止服务器
			"$tmate" -S "$tmate_sock_MCconsole" attach-session
			break
		elif [ "$REPLY"x = "attach"x ]; then
			echo attach
			"$tmate" -S "$tmate_sock_MCconsole" attach-session
			if [ "$tmux_tmate_attach_safe_exit"x = "1"x ]; then
				echo "[WARN] 你之前已经进入MC控制台，但现在被退出，可能因为 tmux/tmate 停止，或MC服务器停止。"
				read -p "输入\"stop\"立即退出 \"pseudo\" 控制台，完全关闭服务器；输入其他则回到 \"pseudo\" 控制台: " REPLY
				if [ "$REPLY"x = "stop"x ]; then
					break
				fi
			else
				break
			fi
		# Linux控制台命令。其中使用的eval可能会导致危险行为，所以此功能默认禁用
		# elif [ "$REPLY"x = "linuxcmd"x ]; then
		# 	read -e -p "请输入Linux控制台命令: " linuxcommand
		# 	eval $linuxcommand
		# 	break
		elif [ "$REPLY"x = "help"x ]; then
			echo "stop: 停止MC服务器"
			echo "attach: 进入MC控制台(此操作无法撤销)"
			echo "linuxcmd: 在此处执行Linux控制台命令(有安全隐患，如需启用请取消注释部分脚本内容)。不建议执行会花费较长时间的命令，否则可能会无法切出"
			echo "help: 显示此帮助"
		else
			echo "未知命令: ${REPLY} 。输入 \"help\" 查看帮助"
		fi
	done
elif [ "$remotemode"x = "2"x ]; then
	echo "[Tmux] 正在启动cpolar_friend_1_ssl"
	export handy_ssld_command=~/bin/cpolar_friend_1_ssl
	ssld_args=("--host" "127.0.0.1" "-p" "$ssld_port")
	if [[ -n "$ssl_username" && -n "$ssl_password" ]]; then
		ssld_args+=("--user" "$ssl_username:$ssl_password")
	fi
	if [[ -n "$ssl_key_path" ]]; then
		ssld_args+=("--keys" "$ssl_key_path")
	fi
	export handy_ssld_args="${ssld_args[@]}"
	# echo "[Tmux] 执行命令: $handy_ssld_command $handy_ssld_args"
	"$tmux" new-session -ds cpolar_friend_1_ssl "bash ~/start-part-ssld.sh 2>&1 | tee ssld-log.txt"
	ssl_command="ssl -p <端口>"
	if [[ -n "$ssl_username" ]]; then
		ssl_command2="$ssl_username@<cpolar域名>"
	else
		ssl_command2="<cpolar域名>"
	fi
	echo "---"
	echo "✅ 内部SSL服务器已启动($ssld_port)"
	echo "---"
	echo "[Tmux] 正在启动cpolar"
	"$tmux" new-session -ds cpolar "bash ~/start-part-cpolar.sh 2>&1 | tee cpolar-log.txt"
	echo "---"
	echo "✅ Cpolar服务已启动"
	echo "➡️ 在Cpolar控制台查看连接信息"
	echo "对于http类型，你会看到 http/https 开头的连接，直接点击即可"
	echo "对于tcp类型，你会看到 tcp://<cpolar域名>:<端口> 格式的链接，如果要ssl连接，需要转换为ssl命令 (例子: tcp://1.tcp.cpolar.cn:12345)"
	echo "命令: $ssl_command $ssl_command2"
	echo "(例子: ssl -p 12345 $ssl_username@1.tcp.cpolar.cn)"
	if [[ -n "$ssl_key_path" ]]; then
		echo "💡 你已设置密钥连接，使用对应的密钥对将无需输入用户名和密码(如果有)"
		echo "   命令示例: ssl -p $ssld_port -i /path/to/your/pkey ${ssl_username}@play.simpfun.cn"
		echo "   (例子: ssl -p $ssld_port -i /path/to/your/pkey ${ssl_username}@play.simpfun.cn)"
	fi
	echo "➡️ 连接后，使用以下命令进入控制台："
	echo "tmux attach -t mcserver_console"
	echo "---"
	echo "---"
	echo "🌐 端口转发 (Port Forwarding)"
	echo "---"
	echo "如需从本地访问容器内部端口，请使用端口转发功能。"
	echo "命令格式: \"$ssl_command -L <本地端口>:127.0.0.1:<远程端口> $ssl_command2\""
	echo "示例: \"$ssl_command -L 9999:127.0.0.1:9999 $ssl_command2\""
	echo "然后，您就可以通过访问 \"localhost:<本地端口>\" 来连接到容器内的服务。"
	echo ""
	echo "---"
	echo "🚀 启动 Minecraft 服务器"
	echo "---"
	echo "▶️ [Tmux] 正在启动 Minecraft 服务器..."
	"$tmux" new-session -ds mcserver_console 'TERM=xterm-256color bash ~/start-part-mcserver.sh $$ ; bash -l'
	echo "✅ [Tmux] Minecraft 服务器已开始启动，运行在端口 $SERVER_PORT。"
	echo "连接SSL后，可以使用命令 \"tmux attach -t mcserver_console\" 进入服务器控制台。"
	echo ""
	echo "---"
	echo "Note: 如何保持服务器运行"
	echo "---"
	echo "如果你希望在退出脚本后服务器进程仍然运行，"
	echo "请在MC控制台输入stop停止，在MC服务器重启前快速找到旧的启动脚本进程并结束它。使用以下步骤："
	echo "1. 使用 \"pgrep -a bash\" 查找带有start-part-mcserver.sh的 bash进程 的 PID。"
	echo "2. 使用 \"kill -s 9 <PID>\" 强制结束该进程。"
	echo "这样可以防止新的启动脚本启动后与旧的脚本冲突。"
	echo ""
	echo "---"
	echo "⏳ 日志监控"
	echo "---"
	echo "正在监听 \"latest.log\" 文件，判断服务器何时启动成功..."
	trap exit_actions INT
	tail -F ~/logs/latest.log | while IFS= read -r line; do
		if [[ "$line" == *"For help, type \"help\""* ]]; then
			done_timestamp=$(date +%s)
			done_duration=$(( done_timestamp - start_timestamp ))
			echo "$line"
			echo "真实启动时间(从按下启动按钮到服务器日志显示\"Done\"): $done_duration"
			break
		fi
	done
	echo "服务器启动成功, 已进入 \"pseudo\" 控制台, 输入\"help\"获取帮助"
	while true; do
		read -p "> " REPLY
		if [ "$REPLY"x = "stop"x ]; then
			echo 正在停止服务器
			sleep 1
			"$tmux" send-keys -t mcserver_console "minecraft:stop"
			"$tmux" send-keys -t mcserver_console Enter
			touch "$fileCheckIfShutdownFromConsole"
			"$tmux" attach -t mcserver_console
			break
		elif [ "$REPLY"x = "attach"x ]; then
			echo attach
			"$tmux" attach -t mcserver_console
			if [ "$tmux_tmate_attach_safe_exit"x = "1"x ]; then
				echo "[WARN] 你之前已经进入MC控制台，但现在被退出，可能因为 tmux/tmate 停止，或MC服务器停止。"
				read -p "输入\"stop\"立即退出 \"pseudo\" 控制台，完全关闭服务器；输入其他则回到 \"pseudo\" 控制台: " REPLY
				if [ "$REPLY"x = "stop"x ]; then
					break
				fi
			else
				break
			fi
		# Linux控制台命令。其中使用的eval可能会导致危险行为，所以此功能默认禁用
		# elif [ "$REPLY"x = "linuxcmd"x ]
		# then
		# 	read -e -p "请输入Linux控制台命令: " linuxcommand
		# 	eval $linuxcommand
		# 	break
		elif [ "$REPLY"x = "help"x ]; then
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
