#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
export SHA=$(cd "${ROOT_DIR}" && git rev-parse HEAD)

docker build \
  --build-arg RELEASE \
  --build-arg SHA \
  --tag cyberdojo/versioner \
  "${ROOT_DIR}"
