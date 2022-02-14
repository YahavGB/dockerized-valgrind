FROM alpine:3.12

ARG USERNAME=labcc

RUN apk add --no-cache \
    gcc \
    g++ \
    make \
    cmake \
    valgrind \
    libc-dev \
    musl-dev

ENV CC /usr/bin/gcc
ENV CXX /usr/bin/g++

RUN \
    mkdir -p /output && \
    mkdir -p /input && \
    chmod -R a+rwX /output/ && \
    chmod -R a+rwX /input/

RUN adduser -SD ${USERNAME}
USER ${USERNAME}

RUN mkdir -p /home/${USERNAME}/build
WORKDIR /home/${USERNAME}/build

VOLUME ["/input", "/output"]