# 更好的简幻欢启动脚本(Minecraft服务器)

魔改简幻欢的start.sh，添加SSH功能，直接连接到容器/服务器控制台

添加可以直接使用的应用程序:
1. btop和htop: 性能监视器
2. handy-sshd: SSH
<!-- 3. dropbear*, dbclient: SSH服务端(及工具)、SSH客户端 -- 无法解决容器只读带来的问题，所以无法添加-->
4. busybox: 基础功能
5. tmate和tmux: 终端工具
6. ncdu: 存储空间占用分析

拆分出start-part-mcserver.sh用于启动Minecraft服务器，加入优化JVM参数、自动重启、防止Ctrl-C停止

# 使用教程

1. git clone 或下载仓库(记得点点star)
2. 将文件通过SFTP放到根目录
3. 给予 /bin/* start.sh start-part-mcserver.sh 执行权限(chmod -R 755 文件名)
4. 在start.sh的配置区完成配置
<!-- 5. 如果使用Dropbear模式，需要配置密钥。
    1. 在自己的电脑上生成公私钥，然后创建/.ssh/文件夹，创建/.ssh/authorized_keys，将公钥添加到此文件
    2. 使用非Dropbear模式连接容器的SSH -->
6. 启动服务器
7. 运行成功后在Simpfun控制台输入help查看帮助

# `scripts`说明

1. `diskusage.sh`: 使用 `ncdu` 显示磁盘空间的占用情况。在SSH内执行 `bash ~/scripts/diskusage.sh` 即可进入，按下`?`查看软件帮助