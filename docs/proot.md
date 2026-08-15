使用 proot ，运行更完整的Linux环境

为什么不用 chroot (效率更高): Docker 环境且没有开启 `--cap-add SYS_CHROOT` 或 `--privileged` ，提示 "不允许的操作" (Operation not permitted)

命令帮助: `proot --help`

选择镜像:
- ubuntu minimal (rootfs)
- ...

