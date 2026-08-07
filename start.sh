#!/bin/bash

#--------预加载区--------

# 检查当前 Shell 是否是 Bash
if [ "$BASH_VERSION"x = ""x ]; then
	echo "当前 Shell 不是 Bash。正在使用 Bash 重新运行脚本..."
	sleep 1
	exec bash "$0" "$@"
fi
# 用户须知
export show_start_message_and_exit=1
if [ "$show_start_message_and_exit"x = "1"x ]
then
	echo "欢迎使用 更好的简幻欢启动脚本 ，作者 wujinjun-MC (https://github.com/wujinjun-MC)"
	echo "在开始使用前，请使用编辑器打开start.sh，在下方配置区中进行配置"
	echo "免责声明: 使用此项目时，用户需自行检查脚本和配置是否正确，自行承担使用风险，不得将此项目用于违反简幻欢(Simpfun)用户条款、中华人名共和国及当地法律法规的行为。wujinjun-MC 不为使用者承担任何责任"
	echo "请遵守开源协议，并保证不将此项目用于销售和其他违规用途。该项目不会对任何人收费。如果您通过任何渠道购买了此项目或其中的一部分，请要求退款"
	echo "如不同意条款，请立即删除此脚本和其他附属文件。"
	echo "如同意，请使用编辑器将show_start_message_and_exit设置为0，然后重新启动实例。"
	exit
fi
# 获取开始启动的时间戳
export start_timestamp=$(date +%s)
# 文件权限准备: 为二进制文件和脚本文件添加执行权限(+x)
chmod -R +x ./bin/
chmod -R +x ./start-part-mcserver.sh
chmod -R +x ./start-part-sshd.sh


#--------配置区--------

# 内存设置
	## 服务器JVM的最大(-Xmx)和预占用(-Xms)内存, 建议最大设置为容器限制的80%, 预占用内存设置等于最大值，避免动态分配效率降低。如果使用的是OpenJDK而不是Zulu，则可以尝试增大百分比
		### export maxmem=$(echo "$SERVER_MEMORY*80/100" | busybox bc)
		### export minmem=$((${maxmem} / 2))
	## (Deprecated)服务器JVM的最大(-Xmx)和预占用(-Xms)内存, 建议最大设置为容器限制-1500, 预占用内存设置为最大的一半
		### export maxmem=$((${SERVER_MEMORY} - 1500))
		### export minmem=$((${maxmem} / 2))
export allocate_perfcent=80
export SERVER_MEMORY=$(free -m | awk '/^Mem:/ {print $2}')
export maxmem=$(echo "$SERVER_MEMORY*$allocate_perfcent/100" | ./bin/busybox bc)
export minmem=$maxmem
# Java设置
	## 不能与 内存设置 交换顺序，因为JVM参数中使用了其中的变量，交换后因值为空而出错
	## JVM参数 优化版 详情: https://g.co/gemini/share/def3167e45bc
# export jvm="-server -Xms${minmem}M -Xmx${maxmem}M -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -XX:+EnableDynamicAgentLoading -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -DIKnowThereAreNoNMSBindingsForv1_21_8ButIWillProceedAnyway -Djava.security.manager=allow -Dtechnicjelle.updatechecker.disabled" # " -Dpaper.disableGameRuleLimits=true -Dpaper.preferSparkPlugin=true -Dcom.mojang.eula.agree=true"
	## 20250902 改进
		### Aikar's Flag 太旧了，部分参数不适合 [现代Minecraft版本] & [Java 21]，需要修改。
		### 参照: [【心得】Minecraft 伺服器優化反思：Aikar's Flags 是否已成過去式？ (by LogoCat)](https://forum.gamer.com.tw/Co.php?bsn=18673&sn=1099619)
		### "-XX:MaxMetaspaceSize=384m" 已移除，在插件很多的服务器上会导致大量插件崩溃
