# 更好的简幻欢启动脚本(Minecraft服务器)

魔改简幻欢的start.sh，支持自动重启、终端管理、性能优化、存档保护等功能，方便服主高效管理服务器。

ACTIVE NOW!!! STAR!!! FORK!!!

## 为什么选择此项目

1. 可以直接连接服务器控制台，获得和本地电脑启动Minecraft服务器一样的操作体验，可以使用↑↓调取命令历史记录，用TAB自动补全
2. 网页端需要加载大量前端资源，占用CPU、GPU和内存，降低游戏帧率。此项目的远程控制方法流量消耗更少，方便在低带宽状态下更好管理服务器
3. 快速配置JVM参数，优化服务器性能
4. 自动重启服务器，防止服务器因异常停止导致存档丢失
5. 自动清理垃圾，防止过度消耗积分和占用宝贵的免费资源
6. 可通过Tailscale (即将到来) 远程调试，避免直接暴露端口，减小攻击面
7. **(NOT VIOLATING TOS)** 方便多管理员情况下的团队协作，例如排除故障、动态测试JVM参数性能
	- 必须使用...方法获得IP白名单后才能登录到网页控制台，但""启动速度慢，包含开屏广告(跳过按钮屏占比仅<2%)，严重影响用户体验; 多管理员环境下，效率更低，需要使用屏幕共享等方式控制，产生严重安全漏洞 (获得完整手机/电脑操控权限，服主面临财产、隐私安全威胁)

更多功能查看 [Features](#features)

## ~~为什么要归档~~

~~1.19 官方公告显示部分用户利用SSH功能违规商业活动、挤占服务器资源，影响了正常用户的体验。~~

~~为避免您的账号封禁，请立即删除SSH相关代码和滥用功能~~

目前仍然未知此类用户是否使用了本项目，但是在 start.sh 的 "用户须知" 内已经提醒用户不得用于违规用途，并且用户必须关闭提示信息才能使用 (视为同意相关声明)，用户行为与本项目无关。

对于正常用户: SSH直接使用确实有风险 (暴露了"危险"服务到公网，黑客可能破解并控制实例; 被""扫描到然后自动扣帽子，一刀切立即封禁)。如果确实担心风险，或者正在用于重要项目 (例如~~保证商业服稳定盈利?~~ (Warning: At your own risk. You are breaking Simpfun's ToS and/or Mojang's EULA!) 或 持续建设高难度的生电工程) ，用 `Tmate` 、 `Cpolar+ssld` 和 `Telnet` (TODO) 就好了

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

1. git clone 或 从[Releases](https://github.com/wujinjun-MC/simpfun-better-start-script/releases) 下载 (记得点点star)
2. 将文件通过SFTP放到根目录
3. 给予 /bin/* start.sh start-part-mcserver.sh 执行权限(`chmod -R 755 <文件名>` 或 通过SFTP给文件添加 "x" 权限)
4. 在start.sh的配置区完成配置
<!-- 5. 如果使用Dropbear模式，需要配置密钥。
	1. 在自己的电脑上生成公私钥，然后创建/.ssh/文件夹，创建/.ssh/authorized_keys，将公钥添加到此文件
	2. 使用非Dropbear模式连接容器的SSH -->
6. 启动服务器
7. 运行成功后在Simpfun控制台输入help查看帮助

## 远程控制

- remotemode=0: tmate
- remotemode=1: handy-sshd (SSH) (not recommended)
- remotemode=2: handy-sshd ("ssh"->"ssl" in this mode) + Cpolar
	- 使用SSL/SSH协议，但是不直接暴露端口到公网，而是通过Cpolar连接，确保服务器安全
- remotemode=3: Telnet

## 重载启动脚本

- 创建文件 `restart-<脚本名称>`
	- start.sh: 脚本将重新执行。重新执行前，所有子进程将被清除 (例如Minecraft服务器、Cpolar) [!TODO]
	- start-part-*.sh: 脚本将重新执行

## Other Docs

见 [docs](./docs)

### 与其他项目/工具对比

- [OPanel](docs/compare-with-opanel.md)

## `scripts`说明

1. `diskusage.sh`: 使用 `ncdu` 显示磁盘空间的占用情况。在SSH内执行 `bash ~/scripts/diskusage.sh` 即可进入，按下`?`查看软件帮助

## Goals

- [ ] [Bypas*]添加 Telnet 支持，专治SSH ban
- [ ] [Security]添加 Tailscale 支持，避免直接暴露端口，减小攻击面
- [ ] [Feature]添加远程控制开关，在运行过程中按需启用远程终端，减小攻击面
- [x] [Docs]完善 `scripts` 说明
- [ ] [Security](Github actions)一键"obfuscator" (可使用[Bashfuscator](https://github.com/bashfuscator/bashfuscator)等工具暂时代替)
- [x] [Security]添加 [Cpolar](https://www.cpolar.com/) (非frp) 支持，使用tunnel避免直接暴露端口，减小攻击面

## Copyright & License

Copyright © 2026 wujinjun-MC, released under GPL 3.0. (See [License](./LICENSE))
