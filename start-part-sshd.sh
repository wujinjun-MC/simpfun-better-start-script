#!/bin/bash

# ==========================================================
# 脚本配置
# ==========================================================
# 进程异常退出后，等待多久再重启（单位：秒）
RESTART_DELAY=5
# handy-sshd 的超时时间（单位：秒），如果未提供第二个参数，则使用默认值 3600
HANDY_SSHD_TIMEOUT=${2:-86400}
# 要监控并重启的进程命令，如果环境变量 handy_sshd_command 已设置，则使用该值，否则使用第一个参数
HANDY_SSHD_COMMAND=${handy_sshd_command:-$1}
# 进程参数，如果环境变量 handy_sshd_args 已设置，则使用该值，否则使用从第三个参数开始的所有参数
HANDY_SSHD_ARGS=${handy_sshd_args:-"${@:3}"}


# ==========================================================
# 函数：主重启循环
# ==========================================================
function main_loop() {
	# 创建一个无限循环，确保进程总会被重启
	while true; do
		# 获取当前时间，格式化为 "YYYY-MM-DD HH:MM:SS"
		TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
		echo "[$TIMESTAMP] 🚀 正在启动 $HANDY_SSHD_COMMAND，超时时间为 $HANDY_SSHD_TIMEOUT 秒..."

		# 使用 timeout 命令启动进程，并将其放入后台，这样我们就可以获取其 PID
		timeout -s SIGINT $HANDY_SSHD_TIMEOUT $HANDY_SSHD_COMMAND $HANDY_SSHD_ARGS &

		# 获取由 timeout 启动的进程的 PID，这个 PID 是唯一的，不会被其他同名进程混淆
		PID_TO_KILL=$!

		# 进入一个内部循环，每1秒检查一次文件和进程状态
		while kill -0 $PID_TO_KILL 2>/dev/null; do
			# 检查 "stop-sshd" 文件是否存在
			if [[ -f "stop-sshd" ]]; then
				TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
				echo "[$TIMESTAMP] 🚨 检测到 'stop-sshd' 文件。正在立即终止进程 $PID_TO_KILL..."
				# 移除文件，防止下次循环再次触发
				rm "stop-sshd"
				# 直接杀死我们已知的进程 ID，而不是通过 pgrep
				kill $PID_TO_KILL
				# 退出内部循环，进入重启逻辑
				break
			fi

			# 检查 "restart-<脚本名称>.sh" 文件是否存在，若存在则删除并重载本脚本
			if [[ -f "restart-start-part-sshd" ]]; then
				TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
				echo "[$TIMESTAMP] 🔁 检测到重启标志文件。正在重载此脚本..."
				# 移除文件，防止下次循环再次触发
				rm "restart-start-part-sshd"
				# 杀死当前监控的进程
				kill $PID_TO_KILL
				# 使用 exec 重新执行当前脚本以实现重载（保留参数）
				exec "$0" "$@"
			fi
			# 短暂休眠以避免 CPU 过高
			sleep 1
		done

		# 等待进程退出，并获取其退出代码
		wait $PID_TO_KILL
		EXIT_CODE=$?
		
		# 根据进程的退出代码判断重启原因
		TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
		if [[ $EXIT_CODE -eq 124 ]]; then
			# 退出码 124 是 timeout 命令专用的，表示超时
			echo "[$TIMESTAMP] ⏰ $HANDY_SSHD_COMMAND 运行超过 $HANDY_SSHD_TIMEOUT 秒后超时。正在重启..."
		elif [[ $EXIT_CODE -eq 0 ]]; then
			# 退出码 0 表示进程正常退出
			echo "[$TIMESTAMP] ✅ $HANDY_SSHD_COMMAND 正常退出。正在重启..."
		else
			# 其他非零退出码表示异常退出
			echo "[$TIMESTAMP] ⚠️ $HANDY_SSHD_COMMAND 异常退出，退出代码为 $EXIT_CODE。等待 $RESTART_DELAY 秒后重启..."
			sleep $RESTART_DELAY
		fi
	done
}

# ==========================================================
# 主程序入口
# ==========================================================
# 启动主循环，所有监控和重启逻辑都在该循环内处理
main_loop