export jvm="-server -Xms${minmem}M -Xmx${maxmem}M -XX:+UseG1GC -Xss384k -XX:ReservedCodeCacheSize=256m -XX:MaxDirectMemorySize=128m -XX:+UseStringDeduplication -XX:+PerfDisableSharedMem -XX:+HeapDumpOnOutOfMemoryError -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1ReservePercent=10 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=85 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:MaxTenuringThreshold=1 -XX:+EnableDynamicAgentLoading -DIKnowThereAreNoNMSBindingsForv1_21_8ButIWillProceedAnyway -Djava.security.manager=allow -Dtechnicjelle.updatechecker.disabled" # " -XX:MaxMetaspaceSize=384m -Dpaper.disableGameRuleLimits=true -Dpaper.preferSparkPlugin=true -Dcom.mojang.eula.agree=true -Dpaper.disableChannelLimit"
	## 其他JVM参数说明:
		### + "-XX:+EnableDynamicAgentLoading" (Spark修复: Java21不显示错误信息，Java22继续使用高效方式获取性能数据。参见 https://spark.lucko.me/docs/misc/Java-agent-warning)
		### + "-DIKnowThereAreNoNMSBindingsForv1_21_8ButIWillProceedAnyway" (用于1.21.8强制加载Terra(地形生成器)插件)
		### + "-Djava.security.manager=allow" (允许使用Network Interceptor)
		### + "-Dtechnicjelle.updatechecker.disabled" (关闭BlueMapFloodgate的更新检查)
		### + "-Dpaper.disableGameRuleLimits=true" (关闭gamerule检查(比如矿车最大速度限制)，用于乐趣服务器。默认禁用)
		### + "-Dpaper.preferSparkPlugin=true" (使用外置 & 关闭内置Spark插件。默认禁用)
		### + "-Dcom.mojang.eula.agree=true" (同意EULA，忽略eula.txt。默认禁用)
		### + "-Dpaper.disableChannelLimit" (禁用插件通讯频道数量限制，玩家不会因为安装过多mod被踢出。在公共服务器上不建议启用。默认禁用)
	## 备用JVM参数，除了内存信息外什么都不添加，用于临时救急
# export jvm="-Xms${minmem}M -Xmx${maxmem}M"
# SSH设置
	## SSH(远程终端)模式
		### 设置为0使用Tmate, 在控制台输出访问ssh命令和web链接, 用于访问容器Shell和MC服务器控制台Shell
		### 设置为1使用Handy-sshd, 需要一个独立端口用于sshd, MC控制台在tmux中, 登录ssh后执行 "tmux attach" 进入控制台
export sshmode=0
	## SSH模式为1时，是否开启 用户名和密码登录
export ssh_use_user_password=1
	## SSH模式为1时，是否开启 密钥登录
export ssh_use_key=0
	## Tmate模式下创建Shell重试次数
export tmate_retry=5
	## sshd使用的端口
export sshd_port=22222
	## SSH认证信息。如果 {用户名和密码} 或 {密钥} 组成部分都为空白，则不使用对应认证方法
		### SSH用户名(尽量使用除了":"和"@"的ASCII可见字符)
export ssh_username=admin
		### SSH密码(尽量使用除了":"和"@"的ASCII可见字符) 留空则无需密码即可登录(非常不安全!)
export ssh_password=mypassword
		### SSH密钥(authorized_keys)路径
export ssh_key_path=./.ssh/authorized_keys
# 文件设置
	## 指定服务器核心文件路径
export server_jar="server.jar"
	## 指定tmate二进制文件的路径
export tmate=./bin/tmate
	## 指定tmux二进制文件的路径
export tmux=./bin/tmux
	## 指定关服标志文件, 用于判断是否停止服务器
export fileCheckIfShutdownFromConsole=./shutdown-mc-server
	## 指定"自动休眠"标志文件，判断是否为 自动任务-0点自动关服并等待
export fileCheckIfAutoTaskHour0AutoSleep=./hour0-auto-sleep
	## 添加本地bin目录到路径
export PATH=$PATH:$HOME/bin
	## 显示环境变量
		### env
	## 显示系统信息
		### uname -a
	## 关服时，是否清除垃圾，避免因超出磁盘空间而扣积分(默认关闭)
		### 清除BlueMap地图缓存
export cleanBlueMap=0
		### 清除DHSupport压缩区块缓存
export cleanDistantHorizonsSupport=0
		### 清除paper重映射插件缓存
export cleanPaperRemappedPlugins=0
# 自动任务
	## 是否启用 0点自动关服并等待 - 在0点时关闭服务器，等待一定时间(默认3600秒/60分钟)再开服，用于防止服务器损坏，因为如果积分不足，实例在此时会被强制停止。(暂时仅支持Handy-sshd模式)
export enable_autotask_hour0_auto_sleep=1
# 结束动作设置
	## 脚本结束动作，收到SIGINT结束时执行清理
