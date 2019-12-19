#!/bin/bash
set -e

readonly IMAGE=cyberdojo/versioner
readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

# - - - - - - - - - - - - - - - - - - - - - - - -
build_image()
{
  docker build \
    --build-arg SHA="$(git_commit_sha)" \
    --build-arg RELEASE="$(release)" \
    --tag ${IMAGE}:latest \
    "${ROOT_DIR}"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
git_commit_sha()
{
  echo $(cd "${ROOT_DIR}" && git rev-parse HEAD)
}

git_commit_msg()
{
  echo $(cd ${ROOT_DIR} && git log --oneline --format=%B -n 1 HEAD | head -n 1)
}

image_sha()
{
  docker run --rm ${IMAGE}:latest sh -c 'echo ${SHA}'
}

# - - - - - - - - - - - - - - - - - - - - - - - -
release()
{
  local -r SCRIPT=puts-commit-release.rb
  docker run \
    --rm \
    --env GIT_COMMIT_MSG="$(git_commit_msg)" \
    --volume ${ROOT_DIR}/sh/${SCRIPT}:/app/${SCRIPT} \
    cyberdojo/ruby-base:latest \
      /app/${SCRIPT}
}

image_release()
{
  docker run --rm ${IMAGE}:latest sh -c 'echo ${RELEASE}'
}

# - - - - - - - - - - - - - - - - - - - - - - - -
tag_image()
{
  local -r SHA="$(git_commit_sha)"
  docker tag ${IMAGE}:latest ${IMAGE}:${SHA:0:7}
}

# - - - - - - - - - - - - - - - - - - - - - - - -
assert_equal()
{
  local -r name="${1}"
  local -r expected="${2}"
  local -r actual="${3}"
  echo "expected: ${name}='${expected}'"
  echo "  actual: ${name}='${actual}'"
  if [ "${expected}" != "${actual}" ]; then
    echo "ERROR: unexpected ${name} inside image ${IMAGE}:latest"
    exit 42
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - -
run_tests()
{
  "${ROOT_DIR}/test/run.sh"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
build_image
assert_equal SHA     "$(git_commit_sha)" "$(image_sha)"
assert_equal RELEASE "$(release)"        "$(image_release)"
tag_image
