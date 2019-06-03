#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
readonly SHA=$(cd "${ROOT_DIR}" && git rev-parse HEAD)

docker build \
  --build-arg SHA=${SHA} \
  --tag cyberdojo/versioner \
  "${ROOT_DIR}"
