# 编译静态 coreutils (gnu)

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

    ENV COREUTILS_VERSION=9.11

    # 下载并解压源码
    RUN wget https://ftp.gnu.org/gnu/coreutils/coreutils-${COREUTILS_VERSION}.tar.xz && \
        tar -xf coreutils-${COREUTILS_VERSION}.tar.xz

    WORKDIR /build/coreutils-${COREUTILS_VERSION}

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
    FROM scratch AS export
    COPY --from=builder /build/output/usr/local/bin/ /coreutils_bin/
    ```
- 如果支持Buildkit:
    - `DOCKER_BUILDKIT=1 docker build --output . .` ，直接输出到此文件夹
- 没有BUILDKIT:
    - 执行: `docker build -t coreutils-static .`
    - 输出产物
        ```bash
        # 创建用于导出的目录
        mkdir -p ./my_coreutils

        # 创建临时容器
        docker create --name coreutils_temp coreutils-static bash

        # 提取文件
        docker cp coreutils_temp:/coreutils_bin ./my_coreutils/

        # 删除临时容器
        docker rm coreutils_temp

        # 删除镜像
        docker image rm coreutils-static
        ```

## Debian/Ubuntu系列

(Failed: link error)

```bash
apt install build-essential git markdown wget curl tar xz gzip perl
COREUTILS_VERSION=9.11
wget https://ftp.gnu.org/gnu/coreutils/coreutils-${COREUTILS_VERSION}.tar.xz
tar -xf coreutils-${COREUTILS_VERSION}.tar.xz
cd coreutils-${COREUTILS_VERSION}
export FORCE_UNSAFE_CONFIGURE=1
./configure CC="gcc" CFLAGS="-Os -static" LDFLAGS="-static" --disable-shared --enable-static --disable-nls --disable-acl --disable-xattr --disable-selinux --without-gmp &&
    make -j$(nproc) &&
    make install-strip DESTDIR=./output
```

一行命令:
```bash
apt install build-essential git markdown wget curl tar xz gzip perl && COREUTILS_VERSION=9.11 && wget https://ftp.gnu.org/gnu/coreutils/coreutils-${COREUTILS_VERSION}.tar.xz && tar -xf coreutils-${COREUTILS_VERSION}.tar.xz && cd coreutils-${COREUTILS_VERSION} && export FORCE_UNSAFE_CONFIGURE=1 && ./configure CC="gcc" CFLAGS="-Os -static" LDFLAGS="-static" --disable-shared --enable-static --disable-nls --disable-acl --disable-xattr --disable-selinux --without-gmp && make -j$(nproc) && make install-strip DESTDIR=./output
```
