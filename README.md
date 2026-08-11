# 更好的简幻欢启动脚本(Minecraft服务器)

魔改简幻欢的start.sh，支持自动重启、终端管理、性能优化、存档保护等功能，方便服主高效管理服务器。

ACTIVE NOW!!! STAR!!! FORK!!!

## 为什么选择此项目

1. 可以直接连接服务器控制台，获得和本地电脑启动Minecraft服务器一样的操作体验，包括命令历史记录、快捷键
2. 流量消耗更少，方便在低带宽状态下更好管理服务器
3. 快速配置JVM参数，优化服务器性能
4. 自动重启服务器，防止服务器因异常停止导致存档丢失
5. 自动清理垃圾，防止过度消耗积分和占用宝贵的免费资源
6. 可通过Tailscale (即将到来) 远程调试，避免直接暴露端口，减小攻击面

更多功能查看 [Features](#features)

## ~~为什么要归档~~

~~1.19 官方公告显示部分用户利用SSH功能违规商业活动、挤占服务器资源，影响了正常用户的体验。~~

~~为避免您的账号封禁，请立即删除SSH相关代码和滥用功能~~

既然不能用SSH，用 `Tmate` 和 `Telnet` (TODO) 就好了

## Features

- 远程控制: 支持SSH、Tmate、Telnet (TODO) 远程连接服务器，方便管理Minecraft服务器
- 终端管理: 支持tmux，远程调试过程中可以随时断开连接，服务器仍然运行
- 性能监控: 支持htop和btop等性能监控工具，方便查看服务器的CPU、内存、网络等性能指标
- 存档保护: 每天0:00~1:00如果积分不足，服务器会被强制关闭，不保存存档，开启保护功能后，会自动"休息"1小时，同时保存存档，防止存档丢失
- 预置二进制文件，无需手动编译和寻找依赖:
	1. btop和htop: 性能监视器
	2. handy-sshd: SSH
	<!-- 3. dropbear*, dbclient: SSH服务端(及工具)、SSH客户端 -- 无法解决容器只读带来的问题，所以无法添加-->
	4. busybox: 基础功能
	5. tmate和tmux: 终端工具
	6. ncdu: 存储空间占用分析
- 支持 Java Agent mod，实现Bukkit/Spigot/Paper插件无法实现的修改
	- Example:
		- [ChunkGuardAgent](https://github.com/kuohsuanlo/ChunkGuardAgent)

拆分出start-part-mcserver.sh用于启动Minecraft服务器，加入优化JVM参数、自动重启、防止Ctrl-C停止

## 使用教程

1. git clone 或下载仓库(记得点点star)
2. 将文件通过SFTP放到根目录
3. 给予 /bin/* start.sh start-part-mcserver.sh 执行权限(chmod -R 755 文件名)
4. 在start.sh的配置区完成配置
<!-- 5. 如果使用Dropbear模式，需要配置密钥。
	1. 在自己的电脑上生成公私钥，然后创建/.ssh/文件夹，创建/.ssh/authorized_keys，将公钥添加到此文件
	2. 使用非Dropbear模式连接容器的SSH -->
6. 启动服务器
7. 运行成功后在Simpfun控制台输入help查看帮助

## Other Docs

见 [docs](./docs)

## `scripts`说明

1. `diskusage.sh`: 使用 `ncdu` 显示磁盘空间的占用情况。在SSH内执行 `bash ~/scripts/diskusage.sh` 即可进入，按下`?`查看软件帮助

## Goals

- [ ] 添加 Telnet 支持，专治SSH ban
- [ ] 添加 Tailscale 支持，避免直接暴露端口，减小攻击面
- [ ] 添加 SSH/Tmate/Telnet 开关，按需启用远程终端，减小攻击面 (避免扫端口等安全风险)
- [ ] 完善 `scripts`说明
