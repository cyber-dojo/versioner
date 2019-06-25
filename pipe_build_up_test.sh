#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && pwd )"

export GIT_COMMIT_MSG=$(cd ${ROOT_DIR} && git log --oneline --format=%B -n 1 HEAD | head -n 1)

if ${ROOT_DIR}/sh/is-release-commit.sh; then
  export RELEASE=$(${ROOT_DIR}/sh/echo-commit-release.sh)
fi

"${ROOT_DIR}/sh/build_docker_images.sh"
"${ROOT_DIR}/test/run.sh"
