FROM debian:bullseye

# Install dependencies
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/' /etc/apt/sources.list && \
    apt-get -qq update && \
    apt-get install -qqy --no-install-recommends \
        ca-certificates \
        autoconf automake cmake dpkg-dev file git make patch \
        libc-dev libc++-dev libgcc-10-dev libstdc++-10-dev  \
        dirmngr gnupg2 lbzip2 xz-utils libtinfo5 \
        g++ gdb lcov gettext-base jq curl && \
    rm -rf /var/lib/apt/lists/*

# Signing keys
ENV GPG_KEYS 09C4E7007CB2EFFB A2C794A986419D8A B4468DF4E95C63DC D23DD2C20DD88BA2 8F0871F202119294 0FC3042E345AD05D

# Retrieve keys
RUN gpg --batch --keyserver keyserver.ubuntu.com --recv-keys $GPG_KEYS

# Version info
ENV LLVM_RELEASE 4
ENV LLVM_VERSION 4.0.1

# Install Clang and LLVM
COPY install.sh .
RUN ./install.sh

# Install GTest
ENV DEBIAN_FRONTEND noninteractive
ENV CMAKE_C_COMPILER /usr/local/bin/clang
ENV CMAKE_CXX_COMPILER /usr/local/bin/clang++
ENV CMAKE_CXX_FLAGS    -std=c++17
ENV CMAKE_AR           "/usr/local/bin/llvm-ar"
ENV CMAKE_LINKER       "/usr/local/bin/llvm-ld"
ENV CMAKE_NM           "/usr/local/bin/llvm-nm"
ENV CMAKE_OBJDUMP      "/usr/local/bin/llvm-objdump"
ENV CMAKE_RANLIB       "/usr/local/bin/llvm-ranlib"

COPY googletest /usr/src/googletest
RUN mkdir /usr/src/googletest/build && cd /usr/src/googletest/build && \
    cmake .. && make && make install
RUN rm -rf /usr/src/googletest
