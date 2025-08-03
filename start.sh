#!/bin/bash
# 检查当前 Shell 是否是 Bash
if [ "$BASH_VERSION"x = ""x ]; then
  echo "当前 Shell 不是 Bash。正在使用 Bash 重新运行脚本..."
  sleep 1
  exec bash "$0" "$@"
fi
exit_actions()
{
	echo
	echo "Minecraft server stopped, exiting..."
	exit $1
}
# 获取开始启动的时间戳
start_timestamp=$(date +%s)


#--------配置区--------
# 文件权限准备: 为二进制文件和脚本文件添加执行权限(+x)
chmod -R +x ~/bin/
chmod -R +x ~/start-part.mcserver.sh

# 服务器JVM的最大(-Xmx)和预占用(-Xms)内存, 建议最大设置为容器限制-1500, 预占用内存设置为最大的一半
export maxmem=$((${SERVER_MEMORY} - 1500))
export minmem=$((${maxmem} / 2))

# 是否使用Tmate
# 设置为1使用Tmate, 在控制台输出访问ssh命令和web链接, 用于访问容器Shell和MC服务器控制台Shell
# 设置为0使用Handy-sshd, 需要一个独立端口用于sshd, MC服务器在tmux中, 登录ssh后执行 "tmux attach" 进入控制台
useTmate=0

# Tmate模式: 创建Shell重试次数
retry=5

# Handy-sshd使用的端口
sshd_port=25495
# 用户名(不要带":"和"@", 或使用反斜杠转义)
ssh_username=wujinjun
# 密码(不要带":", 或使用反斜杠转义)
ssh_password=mypassword

# 指定tmate二进制文件的路径
tmate=~/bin/tmate
# 指定tmux二进制文件的路径
tmux=~/bin/tmux

# 指定关服标志文件, 用于判断是否停止服务器
export fileCheckIfShutdownFromConsole=~/shutdown-mc-server
# 添加本地bin目录到路径
export PATH=$PATH:$HOME/bin
# 显示环境变量
# env
# 显示系统信息
# uname -a

# 关服时，是否清除垃圾，避免因超出磁盘空间而扣积分(默认关闭)
	# 清除BlueMap地图缓存
cleanBlueMap=0
	# 清除DHSupport压缩区块缓存
cleanDistantHorizonsSupport=0
	# 清除paper重映射插件缓存
cleanPaperRemappedPlugins=0


#--------启动区--------
# 删除关服标志文件, 防止错误
rm -f "$fileCheckIfShutdownFromConsole"

if [ "$useTmate"x = "1"x ]
then
	echo "[Tmate]正在启动容器Shell"
	numTmateTrials=1 # 重试次数计数器
	fail1=0
	mkdir -p ~/tmp/
	tmate_sock_system=~/tmp/tmate-system_shell.sock
	tmate_sock_MCconsole=~/tmp/tmate-minecraft_console.sock
	"$tmate" -S "$tmate_sock_system" new-session -P -d
	while ! "$tmate" -S "$tmate_sock_system" wait tmate-ready # 等待到Tmate连接建立。返回非0代表连接建立失败
	do
		if [ "$numTmateTrials" -ge "$retry" ]
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
		if [ "$numTmateTrials" -ge "$retry" ]
		then
			echo "[Tmate]启动服务器Shell失败, 已跳过"
			fail2=1
			break
		fi
		echo "[Tmate]启动服务器Shell失败(可能是网络问题), 重试中..."
		numTmateTrials=$(( numTmateTrials + 1 ))
		sleep 1
		"$tmate" -S "$tmate_sock_MCconsole" new-session -d bash start-part-mcserver.sh $$
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
			"$tmate" -S "$tmate_sock_MCconsole" send-keys "stop"
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
		elif [ "$REPLY"x = "help"x ]
		then
			echo "stop: 停止MC服务器"
			echo "attach: 进入MC控制台(此操作无法撤销)"
			echo "help: 显示此帮助"
		else
			echo "未知命令: ${REPLY} 。输入 \"help\" 查看帮助"
		fi
	done
else
	echo "[Tmux]正在启动Handy-sshd"
	"$tmux" new-session -ds sshd ~/bin/handy-sshd -p "$sshd_port" -u "$ssh_username":"$ssh_password"
	echo -e "SSH端口为 $sshd_port 。使用以下ssh命令连接:\nssh -p $sshd_port $ssh_username@play.simpfun.cn\n连接后，使用以下命令进入MC服务器控制台:\ntmux attach -t mcserver_console"
	echo -e "如需访问容器内部端口，使用以下格式的ssh命令:\nssh -L <本地端口>:127.0.0.1:<远程端口> -p $sshd_port $ssh_username@play.simpfun.cn\nssh -L 9999:127.0.0.1:9999 -p $sshd_port $ssh_username@play.simpfun.cn\n然后访问 localhost:<本地端口>"
	echo "[Tmux]正在启动MC服务器..." 
	"$tmux" new-session -ds mcserver_console 'TERM=xterm-256color bash ~/start-part-mcserver.sh'" $$"
	echo "[Tmux]MC服务器状态: 正在启动, 端口为 $SERVER_PORT"
	echo "正在监听 latest.log 判断服务器何时启动成功"
	trap exit_actions INT
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
			"$tmux" send-keys -t mcserver_console "stop"
			"$tmux" send-keys -t mcserver_console Enter
			touch "$fileCheckIfShutdownFromConsole"
			echo 正在停止服务器
			"$tmux" attach -t mcserver_console
			break
		elif [ "$REPLY"x = "attach"x ]
		then
			echo attach
			"$tmux" attach -t mcserver_console
			break
		elif [ "$REPLY"x = "help"x ]
		then
			echo "stop: 停止MC服务器"
			echo "attach: 进入MC控制台(此操作无法撤销)"
			echo "help: 显示此帮助"
		else
			echo "未知命令: ${REPLY} 。输入 \"help\" 查看帮助"
		fi
	done
fi


#--------后处理区--------
# 清除BlueMap地图缓存
if [ "$cleanBlueMap"x = "1"x ]
then
	echo "正在清除BlueMap地图缓存"
	rm -rf ~/bluemap/web/maps
fi
# 清除DHSupport压缩区块缓存
if [ "$cleanDistantHorizonsSupport"x = "1"x ]
then
	echo "正在清除DHSupport压缩区块缓存"
	rm -f ~/plugins/DHSupport/data.sqlite
fi
# 清除paper重映射插件缓存
if [ "$cleanPaperRemappedPlugins"x = "1"x ]
then
	echo "正在清除paper重映射插件缓存"
	rm -rf ~/plugins/.paper-remapped
fi
