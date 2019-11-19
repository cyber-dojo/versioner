#!/bin/bash

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

${ROOT_DIR}/sh/latest_env.sh | tee ${ROOT_DIR}/.env
${ROOT_DIR}/sh/create-env-md.sh > ${ROOT_DIR}/.env.md
