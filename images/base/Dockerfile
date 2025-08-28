FROM ubuntu:25.10

ARG TARGETPLATFORM

ENV DEBIAN_FRONTEND=noninteractive

RUN \
    mkdir -p /downloads && \
    apt-get -y update && \
    apt-get -y dist-upgrade && \
    apt-get -y install --no-install-recommends \
        $([ "$TARGETPLATFORM" != "linux/amd64" ] || echo gcc-multilib g++-multilib) \
        build-essential yasm nasm \
        systemd language-pack-zh-hans language-pack-zh-hans-base tzdata locales  \
        xxd pkgconf curl wget unzip zip git subversion mercurial rsync jq \
        autoconf automake libtool libtool-bin autopoint gettext cmake meson ninja-build \
        clang llvm lcov lld \
        texinfo texi2html help2man flex bison groff \
        gperf itstool ragel libc6-dev zlib1g-dev libssl-dev \
        gtk-doc-tools gobject-introspection gawk \
        ocaml ocamlbuild libnum-ocaml-dev indent p7zip-full zstd \
        python3-setuptools python3-pip python3-venv python3-jinja2 python3-jsonschema python3-apt python-is-python3 && \
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    curl -fsSL -o /downloads/sh.rustup.rs https://sh.rustup.rs && \
    apt-get -y install nodejs && \
    apt-get -y autoremove && \
    apt-get -y clean autoclean && \
    rm -rf /var/lib/apt/lists/* && \
    locale-gen zh_CN.UTF-8 && \
    ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
	echo 'Asia/Shanghai' > /etc/timezone && \
    git config --global user.email "builder@localhost" && \
    git config --global user.name "Builder" && \
    git config --global advice.detachedHead false

ENV LANG=zh_CN.UTF-8 LC_ALL=zh_CN.UTF-8 TZ=Asia/Shanghai LANGUAGE=zh_CN:en
ENV CARGO_HOME="/opt/cargo" RUSTUP_HOME="/opt/rustup" PATH="/opt/cargo/bin:${PATH}"
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y --no-modify-path && \
    cargo install cargo-c && rm -rf "${CARGO_HOME}"/registry "${CARGO_HOME}"/git
RUN  --mount=src=.,dst=/input \
  printf '%s\n' 'Types: deb' 'URIs: http://archive.ubuntu.com/ubuntu/' 'Suites: noble noble-updates noble-backports' 'Components: main universe' 'Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg' '' >/etc/apt/sources.list.d/ubuntu.sources &&\
  apt-get -y upgrade build-essential ca-certificates yasm nasm\
  xxd pkgconf curl wget unzip zip git subversion mercurial rsync jq\
  autoconf automake libtool libtool-bin autopoint gettext cmake clang meson ninja-build\
  texinfo texi2html help2man flex bison groff\
  gperf itstool ragel libc6-dev zlib1g-dev libssl-dev\
  gtk-doc-tools gobject-introspection gawk\
  ocaml ocamlbuild libnum-ocaml-dev indent p7zip-full\
  python3-setuptools python3-jinja2 python3-jsonschema python3-apt python-is-python3 &&\
 update-ca-certificates &&\
 git config --global user.email "builder@localhost" &&\
 git config --global user.name "Builder" &&\
 git config --global advice.detachedHead false &&\
 bash /downloads/sh.rustup.rs -y --no-modify-path && \
 cargo install cargo-c && rm -rf "${CARGO_HOME}"/registry "${CARGO_HOME}"/git &&\
    for s in /input/*.sh; do cp $s /usr/bin/$(echo $s | sed -e 's|.*/||' -e 's/\.sh$//'); done &&\
 cd /usr/bin &&\
 ln -sfT gcc cc &&\
 ln -sfT g++ c++
ENV DEBIAN_FRONTEND=noninteractive\
 CARGO_HOME="/opt/cargo"\
 RUSTUP_HOME="/opt/rustup"\
 PATH="/opt/cargo/bin:${PATH}"\
 HOST_CC="gcc" \
 HOST_CXX="g++" \
 HOST_CFLAGS="-O3 -fno-unroll-loops -fno-align-functions -fno-align-jumps -fno-unroll-loops -flto=auto -fno-math-errno -fno-trapping-math -fno-align-labels -fno-align-loops -fno-ipa-cp-clone -fipa-pta -pipe -fwrapv -fivopts -fomit-frame-pointer -g0 -DNDEBUG -U_FORTIFY_SOURCE -fno-asynchronous-unwind-tables -w" \
 HOST_CXXFLAGS="-O3 -fno-unroll-loops -fno-align-functions -fno-align-jumps -fno-unroll-loops -flto=auto -fno-math-errno -fno-trapping-math -fno-align-labels -fno-align-loops -fno-ipa-cp-clone -fipa-pta -pipe -fwrapv -fivopts -fomit-frame-pointer -g0 -DNDEBUG -U_FORTIFY_SOURCE -fno-asynchronous-unwind-tables -w"
