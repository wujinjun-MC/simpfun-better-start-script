# 编译静态 procps-ng

(All failed: `ldd output/usr/local/bin/*` not passing)

## Docker方式

- Dockerfile
    ```Dockerfile
    # 第一阶段：编译环境
    FROM alpine:3.19 AS builder

    # 安装必要的编译工具链（已加入 linux-headers）
    RUN apk add --no-cache \
        build-base \
        autoconf \
        automake \
        libtool \
        gettext-dev \
        gettext-static \
        ncurses-dev \
        ncurses-static \
        git \
        pkgconfig \
        linux-headers \
        wget \
        tar \
        xz \
        bash \
        perl

    WORKDIR /build

    ENV PROCPS_VERSION=4.0.7

    # 下载并解压源码
    RUN wget https://gitlab.com/procps-ng/procps/-/archive/v${PROCPS_VERSION}/procps-v${PROCPS_VERSION}.tar.gz && \
        tar -xf procps-v${PROCPS_VERSION}.tar.gz

    WORKDIR /build/procps-v${PROCPS_VERSION}

    # 配置并进行静态编译
    RUN export FORCE_UNSAFE_CONFIGURE=1 && \
        ./autogen.sh && \
        ./configure \
        CFLAGS="-O2 -static" \
        LDFLAGS="-static" \
        PKG_CONFIG="pkg-config --static" \
        --disable-shared \
        --enable-static \
        --disable-nls \
        --disable-rpath
        --without-systemd \
        --without-elogind && \
        make -j$(nproc) && \
        make install-strip DESTDIR=/build/output

    # 第二阶段：导出产物
    FROM scratch
    COPY --from=builder /build/output/usr/local/bin/ /procps-ng_bin/
    ```
- 如果支持Buildkit:
    - `DOCKER_BUILDKIT=1 docker build --output . .` ，直接输出到此文件夹
- 没有BUILDKIT:
    - 执行: `docker build -t pv-static .`
    - 输出产物
        ```bash
        # 创建用于导出的目录
        mkdir -p ./my_pv

        # 创建临时容器
        docker create --name procps-ng_temp procps-ng-static bash

        # 提取文件
        docker cp procps-ng_temp:/procps-ng_bin ./my_procps-ng/

        # 删除临时容器
        docker rm procps-ng_temp

        # 删除镜像
        docker image rm procps-ng-static
        ```

## Debian/Ubuntu系列

```bash
apt install build-essential git markdown wget curl tar xz gzip perl
PROCPS_VERSION=4.0.7
wget https://gitlab.com/procps-ng/procps/-/archive/v${PROCPS_VERSION}/procps-v${PROCPS_VERSION}.tar.gz
tar -xf procps-v${PROCPS_VERSION}.tar.gz
cd procps-v${PROCPS_VERSION}
export FORCE_UNSAFE_CONFIGURE=1
./autogen.sh
./configure CFLAGS="-O2 -static" LDFLAGS="-static" PKG_CONFIG="pkg-config --static" --disable-shared --enable-static --disable-nls --disable-rpath --without-systemd --without-elogind &&
    make -j$(nproc) &&
    make install-strip DESTDIR=$(realpath ./output)
```

一行命令:
```bash
apt install build-essential git markdown wget curl tar xz gzip perl && PROCPS_VERSION=4.0.7 && wget https://gitlab.com/procps-ng/procps/-/archive/v${PROCPS_VERSION}/procps-v${PROCPS_VERSION}.tar.gz && tar -xf procps-v${PROCPS_VERSION}.tar.gz && cd procps-v${PROCPS_VERSION} && export FORCE_UNSAFE_CONFIGURE=1 && ./autogen.sh && ./configure CFLAGS="-O2 -static" LDFLAGS="-static" PKG_CONFIG="pkg-config --static" --disable-shared --enable-static --disable-nls --disable-rpath --without-systemd --without-elogind && make -j$(nproc) && make install-strip DESTDIR=$(realpath ./output)
```
