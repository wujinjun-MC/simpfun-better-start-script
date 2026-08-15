# 编译静态 pv

## Docker方式

- Dockerfile
    ```Dockerfile
    # 第一阶段：编译环境
    FROM alpine:3.19 AS builder

    # 安装必要的编译工具链（已加入 linux-headers）
    RUN apk add --no-cache \
        build-base \
        linux-headers \
        wget \
        tar \
        xz \
        bash \
        perl

    WORKDIR /build

    ENV PV_VERSION=1.11.0

    # 下载并解压源码
    RUN wget https://ivarch.com/s/pv-${PV_VERSION}.tar.gz && \
        tar -xf pv-${PV_VERSION}.tar.gz

    WORKDIR /build/pv-${PV_VERSION}

    # 配置并进行静态编译
    RUN export FORCE_UNSAFE_CONFIGURE=1 && \
        ./configure \
        CC="gcc" \
        CFLAGS="-Os -static" \
        LDFLAGS="-static" \
        --disable-shared \
        --enable-static \
        --disable-nls \
        --disable-acl \
        --disable-xattr \
        --disable-selinux \
        --without-gmp && \
        make -j$(nproc) && \
        make install-strip DESTDIR=/build/output

    # 第二阶段：导出产物
    FROM scratch
    COPY --from=builder /build/output/usr/local/bin/ /pv_bin/
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
        docker create --name pv_temp pv-static bash

        # 提取文件
        docker cp pv_temp:/pv_bin ./my_pv/

        # 删除临时容器
        docker rm pv_temp

        # 删除镜像
        docker image rm pv-static
        ```

## Debian/Ubuntu系列

```bash
apt install build-essential git markdown wget curl tar xz gzip perl
PV_VERSION=1.11.0
wget https://ivarch.com/s/pv-${PV_VERSION}.tar.gz
tar -xf pv-${PV_VERSION}.tar.gz
cd pv-${PV_VERSION}
export FORCE_UNSAFE_CONFIGURE=1
./configure CC="gcc" CFLAGS="-Os -static" LDFLAGS="-static" --disable-shared --enable-static --disable-nls --disable-acl --disable-xattr --disable-selinux --without-gmp &&
    make -j$(nproc) &&
    make install-strip DESTDIR=./output
```

一行命令:
```bash
apt install build-essential git markdown wget curl tar xz gzip perl && PV_VERSION=1.11.0 && wget https://ivarch.com/s/pv-${PV_VERSION}.tar.gz && tar -xf pv-${PV_VERSION}.tar.gz && cd pv-${PV_VERSION} && export FORCE_UNSAFE_CONFIGURE=1 && ./configure CC="gcc" CFLAGS="-Os -static" LDFLAGS="-static" --disable-shared --enable-static --disable-nls --disable-acl --disable-xattr --disable-selinux --without-gmp && make -j$(nproc) && make install-strip DESTDIR=./output
```
