FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive
RUN \
    apt-get -y update && \
    apt-get -y dist-upgrade && \
    apt-get -y install build-essential yasm nasm \
        systemd language-pack-zh-hans language-pack-zh-hans-base locales  \
        xxd pkgconf curl wget unzip zip git subversion mercurial rsync jq \
        autoconf automake libtool libtool-bin autopoint gettext cmake clang meson ninja-build \
        texinfo texi2html help2man flex bison groff \
        gperf itstool ragel libc6-dev zlib1g-dev libssl-dev \
        gtk-doc-tools gobject-introspection gawk \
        ocaml ocamlbuild libnum-ocaml-dev indent p7zip-full \
        python3-setuptools python3-jinja2 python3-jsonschema python3-apt python-is-python3 && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get -y install nodejs && \
    apt-get -y clean && \
    locale-gen zh_CN.UTF-8; /usr/bin/localectl set-locale LANG=zh_CN.UTF-8 || true ; \
    /usr/bin/timedatectl set-timezone Asia/Shanghai || true; \
    /usr/bin/timedatectl set-ntp true || true; \
    git config --global user.email "builder@localhost" && \
    git config --global user.name "Builder" && \
    git config --global advice.detachedHead false

ENV LANG zh_CN.UTF-8
ENV LANGUAGE zh_CN:en
ENV LC_ALL zh_CN.UTF-8

ENV CARGO_HOME="/opt/cargo" RUSTUP_HOME="/opt/rustup" PATH="/opt/cargo/bin:${PATH}"
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y --no-modify-path && \
    cargo install cargo-c && rm -rf "${CARGO_HOME}"/registry "${CARGO_HOME}"/git

RUN --mount=src=.,dst=/input \
    for s in /input/*.sh; do cp $s /usr/bin/$(echo $s | sed -e 's|.*/||' -e 's/\.sh$//'); done

ENV HOST_CC="gcc" \
    HOST_CXX="g++" \
    HOST_CFLAGS="-O2 -pipe" \
    HOST_CXXFLAGS="-O2 -pipe"
