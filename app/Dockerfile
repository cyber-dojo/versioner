FROM alpine:latest
LABEL maintainer=jon@jaggersoft.com

COPY . /app

ARG SHA
ENV SHA=${SHA}

ARG RELEASE
ENV RELEASE=${RELEASE}

RUN mv /app/cat /usr/local/bin/cat

ENTRYPOINT [ "/usr/local/bin/cat", "/app/.env" ]
