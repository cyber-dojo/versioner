#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
export SHA=$(cd "${ROOT_DIR}" && git rev-parse HEAD)

readonly IMAGE=cyberdojo/versioner

docker build \
  --build-arg RELEASE \
  --build-arg SHA \
  --tag ${IMAGE} \
  "${ROOT_DIR}"

docker tag ${IMAGE}:latest ${IMAGE}:${SHA:0:7}
docker run --rm ${IMAGE}:latest sh -c 'echo ${SHA}'
