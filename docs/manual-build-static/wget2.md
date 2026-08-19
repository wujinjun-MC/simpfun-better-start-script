# 编译静态 wget2 (gnu)

(All failed: `ldd output/usr/local/bin/*` not passing)

## Docker方式

- Dockerfile
    ```Dockerfile
    # 第一阶段：编译环境
    FROM alpine:3.19 AS builder

    # 安装必要的编译工具链（已加入 linux-headers）
    RUN apk add --no-cache \
        git \
        build-base \
        autoconf \
        automake \
        libtool \
        gettext-dev \
        pkgconf \
        texinfo \
        flex \
        bison \
        ca-certificates \
        # Compression libraries (static)
        zlib-dev \
        zlib-static \
        bzip2-dev \
        bzip2-static \
        xz-dev \
        zstd-dev \
        zstd-static \
        brotli-dev \
        brotli-static \
        # Networking & Crypto libraries (static)
        gnutls-dev \
        libpsl-dev \
        libpsl-static \
        libidn2-dev \
        libidn2-static \
        libunistring-dev \
        libunistring-static \
        nghttp2-dev \
        nghttp2-static \
        pcre2-dev \
        wget \
        tar \
        xz \
        bash \
        perl

    WORKDIR /build

    ENV WGET2_VERSION=2.2.1

    # 下载并解压源码
    RUN wget https://ftp.gnu.org/gnu/wget/wget2-${WGET2_VERSION}.tar.gz && \
        tar -xf wget2-${WGET2_VERSION}.tar.xz

    WORKDIR /build/wget2-${WGET2_VERSION}

    # 配置并进行静态编译
    RUN export FORCE_UNSAFE_CONFIGURE=1 && \
        ./configure \
        CFLAGS="-O2 -static" \
        LDFLAGS="-static -all-static" \
        --disable-shared \
        --enable-static \
        --disable-nls \
        --disable-rpath \
        --disable-doc && \
        make -j$(nproc) && \
        make install-strip DESTDIR=/build/output

    # 第二阶段：导出产物
    FROM scratch AS export
    COPY --from=builder /build/output/usr/local/bin/ /wget2_bin/
    ```
- 如果支持Buildkit:
    - `DOCKER_BUILDKIT=1 docker build --output . .` ，直接输出到此文件夹
- 没有BUILDKIT:
    - 执行: `docker build -t wget2-static .`
    - 输出产物
        ```bash
        # 创建用于导出的目录
        mkdir -p ./my_wget2

        # 创建临时容器
        docker create --name wget2_temp wget2-static bash

        # 提取文件
        docker cp wget2_temp:/wget2_bin ./my_wget2/

        # 删除临时容器
        docker rm wget2_temp

        # 删除镜像
        docker image rm wget2-static
        ```

## Debian/Ubuntu系列

```bash
apt install build-essential git markdown wget curl tar xz gzip perl
WGET2_VERSION=2.2.1
wget https://ftp.gnu.org/gnu/wget/wget2-${WGET2_VERSION}.tar.gz
tar -xf wget2-${WGET2_VERSION}.tar.xz
cd wget2-${WGET2_VERSION}
export FORCE_UNSAFE_CONFIGURE=1
./configure CFLAGS="-O2 -static" LDFLAGS="-static" --disable-shared --enable-static --disable-nls --disable-rpath &&
    make -j$(nproc) &&
    make install-strip DESTDIR=./output
```

一行命令:
```bash
apt install build-essential git markdown wget curl tar xz gzip perl && WGET2_VERSION=9.2 && wget https://ftp.gnu.org/gnu/wget2/wget2-${WGET2_VERSION}.tar.xz && tar -xf wget2-${WGET2_VERSION}.tar.xz && cd wget2-${WGET2_VERSION} && export FORCE_UNSAFE_CONFIGURE=1 && ./configure CFLAGS="-O2 -static" LDFLAGS="-static" --disable-shared --enable-static --disable-nls --disable-rpath --disable-doc && make -j$(nproc) && make install-strip DESTDIR=./output
```

输出可能在 `src/output/usr/local/bin/*` 或 `output/usr/local/bin/*`
