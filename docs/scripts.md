"scripts" 文件夹提供了一些管理小工具

`diskusage.sh` 用于快速查看当前所有文件的磁盘占用 (需要在完整终端/ssh中执行)

`rclone-backup.txt` 提供 rclone 备份方法，命令内已经包含排除文件夹规则，过滤无需备份的垃圾，复制命令后更改目录等参数，执行即可备份到本地

`rclone-mount.txt` 提供 rclone 挂载教程，将sftp挂载为网络驱动器或unix/linux挂载点，方便使用VScode等编辑器快速编辑配置，无需反复复制粘贴