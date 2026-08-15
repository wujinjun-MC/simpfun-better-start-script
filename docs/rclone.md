使用 rclone 高效同步文件

你可以直接用rclone命令行参数连接SSH/SSL/SFTP进行文件操作，但是不方便 (每次输入密码/明文密码在命令行参数，不安全)，推荐使用 `rclone config` 配置连接信息，每次只需使用remote名称指定连接。

- 可用的连接方式:
    - simpfun默认提供的sftp (纯SFTP服务)
        - **不消耗每日上行流量限制**
        - 实例关闭时也可用
        - 无法更改文件的修改时间 (对文件进行更改时，服务端会强制设置更改时间) & 无法使用校验和 (例如 sha256sum / md5sum) 比较文件。从本地同步文件到SFTP后，下一次同步文件时，未更改的文件仍然可能重复上传 (**小心: 现在的运营商非常重视家宽上传流量，过多上传会强制限速 (5兆 或更低)，必须签保证书才能解封，更严重情况下会强制拆机、将身份证加入黑名单等**)
        - 有 Keepalive 心跳包问题，如果SFTP客户端没有发送心跳包，连接实际上已经关闭，但是没有通知客户端，客户端会显示错误，重新连接才能继续使用
    - remotemode=1,2 创建的 sshd / ssld (带shell的SFTP)
        - **消耗每日上行流量限制**
        - 实例必须保持运行
        - 支持必须使用shell的功能，包括修改时间同步、校验和，节省上传流量
        - 正常的 Keepalive ，和大部分sshd的行为一致

- 创建配置文件
    - `rclone config` 进入交互式创建向导
    - 也可使用配置文件模板，放入 `C:\Users\<user>\AppData\Roaming\rclone\rclone.conf` 或 `~/.config/rclone/rclone.conf`。查看 [rclone/config-template](./rclone/config-template/)

- 使用配置文件
    - 直接在命令行内引用配置
        - Example: `rclone sync 1a1s-sftp: /path/to/1a1s-backup`

- 备份/同步: (old tutorial) [rclone/rclone-backup.txt](./rclone/rclone-backup.txt)
- 挂载: (old tutorial) [rclone/rclone-mount.txt](./rclone/rclone-mount.txt)
