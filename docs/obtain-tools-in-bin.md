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

Download source code in [release](https://github.com/aristocratos/btop/releases) or with git clone

git clone 或 [release](https://github.com/aristocratos/btop/releases) 下载源码

`cd` to source directory, `make STATIC=true -j$(nproc)` and copy `btop` binary.

`cd`到源码目录，`make STATIC=true -j$(nproc)`，复制 `btop` 二进制即可