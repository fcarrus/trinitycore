FROM docker.io/ubuntu:22.04 as builder

RUN apt-get update && \
      apt-get install --assume-yes git clang cmake make gcc g++ libmysqlclient-dev libssl-dev libbz2-dev libreadline-dev libncurses-dev libboost-all-dev mysql-server p7zip && \
      update-alternatives --install /usr/bin/cc cc /usr/bin/clang 100 && \
      update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang 100

RUN useradd -m trinity -d /home/trinity

USER trinity

WORKDIR /home/trinity

RUN git clone --depth 1 -b 3.3.5 https://github.com/TrinityCore/TrinityCore.git

RUN cd TrinityCore && \
      mkdir build && \
      cd build && \
      cmake ../ -DSCRIPTS=static -DCMAKE_INSTALL_PREFIX=/home/trinity/server/ && \
      make -j4 install

FROM docker.io/ubuntu:22.04 as runtime

RUN apt-get update && \
      apt-get install --assume-yes git clang cmake make gcc g++ libmysqlclient-dev libssl-dev libbz2-dev libreadline-dev libncurses-dev libboost-all-dev mysql-server p7zip && \
      update-alternatives --install /usr/bin/cc cc /usr/bin/clang 100 && \
      update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang 100

COPY --from=builder /home/trinity/server/ /opt/trinitycore/

RUN chown -R root:root /opt/trinitycore

RUN chmod -R 755 /opt/trinitycore

WORKDIR /opt/trinitycore

CMD /bin/bash


