ARG BASE_IMAGE=alpine:3.18.4
FROM ${BASE_IMAGE}
LABEL maintainer=jon@jaggersoft.com

COPY . /app

ARG SHA
ENV SHA=${SHA}

ARG RELEASE
ENV RELEASE=${RELEASE}

# ARGs are reset after FROM See https://github.com/moby/moby/issues/34129
ARG BASE_IMAGE
ENV BASE_IMAGE=${BASE_IMAGE}

RUN mv /app/cat /usr/local/bin/cat

ENTRYPOINT [ "/usr/local/bin/cat", "/app/.env" ]
