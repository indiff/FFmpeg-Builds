FROM ubuntu:25.10

ARG TARGETPLATFORM

ENV DEBIAN_FRONTEND=noninteractive
RUN \
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
        indent p7zip-full zstd \
        python3-setuptools python3-pip python3-venv python3-jinja2 python3-jsonschema python3-apt python-is-python3 \
        pkg-config sudo libncurses5-dev libgavl-dev tree && \
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
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

# RUN \    
#     bash -c "printf '\n\n' | sh <(curl -fsSL https://opam.ocaml.org/install.sh)" && \
#     opam init --disable-sandboxing --bare && \
#     bash -c "eval $(opam env)" && \
#     opam switch create ocamlbuild && \
#     opam install -y ocamlfind ocamlbuild num ocaml-base-compiler && \
#     bash -c "echo $(opam env)" && \
#     bash -c "eval $(opam env)" && \
#     bash -c "eval $(opam env) && ocamlfind ocamlopt -package num -linkpkg -c number.ml"
# Installing OCaml needed to compile libvyosconfig

RUN curl https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh \
      --output /tmp/opam_install.sh --retry 10 --retry-delay 5 && \
    sed -i 's/read_tty BINDIR/BINDIR=""/' /tmp/opam_install.sh && sh /tmp/opam_install.sh && \
    opam init --root=/opt/opam --disable-sandboxing --no-setup \
    && rm /tmp/opam_install.sh

RUN eval $(opam env --root=/opt/opam --set-root) && opam install -y \
      ocamlfind \
      ocamlbuild \
      num \
      ocaml-base-compiler

# 假设之前已安装 opam 并 opam init、opam install 已做过
RUN tree /opt/opam && \
    eval "$(opam env --root=/opt/opam --set-root)" && \
    echo "OPAM_BIN=$(opam var bin --root=/opt/opam --set-root)" && \
    ocamlfind --version && \
    ocamlfind list | grep -E '^num$' && \
    printf 'open Num\nlet () = print_endline (string_of_num (num_of_int 42))\n' > /tmp/number.ml && \
    ocamlfind ocamlopt -package num -linkpkg -o /tmp/test_num /tmp/number.ml && \
    /tmp/test_num
    
ENV LANG=zh_CN.UTF-8 LC_ALL=zh_CN.UTF-8 TZ=Asia/Shanghai LANGUAGE=zh_CN:en
ENV CARGO_HOME="/opt/cargo" RUSTUP_HOME="/opt/rustup" PATH="/root/.opam/ocamlbuild/bin:/opt/cargo/bin:${PATH}"
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y --no-modify-path && \
    cargo install cargo-c && rm -rf "${CARGO_HOME}"/registry "${CARGO_HOME}"/git

RUN --mount=src=.,dst=/input \
    for s in /input/*.sh; do cp $s /usr/bin/$(echo $s | sed -e 's|.*/||' -e 's/\.sh$//'); done

ENV HOST_CC="gcc" \
    HOST_CXX="g++" \
    HOST_CFLAGS="-O3 -pipe" \
    HOST_CXXFLAGS="-O3 -pipe"

RUN which ocamlbuild
RUN ocamlbuild --version