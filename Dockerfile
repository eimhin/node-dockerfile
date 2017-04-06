FROM ubuntu:16.04

ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH
RUN apt-get update && \
    apt-get -y install \
    openssh-server \
    sudo \
    procps \
    wget \
    unzip \
    mc \
    ca-certificates \
    curl \
    software-properties-common \
    python-software-properties \
    bash-completion \
    zsh && \
    mkdir /var/run/sshd && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    useradd -u 1000 -G users,sudo -d /home/user --shell /bin/zsh -m user && \
    usermod -p "*" user && \
    add-apt-repository ppa:git-core/ppa && \
    add-apt-repository ppa:openjdk-r/ppa && \
    apt-get update && \
    sudo apt-get install git subversion -y && \
    apt-get clean && \
    apt-get -y autoremove && \
    sudo apt-get install openjdk-8-jdk-headless openjdk-8-source -y && \
    sudo update-ca-certificates -f && \
    sudo sudo /var/lib/dpkg/info/ca-certificates-java.postinst configure && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo "#! /bin/zsh\n set -e\n sudo /usr/sbin/sshd -D &\n exec \"\$@\"" > /home/user/entrypoint.sh && chmod a+x /home/user/entrypoint.sh

RUN apt-get update
RUN apt-get install build-essential software-properties-common -y
RUN add-apt-repository ppa:ubuntu-toolchain-r/test -y
RUN apt-get update
RUN apt-get install gcc-snapshot -y
RUN apt-get update
RUN apt-get install gcc-6 g++-6 -y
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-6 60 --slave /usr/bin/g++ g++ /usr/bin/g++-6
RUN apt-get install gcc-4.8 g++-4.8 -y
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 60 --slave /usr/bin/g++ g++ /usr/bin/g++-4.8

ENV LANG en_GB.UTF-8
ENV LANG en_US.UTF-8

ENV NODE_VERSION=6.10.1

USER user

RUN sudo locale-gen en_US.UTF-8 && \
    svn --version && \
    cd /home/user && ls -la && \
    sed -i 's/# store-passwords = no/store-passwords = yes/g' /home/user/.subversion/servers && \
    sed -i 's/# store-plaintext-passwords = no/store-plaintext-passwords = yes/g' /home/user/.subversion/servers

RUN touch ~/.zshrc
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
RUN git clone https://github.com/nodenv/nodenv.git ~/.nodenv
RUN cd ~/.nodenv
RUN src/configure
RUN make -C src
RUN echo 'export PATH="$HOME/.nodenv/bin:$PATH"' >> ~/.zshrc
RUN export PATH="$HOME/.nodenv/bin:$PATH"
RUN echo 'eval "$(nodenv init -)"' >> ~/.zshrc
RUN eval "$(nodenv init -)"
RUN git clone https://github.com/nodenv/node-build.git $(nodenv root)/plugins/node-build
RUN nodenv install $NODE_VERSION
RUN nodenv global $NODE_VERSION
RUN nodenv rehash

RUN npm install -g vue-cli

EXPOSE 22 4403 3000
LABEL che:server:3000:ref=node-3000 che:server:3000:protocol=http
WORKDIR /projects
ENTRYPOINT ["/home/user/entrypoint.sh"]
CMD tail -f /dev/null