exit_actions()
{
	echo
	echo "Minecraft server stopped, exiting..."
	## 清除BlueMap地图缓存
	if [ "$cleanBlueMap"x = "1"x ]
	then
		echo "正在清除BlueMap地图缓存"
		rm -rf ./bluemap/web/maps/*
	fi
	## 清除DHSupport压缩区块缓存
	if [ "$cleanDistantHorizonsSupport"x = "1"x ]
	then
		echo "正在清除DHSupport压缩区块缓存"
		rm -f ./plugins/DHSupport/data.sqlite
	fi
	## 清除paper重映射插件缓存
	if [ "$cleanPaperRemappedPlugins"x = "1"x ]
	then
		echo "正在清除paper重映射插件缓存"
		rm -rf ./plugins/.paper-remapped/*
	fi
	exit $1
}


#--------启动区--------
# 删除所有标志文件, 防止错误
rm -f "$fileCheckIfShutdownFromConsole"
rm -f "$fileCheckIfAutoTaskHour0AutoSleep"

if [ "$sshmode"x = "0"x ]
then
	echo "[Tmate]正在启动容器Shell"
	numTmateTrials=1 # 重试次数计数器
	fail1=0
	mkdir -p ./tmp/
	tmate_sock_system=./tmp/tmate-system_shell.sock
	tmate_sock_MCconsole=./tmp/tmate-minecraft_console.sock
	"$tmate" -S "$tmate_sock_system" new-session -P -d
	while ! "$tmate" -S "$tmate_sock_system" wait tmate-ready # 等待到Tmate连接建立。返回非0代表连接建立失败
	do
		if [ "$numTmateTrials" -ge "$tmate_retry" ]
		then
			echo "[Tmate]启动容器Shell失败, 已跳过"
			fail1=1
			break
		fi
		numTmateTrials=$(( numTmateTrials + 1 ))
		echo "[Tmate]启动容器Shell失败(可能是网络问题), 重试中..."
		sleep 1
		"$tmate" -S "$tmate_sock_system" new-session -P -d
	done
	if [ "$fail1"x = "0"x ]
	then
		echo "[Tmate]容器Shell启动成功"
		"$tmate" -S "$tmate_sock_system" send-key q 
		"$tmate" -S "$tmate_sock_system" display -p '#{tmate_ssh}' | tee tmate-sys_shell-ssh.txt # 显示SSH连接方式
		"$tmate" -S "$tmate_sock_system" display -p '#{tmate_web}' | tee tmate-sys_shell-web.txt # 显示Web连接方式
		echo
	fi

	echo "[Tmate]正在启动Minecraft服务器..." 
	# "$tmate" -S "$tmate_sock_system" attach-session
	# sleep 10000000
	numTmateTrials=1 # 重试次数计数器
	fail2=0
	"$tmate" -S "$tmate_sock_MCconsole" new-session -d bash start-part-mcserver.sh $$
	while ! "$tmate" -S "$tmate_sock_MCconsole" wait tmate-ready # 等待到Tmate连接建立。返回非0代表连接建立失败
	do
		if [ "$numTmateTrials" -ge "$tmate_retry" ]
		then
			echo "[Tmate]启动服务器Shell失败, 已跳过"
			fail2=1
			break
		fi
		echo "[Tmate]启动服务器Shell失败(可能是网络问题), 重试中..."
		numTmateTrials=$(( numTmateTrials + 1 ))
		sleep 1
		"$tmate" -S "$tmate_sock_MCconsole" new-session -d 'TERM=xterm-256color bash ./start-part-mcserver.sh'" $$"' ; bash -l'
	done
	if [ "$fail2"x = "0"x ]
	then
		echo "[Tmate]服务器Shell启动成功"
		"$tmate" -S "$tmate_sock_MCconsole" send-key q
		echo -n "SSH命令"
		"$tmate" -S "$tmate_sock_MCconsole" display -p '#{tmate_ssh}' | tee tmate-mc_console-ssh.txt # 显示SSH连接方式
		# "$tmate" -S "$tmate_sock_MCconsole" display -p '#{tmate_ssh_ro}' # 显示SSH连接方式(只读)
		echo -n "Web页面"
		"$tmate" -S "$tmate_sock_MCconsole" display -p '#{tmate_web}' | tee tmate-mc_console-web.txt # 显示Web连接方式
		# "$tmate" -S "$tmate_sock_MCconsole" display -p '#{tmate_web_ro}' # 显示Web连接方式(只读)
		echo
	fi

	echo "[Tmate]成功启动容器和服务器Shell, 可以使用控制台显示的信息连接到它们"
	echo
	trap exit_actions INT
	# echo "[$(date +%H:%M:%S)] [Server thread/INFO]: Done (${done_duration}.00s)! For help, type \"help\""
	echo "正在监听 latest.log 判断服务器何时启动成功"
	tail -F ./logs/latest.log | while IFS= read -r line
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
		# elif [ "$REPLY"x = "linuxcmd"x ]
		# then
		# 	read -e -p "请输入Linux控制台命令: " linuxcommand
		# 	eval $linuxcommand
		# 	break
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
elif [ "$sshmode"x = "1"x ]
then
    # 自动任务-0点自动关服并等待
    if [ "$enable_autotask_hour0_auto_sleep"x = "1"x ]
    then
        echo "✅ [定时任务] \"0点自动关服并等待\" 已启用。"
        (
            while true
            do
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
                sleep 60
            done
        ) &
    else
        echo "❌ [定时任务] \"0点自动关服并等待\" 已禁用。"
    fi
	echo "[Tmux] 正在启动Handy-sshd"
	# 构建handy-sshd命令行参数，自动检测是否需要添加参数
		# 1. 初始化一个参数数组
	export handy_sshd_command=./bin/handy-sshd
	sshd_args=("-p" "$sshd_port")
		# 2. 判断是否添加 --user 参数
	if [[ -n "$ssh_username" && -n "$ssh_password" ]]; then
		sshd_args+=("--user" "$ssh_username:$ssh_password")
	fi
		# 3. 判断是否添加 --keys 参数
	if [[ -n "$ssh_key_path" ]]; then
		sshd_args+=("--keys" "$ssh_key_path")
	fi
		# 4. 构建最终在 tmux 中执行的命令
		# 将参数数组中的元素拼接成一个字符串
	export handy_sshd_args="${sshd_args[@]}"
	# echo "[Tmux] 执行命令: $handy_sshd_command $handy_sshd_args" # 不安全
	"$tmux" new-session -ds handy-sshd "bash ./start-part-sshd.sh | tee sshd-log.txt"
	# "$tmux" new-session -ds handy-sshd "$handy_sshd_command $handy_sshd_args"
	ssh_command="ssh -p $sshd_port"
	if [[ -n "$ssh_username" ]]; then
		ssh_command2="$ssh_username@$(curl -s ifconfig.me)"
	else
		# 如果没有用户名，只显示主机地址
		ssh_command2="$(curl -s ifconfig.me)"
	fi
	echo "---"
	echo "✅ SSH服务器已启动，监听端口: $sshd_port"
	echo "➡️ 使用以下命令连接："
	echo "$ssh_command $ssh_command2"
	if [[ -n "$ssh_key_path" ]]; then
		echo "💡 你已设置密钥连接，使用对应的密钥对将无需输入用户名和密码(如果有)"
		echo "   命令示例: ssh -p $sshd_port -i /path/to/your/private_key ${ssh_username}@$(curl -s ifconfig.me)"
	fi
	echo "➡️ 连接后，使用以下命令进入控制台："
	echo "./bin/tmux attach -t mcserver_console"
	echo "---"

	# --- SSH端口转发提示 ---
	echo "---"
	echo "🌐 端口转发 (Port Forwarding)"
	echo "---"
	echo "如需从本地访问容器内部端口，请使用 SSH 端口转发功能。"
	echo "SSH 命令格式: \"$ssh_command -L <本地端口>:127.0.0.1:<远程端口> $ssh_command2\""
	echo "示例: \"$ssh_command -L 9999:127.0.0.1:9999 $ssh_command2\""
	echo "然后，您就可以通过访问 \"localhost:<本地端口>\" 来连接到容器内的服务。"
	echo ""

	# --- Tmux 会话启动提示 ---
	echo "---"
	echo "🚀 启动 Minecraft 服务器"
	echo "---"
	echo "▶️ [Tmux] 正在启动 Minecraft 服务器..."
	"$tmux" new-session -ds mcserver_console 'TERM=xterm-256color bash ./start-part-mcserver.sh $$ ; bash -l'
	echo "✅ [Tmux] Minecraft 服务器已开始启动，运行在端口 $SERVER_PORT。"
	echo "连接SSH后，可以使用命令 \"./bin/tmux attach -t mcserver_console\" 进入服务器控制台。"
	echo ""

	# --- 重要提示 ---
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
	tail -F ./logs/latest.log | while IFS= read -r line
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
			echo 正在停止服务器
			sleep 1
			"$tmux" send-keys -t mcserver_console "minecraft:stop"
			"$tmux" send-keys -t mcserver_console Enter
			touch "$fileCheckIfShutdownFromConsole"
			"$tmux" attach -t mcserver_console
			break
		elif [ "$REPLY"x = "attach"x ]
		then
			echo attach
			"$tmux" attach -t mcserver_console
			break
		# Linux控制台命令。其中使用的eval可能会导致危险行为，所以此功能默认禁用
		# elif [ "$REPLY"x = "linuxcmd"x ]
		# then
		# 	read -e -p "请输入Linux控制台命令: " linuxcommand
		# 	eval $linuxcommand
		# 	break
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


#--------后处理区--------
exit_actions
