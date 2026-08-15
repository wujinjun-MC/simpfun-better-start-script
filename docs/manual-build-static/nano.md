# 编译静态 nano (gnu)

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

    ENV NANO_VERSION=9.2

    # 下载并解压源码
    RUN wget https://ftp.gnu.org/gnu/nano/nano-${NANO_VERSION}.tar.xz && \
        tar -xf nano-${NANO_VERSION}.tar.xz

    WORKDIR /build/nano-${NANO_VERSION}

    # 配置并进行静态编译
    RUN export FORCE_UNSAFE_CONFIGURE=1 && \
        ./configure \
        CFLAGS="-O2 -static" \
        LDFLAGS="-static" \
        --disable-shared \
        --enable-static \
        --disable-nls \
        --disable-rpath \
        --enable-utf8 && \
        make -j$(nproc) && \
        make install-strip DESTDIR=/build/output

    # 第二阶段：导出产物
    FROM scratch AS export
    COPY --from=builder /build/output/usr/local/bin/ /nano_bin/
    ```
- 如果支持Buildkit:
    - `DOCKER_BUILDKIT=1 docker build --output . .` ，直接输出到此文件夹
- 没有BUILDKIT:
    - 执行: `docker build -t nano-static .`
    - 输出产物
        ```bash
        # 创建用于导出的目录
        mkdir -p ./my_nano

        # 创建临时容器
        docker create --name nano_temp nano-static bash

        # 提取文件
        docker cp nano_temp:/nano_bin ./my_nano/

        # 删除临时容器
        docker rm nano_temp

        # 删除镜像
        docker image rm nano-static
        ```

## Debian/Ubuntu系列

```bash
apt install build-essential git markdown wget curl tar xz gzip perl
NANO_VERSION=9.2
wget https://ftp.gnu.org/gnu/nano/nano-${NANO_VERSION}.tar.xz
tar -xf nano-${NANO_VERSION}.tar.xz
cd nano-${NANO_VERSION}
export FORCE_UNSAFE_CONFIGURE=1
./configure CFLAGS="-O2 -static" LDFLAGS="-static" --disable-shared --enable-static --disable-nls --disable-rpath --enable-utf8 &&
    make -j$(nproc) &&
    make install-strip DESTDIR=./output
```

一行命令:
```bash
apt install build-essential git markdown wget curl tar xz gzip perl && NANO_VERSION=9.2 && wget https://ftp.gnu.org/gnu/nano/nano-${NANO_VERSION}.tar.xz && tar -xf nano-${NANO_VERSION}.tar.xz && cd nano-${NANO_VERSION} && export FORCE_UNSAFE_CONFIGURE=1 && ./configure CFLAGS="-O2 -static" LDFLAGS="-static" --disable-shared --enable-static --disable-nls --disable-rpath --enable-utf8 && make -j$(nproc) && make install-strip DESTDIR=./output
```

输出可能在 `src/output/usr/local/bin/*` 或 `output/usr/local/bin/*`
