FROM ubuntu:lunar AS builder

ARG LLVM=16
ARG MESA_VERSION=23.1.0

# install build deps
RUN apt-get -q update && apt-get -q install --no-install-recommends -y \
  autoconf \
  automake \
  bison \
  build-essential \
  ca-certificates \
  cmake \
  elfutils \
  flex \
  git \
  libelf-dev \
  libexpat1-dev \
  libpolly-${LLVM}-dev \
  libudev-dev \
  libx11-dev \
  libxcb-randr0-dev \
  libxext-dev \
  libxrandr-dev \
  libzstd-dev \
  llvm-${LLVM}-dev \
  meson \
  pkg-config \
  python3-mako \
  zlib1g-dev \
&& rm -rf /var/lib/apt/lists/*

RUN set -xe; \
  mkdir -p /var/tmp/build; \
  cd /var/tmp/build/; \
  git clone --depth=1 --branch=mesa-${MESA_VERSION} https://gitlab.freedesktop.org/mesa/mesa.git;

RUN set -xe; \
  cd /var/tmp/build/mesa; \
  meson setup \
  --buildtype=release \
  --prefix=/usr/local \
  --sysconfdir=/etc \
  -D platforms=x11 \
  -D dri3=disabled  \
  -D gallium-drivers=swrast \
  -D gallium-omx=disabled \
  -D gallium-xa=disabled \
  -D vulkan-drivers=[] \
  -D shader-cache=enabled \
  -D shared-glapi=disabled \
  -D gles1=disabled \
  -D gles2=disabled \
  -D gbm=disabled \
  -D glx=xlib \
  -D egl=disabled \
  -D microsoft-clc=disabled \
  -D llvm=enabled \
  -D shared-llvm=disabled \
  -D valgrind=disabled \
  -D libunwind=disabled \
  -D lmsensors=disabled \
  -D enable-glcpp-tests=false \
  -D osmesa=false \
  -D gallium-d3d12-video=disabled \
  -D optimization=3 \
  build/; \
  ninja -C build/ -j $(getconf _NPROCESSORS_ONLN); \
  ninja -C build/ install

FROM scratch

COPY --from=builder /usr/local /usr/local
