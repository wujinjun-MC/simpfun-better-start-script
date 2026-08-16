# PRoot 教程

使用 proot ，运行更完整的Linux环境

为什么不用 chroot (效率更高): Docker 环境且没有开启 `--cap-add SYS_CHROOT` 或 `--privileged` ，提示 "不允许的操作" (Operation not permitted)

命令帮助: `proot --help`

## 选择镜像
### Ubuntu minimal (rootfs)

- 完整，自动更新: https://cloud-images.ubuntu.com/releases/
    - https://cloud-images.ubuntu.com/releases/resolute/release/ubuntu-26.04-server-cloudimg-amd64v3-root.tar.xz
- 稳定，小体积，LTS: https://cdimage.ubuntu.com/ubuntu-base/releases/
    - https://cdimage.ubuntu.com/ubuntu-base/releases/26.04/release/ubuntu-base-26.04-base-amd64.tar.gz

## 解包

```bash
tar -xf *.tar.gz --exclude='dev'
```

## 启动

```bash
#!/bin/bash
ROOTFS_DIR="$HOME/myroot"
# 写入 DNS 防止容器内无法联网
echo "nameserver 8.8.8.8" > "$ROOTFS_DIR/etc/resolv.conf"
echo "nameserver 1.1.1.1" >> "$ROOTFS_DIR/etc/resolv.conf"
# 启动 proot 容器
proot \
  --rootfs="$ROOTFS_DIR" \
  -0 \
  -w /root \
  -b /dev \
  -b /proc \
  -b /sys \
  -b /dev/urandom:/dev/random \
  /usr/bin/env -i \
  HOME=/root \
  TERM="$TERM" \
  LANG=C.UTF-8 \
  PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
  /bin/bash --login
```