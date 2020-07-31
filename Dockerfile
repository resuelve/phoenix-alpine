FROM ubuntu:20.04
LABEL maintainer="Erick Reyna <erickueen@resuelve.mx>"
ARG DEBIAN_FRONTEND=noninteractive
ENV ERLANG_VERSION=23.0.3
ENV ELIXIR_COMMIT=1145dc01680aab7094f8a6dbd38b65185e14adb4
ENV NODE_VERSION=12.18.3
ENV PHOENIX_VERSION=1.5.4
RUN apt update
RUN apt install -y curl git wkhtmltopdf inotify-tools locales && locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
RUN apt-get -y install build-essential autoconf m4 libncurses5-dev libwxgtk3.0-gtk3-dev libgl1-mesa-dev libglu1-mesa-dev libpng-dev libssh-dev unixodbc-dev xsltproc fop libxml2-utils libncurses-dev openjdk-11-jdk
RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf
ENV KERL_CONFIGURE_OPTIONS --disable-silent-rules --without-javac --enable-shared-zlib --enable-dynamic-ssl-lib --enable-hipe --enable-sctp --enable-smp-support --enable-threads --enable-kernel-poll --enable-wx --disable-debug --without-javac --enable-darwin-64bit
RUN cd ~/.asdf && git checkout "$(git describe --abbrev=0 --tags)"
ENV PATH /root/.asdf/bin:/root/.asdf/shims:${PATH}
RUN /bin/bash -c "source ~/.bashrc"
RUN /bin/bash -c "asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git"
RUN /bin/bash -c "asdf install erlang $ERLANG_VERSION"
RUN /bin/bash -c "asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git"
RUN /bin/bash -c "asdf global erlang $ERLANG_VERSION"
RUN /bin/bash -c "asdf install elixir ref:$ELIXIR_COMMIT"
RUN /bin/bash -c "asdf global elixir ref:$ELIXIR_COMMIT"
RUN /bin/bash -c "asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git"
RUN /bin/bash -c "bash -c '${ASDF_DATA_DIR:=$HOME/.asdf}/plugins/nodejs/bin/import-release-team-keyring'"
RUN /bin/bash -c "asdf install nodejs $NODE_VERSION"
RUN /bin/bash -c "asdf global nodejs $NODE_VERSION"
RUN /bin/bash -c "mix local.hex --force"
RUN /bin/bash -c "mix local.rebar --force"
RUN /bin/bash -c "mix archive.install --force hex phx_new $PHOENIX_VERSION"
