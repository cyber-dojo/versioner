#!/bin/sh
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

${ROOT_DIR}/sh/latest-env.sh    | tee ${ROOT_DIR}/app/.env
if [ "${PIPESTATUS[0]}" != '0' ]; then
  exit 42
fi

${ROOT_DIR}/sh/latest-env-md.sh | tee ${ROOT_DIR}/app/.env.md
if [ "${PIPESTATUS[0]}" != '0' ]; then
  exit 42
fi
