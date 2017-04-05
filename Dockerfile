FROM eclipse/stack-base:ubuntu

ENV NODE_VERSION=6.10.1

USER root

RUN apt-get update && \
    apt-get install -y zsh && \
    usermod -s /bin/zsh user

USER user

RUN touch ~/.zshrc && \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

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
    nodenv rehash
    
EXPOSE 3000

RUN npm install -g vue-cli

LABEL che:server:3000:ref=node-3000 che:server:3000:protocol=http
