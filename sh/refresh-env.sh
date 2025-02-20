#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

${ROOT_DIR}/sh/artifact-refresh-env.sh
#${ROOT_DIR}/sh/service-refresh-env.sh
