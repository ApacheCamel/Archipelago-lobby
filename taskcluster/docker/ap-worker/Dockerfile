ARG PYTHON_VERSION=3.12
ARG SRC=topsrcdir
ARG DOCKER_SRC=/


FROM alpine:latest AS enemizer

ADD --checksum=sha256:efab6784cbfe4189a01e0e25226943afd7f71e7c2f10f74b88bfa34fdac972ab https://github.com/Ijwu/Enemizer/releases/latest/download/ubuntu.16.04-x64.zip Enemizer.zip
RUN apk update && apk add unzip && unzip Enemizer.zip -d /Enemizer

FROM ghcr.io/astral-sh/uv:python${PYTHON_VERSION}-trixie AS builder
ARG SRC
ARG DOCKER_SRC

ENV UV_PYTHON_DOWNLOADS=0

ENV BASE_COMMIT=799e0b7b0fa3c965995a6288c651d2f4d800e4ff
ENV FUZZER_COMMIT=17227d793cc1088ae9be5fe97421e73bb683efdf
ENV LINTER_COMMIT=52cfa67f7e40ebe15bf6bff6d17adb6409ad97dc

WORKDIR /ap

# %include ap-worker

COPY ${SRC}/ap-worker /ap/ap-worker
COPY ${DOCKER_SRC}/prepare_worlds.sh /ap/prepare_worlds.sh
COPY ${DOCKER_SRC}/setup.sh /ap/setup.sh

RUN sh /ap/setup.sh ${BASE_COMMIT} ${FUZZER_COMMIT} ${LINTER_COMMIT} && rm /ap/setup.sh

FROM python:${PYTHON_VERSION}-slim-trixie
ARG DOCKER_SRC

RUN apt update && apt install -y curl libtk8.6 libpq5
RUN ARCH=$(dpkg --print-architecture) && \
    case "$ARCH" in \
        amd64) WATCHEXEC_ARCH="x86_64-unknown-linux-gnu" ;; \
        arm64) WATCHEXEC_ARCH="aarch64-unknown-linux-gnu" ;; \
        *) echo "Unsupported arch: $ARCH" && exit 1 ;; \
    esac && \
    curl -fsSL "https://github.com/watchexec/watchexec/releases/download/v2.5.1/watchexec-2.5.1-${WATCHEXEC_ARCH}.deb" -o /tmp/watchexec.deb && \
    dpkg -i /tmp/watchexec.deb && \
    rm /tmp/watchexec.deb

RUN mkdir /ap
WORKDIR /ap

COPY ${DOCKER_SRC}/host.yaml /ap/archipelago/host.yaml
COPY --from=enemizer /Enemizer /ap/enemizer
RUN chmod +x /ap/enemizer/EnemizerCLI.Core

COPY --from=builder /ap/archipelago/ /ap/archipelago/
COPY --from=builder /ap/supported_worlds/ /ap/supported_worlds/
COPY --from=builder /ap/ap-worker/ /ap/ap-worker/

ENV PATH="/ap/.venv/bin:$PATH"
