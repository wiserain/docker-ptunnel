ARG ALPINE_VER
FROM ghcr.io/linuxserver/baseimage-alpine:${ALPINE_VER} AS base

RUN \
    echo "**** install frolvlad/alpine-python3 ****" && \
	apk add --no-cache python3 && \
	if [ ! -e /usr/bin/python ]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
	python3 -m ensurepip && \
	rm -r /usr/lib/python*/ensurepip && \
	pip3 install --no-cache --upgrade pip setuptools wheel && \
	if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip; fi && \
	echo "**** cleanup ****" && \
	rm -rf \
		/tmp/* \
		/root/.cache

# 
# BUILD
# 
FROM base AS builder

RUN \
    echo "**** install green-tunnel ****" && \
    apk add npm && \
    npm i -g --prefix /bar/usr green-tunnel

RUN \
    echo "**** install python-proxy ****" && \
    apk add --no-cache \
        build-base \
        musl-dev \
        python3-dev && \
    pip3 install --root /bar --no-warn-script-location \
        pproxy[accelerated]

# add local files
COPY root/ /bar/

# 
# RELEASE
# 
FROM base
LABEL maintainer="wiserain"
LABEL org.opencontainers.image.source https://github.com/wiserain/docker-ptunnel

ENV \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    PYTHONUNBUFFERED=1 \
    TZ=Asia/Seoul \
    GT_ENABLED=true \
    GT_UPDATE=false \
    PROXY_ENABLED=true

COPY --from=builder /bar/ /

RUN \
    echo "**** install nodejs ****" && \
    apk add --no-cache nodejs-current && \
    echo "**** install others ****" && \
    apk add --no-cache ca-certificates bash curl && \
    echo "**** permissions ****" && \
    chmod a+x /usr/local/bin/* && \
    echo "**** cleanup ****" && \
    rm -rf \
        /tmp/* \
        /root/.cache

EXPOSE 8008 21000
VOLUME /config
WORKDIR /config

HEALTHCHECK --interval=10m --timeout=30s --start-period=10s --retries=3 \
    CMD /usr/local/bin/healthcheck

ENTRYPOINT ["/init"]
