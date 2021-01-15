FROM ghcr.io/linuxserver/baseimage-alpine:3.13
LABEL maintainer "wiserain"

# This hack is widely applied to avoid python printing issues in docker containers.
# See: https://github.com/Docker-Hub-frolvlad/docker-alpine-python3/pull/13
ENV PYTHONUNBUFFERED=1

# default environment settings
ENV TZ=Asia/Seoul
ENV GT_ENABLED=true
ENV GT_UPDATE=false
ENV PROXY_ENABLED=true

RUN \
    echo "**** install frolvlad/alpine-python3 ****" && \
	apk add --no-cache python3 && \
	if [ ! -e /usr/bin/python ]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
	python3 -m ensurepip && \
	rm -r /usr/lib/python*/ensurepip && \
	pip3 install --no-cache --upgrade pip setuptools wheel && \
	if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip; fi && \
    echo "**** install python-proxy ****" && \
    apk add --no-cache py3-pycryptodome && \
    apk add --no-cache --virtual=build-deps \
        build-base \
        python3-dev \
        musl-dev && \
    pip3 install pproxy[accelerated] && \
    apk del --no-cache --purge build-deps && \
    echo "**** install green-tunnel ****" && \
    apk add --no-cache npm && \
    npm i -g green-tunnel && \
    echo "**** install others ****" && \
    apk add --no-cache ca-certificates bash curl && \
    echo "**** cleanup ****" && \
    rm -rf \
        /tmp/* \
        /root/.cache

# add local files
COPY root/ /

RUN chmod a+x /healthcheck.sh

EXPOSE 8008 21000
VOLUME /config
WORKDIR /config

HEALTHCHECK --interval=10m --timeout=30s --start-period=10s --retries=3 \
    CMD [ "/healthcheck.sh" ]  

ENTRYPOINT ["/init"]
