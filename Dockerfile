FROM cyberdojo/rack-base:latest
LABEL maintainer=jon@jaggersoft.com

WORKDIR /app
COPY . .

ARG SHA
ENV SHA=${SHA}

ARG RELEASE
ENV RELEASE=${RELEASE}

# NB: commander's cyber-dojo script relies on
# there _not_ being an ENTRYPOINT
