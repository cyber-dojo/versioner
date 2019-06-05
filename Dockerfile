FROM cyberdojo/rack-base:latest
LABEL maintainer=jon@jaggersoft.com

WORKDIR /app
COPY .env .

ARG SHA
ENV SHA=${SHA}
