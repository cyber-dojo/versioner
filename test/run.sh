#!/bin/bash
set -e

ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

for file in ${ROOT_DIR}/test/test_*.rb; do
  filename=$(basename "${file}")
  docker run \
    --rm \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    --volume "${ROOT_DIR}/.env:/app/.env:ro" \
    --volume "${ROOT_DIR}/test:/app/test:ro" \
    cyberdojo/docker-base \
      "/app/test/${filename}"
done
