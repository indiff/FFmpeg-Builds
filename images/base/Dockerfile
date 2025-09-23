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
        m4 opam ocaml-findlib \
        pkg-config sudo libncurses5-dev libgavl-dev tree patch libgmp-dev libffi-dev dpkg-dev && \
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

# RUN curl https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh \
#       --output /tmp/opam_install.sh --retry 10 --retry-delay 5 && \
#     sed -i 's/read_tty BINDIR/BINDIR=""/' /tmp/opam_install.sh && sh /tmp/opam_install.sh && \
#     opam init --root=/opt/opam --disable-sandboxing --no-setup \
#     && rm /tmp/opam_install.sh

RUN set -xe && git clone https://github.com/indiff/ocaml-num.git /usr/local/src/ocaml-num && \
    cd /usr/local/src/ocaml-num && \
    opam init --disable-sandboxing --bare -y && \
    bash -c "printf '\n\n' | opam switch create . 5.3.0" && \
    opam install -y dune && \
    opam install -y . --deps-only --with-doc --with-test && \
    opam pin add -y num . --no-action && \
    bash -c "printf '\n\n' | opam exec -- make PROFILE=release" && \
    bash -c "printf '\n\n' | opam exec -- make install" && \
    bash -c "printf '\n\n' | opam exec -- make clean"

RUN eval $(opam env --root=/opt/opam --set-root) && opam install -y \
      ocamlfind \
      ocamlbuild \
      ocaml-base-compiler
      
# RUN git clone https://github.com/ocaml/num.git /usr/local/src/ocaml_num && \
#     cd /usr/local/src/ocaml_num && \
#     make all && \
#     make test && \
#     make install && \
#     make clean


# ocamlfind ocamlopt -package num -linkpkg -o /tmp/test_num /tmp/number.ml && \

    
ENV LANG=zh_CN.UTF-8 LC_ALL=zh_CN.UTF-8 TZ=Asia/Shanghai LANGUAGE=zh_CN:en
ENV CARGO_HOME="/opt/cargo" RUSTUP_HOME="/opt/rustup" PATH="/opt/opam/default/bin:/opt/cargo/bin:${PATH}"
ENV OPAMROOT=/opt/opam
ENV OPAM_SWITCH_PREFIX=/opt/opam/default
ENV CAML_LD_LIBRARY_PATH="/opt/opam/default/lib/stublibs:/opt/opam/default/lib/ocaml/stublibs:/opt/opam/default/lib/ocaml"
ENV OCAML_TOPLEVEL_PATH=/opt/opam/default/lib/toplevel
ENV MANPATH="/opt/opam/default/man:${MANPATH}"


# RUN git clone https://github.com/ocaml/num.git /usr/local/src/ocaml_num && \
#     cd /usr/local/src/ocaml_num && \
#     eval $(opam env --root=/opt/opam --set-root) && \
#     make install && \
#     make clean



RUN tree /opt/opam/default/bin && \
    echo $(opam env --root=/opt/opam --set-root) && \
    eval $(opam env --root=/opt/opam --set-root) && \
    ocamlfind list  && \
    printf 'open Num\nlet () = print_endline (string_of_num (num_of_int 87))\n' > /tmp/number.ml && \
    eval $(opam env --root=/opt/opam --set-root) && \
    /opt/opam/default/bin/ocamlopt.opt -o /tmp/test_num /tmp/number.ml && /tmp/test_num && \
    opam env --root=/opt/opam --set-root > /etc/profile.d/opam.sh && chmod +x /etc/profile.d/opam.sh && \
    rm -f /tmp/test_num

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
RUN printf 'open Num\nlet () = print_endline (string_of_num (num_of_int 88))\n' > /tmp/number.ml && \
    /opt/opam/default/bin/ocamlopt.opt -o /tmp/test_num /test/number.ml && /tmp/test_num && \
    rm -f /tmp/test_num
