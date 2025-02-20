#!/usr/bin/env bash
set -Eeu

# Script to create new .env file by reading information from the :latest Artifact of each service.

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

${ROOT_DIR}/sh/artifact-latest-env.sh    | tee ${ROOT_DIR}/app/.env
if [ "${PIPESTATUS[0]}" != '0' ]; then
  exit 42
fi

${ROOT_DIR}/sh/artifact-latest-env-md.sh | tee ${ROOT_DIR}/app/.env.md
if [ "${PIPESTATUS[0]}" != '0' ]; then
  exit 42
fi
