FROM eimhin/base:ubuntu

ENV NODE_VERSION=6.10.1

USER root

RUN apt-get update && \
    apt-get install build-essential software-properties-common -y && \
    add-apt-repository ppa:ubuntu-toolchain-r/test -y && \
    apt-get update && \
    apt-get install gcc-snapshot -y && \
    apt-get update && \
    apt-get install gcc-6 g++-6 -y && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-6 60 --slave /usr/bin/g++ g++ /usr/bin/g++-6 && \
    apt-get install gcc-4.8 g++-4.8 -y && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 60 --slave /usr/bin/g++ g++ /usr/bin/g++-4.8

USER user

RUN git clone https://github.com/nodenv/nodenv.git ~/.nodenv && \
    cd ~/.nodenv && \
    src/configure && \
    make -C src && \
    echo 'export PATH="$HOME/.nodenv/bin:$PATH"' >> ~/.zshrc && \
    export PATH="$HOME/.nodenv/bin:$PATH" && \
    echo 'eval "$(nodenv init -)"' >> ~/.zshrc && \
    eval "$(nodenv init -)" && \
    git clone https://github.com/nodenv/node-build.git $(nodenv root)/plugins/node-build && \
    nodenv install $NODE_VERSION && \
    nodenv global $NODE_VERSION && \
    nodenv rehash && \
    npm install -g vue-cli

EXPOSE 3000
LABEL che:server:3000:ref=node-3000 che:server:3000:protocol=http
