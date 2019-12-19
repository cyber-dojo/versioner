#!/bin/sh
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

${ROOT_DIR}/sh/latest-env.sh    | tee ${ROOT_DIR}/.env
${ROOT_DIR}/sh/latest-env-md.sh | tee ${ROOT_DIR}/.env.md