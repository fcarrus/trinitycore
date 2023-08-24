FROM docker.io/ubuntu:22.04 as base

RUN apt-get update && \
      apt-get install \
        --assume-yes \
        git clang cmake make gcc g++ libmysqlclient-dev \
        libssl-dev libbz2-dev mysql-client libreadline-dev libncurses-dev \
        libboost-all-dev p7zip telnet curl && \
      update-alternatives --install /usr/bin/cc cc /usr/bin/clang 100 && \
      update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang 100

FROM base as builder

ARG TRINITYCORE_BRANCH="3.3.5" 

ARG TRINITYCORE_TDB_RELEASE="TDB335.23061/TDB_full_world_335.23061_2023_06_14"

ARG TRINITYCORE_DIRECTORY="/opt/trinitycore"

RUN useradd -m trinity -d ${TRINITYCORE_DIRECTORY}

USER trinity

WORKDIR ${TRINITYCORE_DIRECTORY}

RUN git clone --depth 1 -b "${TRINITYCORE_BRANCH}" https://github.com/TrinityCore/TrinityCore.git

RUN cd TrinityCore && \
      mkdir build && \
      cd build && \
      cmake ../ -DSCRIPTS=static -DCMAKE_INSTALL_PREFIX=${TRINITYCORE_DIRECTORY} && \
      make -j4 install

FROM base as runtime

ARG TRINITYCORE_BRANCH="3.3.5"

ARG TRINITYCORE_TDB_RELEASE="TDB335.23061/TDB_full_world_335.23061_2023_06_14"

ARG TRINITYCORE_DIRECTORY="/opt/trinitycore"

COPY --from=builder ${TRINITYCORE_DIRECTORY}/bin/ ${TRINITYCORE_DIRECTORY}/bin/

COPY --from=builder ${TRINITYCORE_DIRECTORY}/TrinityCore/sql/ ${TRINITYCORE_DIRECTORY}/TrinityCore/sql/

WORKDIR ${TRINITYCORE_DIRECTORY}

RUN cd TrinityCore && \
    curl -LO https://github.com/TrinityCore/TrinityCore/releases/download/${TRINITYCORE_TDB_RELEASE}.7z

RUN chown -R root:root ${TRINITYCORE_DIRECTORY}

RUN chmod -R 777 ${TRINITYCORE_DIRECTORY}

CMD /usr/bin/bash
