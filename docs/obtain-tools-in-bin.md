# Obtain Tools in `/bin` (获取 `/bin` 使用的工具)

Howto: obtain (binary) tools without dependency or only require a few dependencies for efficient use (since all paths outside `/home/container` are read-only)

教你获取无需依赖或仅需少量依赖的(二进制)工具，方便快速使用 (毕竟 `/home/container` 之外都是只读)

## btop

### Download binary from actions (从actions下载二进制)

Choose the first workflow run results [here (Continuous Build Linux, filtered Event=Push)](https://github.com/aristocratos/btop/actions/workflows/continuous-build-linux.yml?query=event%3Apush)

从[这个 (Continuous Build Linux，筛选"Push"事件)](https://github.com/aristocratos/btop/actions/workflows/continuous-build-linux.yml?query=event%3Apush)工作流运行结果列表中选择第一项

Download `btop-x86_64-*` from `Artifacts`, unzip and rename to `btop`

从`Artifacts`下载`btop-x86_64-*`，解压并重命名为`btop`

### Build from source (从源码构建)

Download source code in [releases](https://github.com/aristocratos/btop/releases) or with git clone

git clone 或 [releases](https://github.com/aristocratos/btop/releases) 下载源码

`cd` to source directory, `make STATIC=true -j$(nproc)` and copy `btop` binary.

`cd`到源码目录，`make STATIC=true -j$(nproc)`，复制 `btop` 二进制即可

## Busybox

## handy-sshd

Already a portable sshd. Download from [releases](https://github.com/nwtgck/handy-sshd/releases)

已经是便携sshd。从[releases](https://github.com/nwtgck/handy-sshd/releases)下载

## htop

## NCurses Disk Usage (ncdu)

Use static binary from [official site](https://dev.yorhel.nl/ncdu)

使用[官网](https://dev.yorhel.nl/ncdu)的静态二进制文件

## pv

## Tmate

Use static binary from [releases](https://github.com/tmate-io/tmate/releases)

使用[releases](https://github.com/tmate-io/tmate/releases)的静态二进制文件

## Tmux

Use static binary from [releases](https://github.com/pythops/tmux-linux-binary/releases) build by [pythops/tmux-linux-binary](https://github.com/pythops/tmux-linux-binary)

使用[releases](https://github.com/pythops/tmux-linux-binary/releases)的静态二进制文件 (由[pythops/tmux-linux-binary](https://github.com/pythops/tmux-linux-binary)构建)

## Other sources

You can find some "portable" (statically linked) binary files, including those not included in this project:

在以下列表中可以找到一些"便携的"(静态编译的)二进制文件，包括本项目没有的:

- [perryflynn/static-binaries](https://github.com/perryflynn/static-binaries) ([Download](https://files.serverless.industries/bin/)): busybox, curl, dig+nsupdate, htop, iperf2, iperf3, jq, rsync/xxHash, smartctl, OpenSSH, tcpdump/libpcap
