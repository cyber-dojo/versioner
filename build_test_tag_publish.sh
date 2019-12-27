#!/bin/bash
set -e

readonly IMAGE=cyberdojo/versioner
readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && pwd )"

# - - - - - - - - - - - - - - - - - - - - - - - -
build_image()
{
  docker build \
    --build-arg SHA="$(git_commit_sha)" \
    --build-arg RELEASE="$(release)" \
    --tag ${IMAGE}:latest \
    "${ROOT_DIR}/app"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
git_commit_sha()
{
  echo $(cd "${ROOT_DIR}" \
    && git rev-parse HEAD)
}

git_commit_msg()
{
  echo $(cd ${ROOT_DIR} \
    && git log --oneline --format=%B -n 1 HEAD | head -n 1)
}

image_sha()
{
  docker run --rm ${IMAGE}:latest sh -c 'echo ${SHA}'
}

# - - - - - - - - - - - - - - - - - - - - - - - -
release()
{
  [[ "$(git_commit_msg)" =~ RELEASE=([0-9]*.[0-9]*.[0-9]*) ]] \
     && echo ${BASH_REMATCH[1]}
}

image_release()
{
  docker run --rm ${IMAGE}:latest sh -c 'echo ${RELEASE}'
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
tag_the_image()
{
  local -r SHA="$(image_sha)"
  local -r RELEASE="$(image_release)"
  docker tag ${IMAGE}:latest ${IMAGE}:${SHA:0:7}
  if [ "${RELEASE}" != "" ]; then
    docker tag ${IMAGE}:latest ${IMAGE}:${RELEASE}
  else
    docker tag ${IMAGE}:latest ${IMAGE}:dev_latest
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci_publish_tagged_images()
{
  if [ -z "${CIRCLECI}" ]; then
    echo 'not on CI so not publishing tagged images'
    return
  fi
  echo 'on CI so publishing tagged images'
  # requires DOCKER_USER, DOCKER_PASS in ci context
  local -r SHA="$(image_sha)"
  local -r RELEASE="$(image_release)"
  echo "${DOCKER_PASS}" | docker login --username "${DOCKER_USER}" --password-stdin
  docker push ${IMAGE}:${SHA:0:7}
  if [ "${RELEASE}" != "" ]; then
    docker push ${IMAGE}:${RELEASE}
    docker push ${IMAGE}:latest
  else
    # TODO: still used? in commander?
    docker push ${IMAGE}:dev_latest
  fi
  docker logout
}

# - - - - - - - - - - - - - - - - - - - - - - - -
build_image
assert_equal SHA     "$(git_commit_sha)" "$(image_sha)"
assert_equal RELEASE "$(release)"        "$(image_release)"
tag_the_image
if [ "${1}" != '--no-test' ]; then
  ${ROOT_DIR}/test/run_all.sh
fi
on_ci_publish_tagged_images
