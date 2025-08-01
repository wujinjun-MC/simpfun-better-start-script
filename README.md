# 更好的简幻欢启动脚本(Minecraft服务器)

魔改简幻欢的start.sh，添加SSH功能，直接连接到容器/服务器控制台

添加可以直接使用的应用程序:
1. btop和htop: 性能监视器
2. handy-sshd: SSH
3. busybox: 基础功能
4. tmate和tmux: 终端工具

拆分出start-part-mcserver.sh用于启动Minecraft服务器，加入优化JVM参数、自动重启、防止Ctrl-C停止
