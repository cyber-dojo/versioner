FROM alpine:latest
LABEL maintainer=jon@jaggersoft.com

COPY . /app

ARG SHA
ENV SHA=${SHA}

ARG RELEASE
ENV RELEASE=${RELEASE}

# Note: older commander's cyber-dojo script relies on
# there _not_ being an ENTRYPOINT
