FROM cyberdojo/rack-base:latest
LABEL maintainer=jon@jaggersoft.com

WORKDIR /app
COPY . .

ARG SHA
ENV SHA=${SHA}

ARG RELEASE
ENV RELEASE=${RELEASE}
