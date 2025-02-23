#!/usr/bin/env bash
set -Eeu

readonly ROOT_DIR="$(cd "$(dirname "${0}")/.." && pwd)"
source "${ROOT_DIR}/sh/lib.sh"


# - - - - - - - - - - - - - - - - - - - - - - - -
image_sha()
{
  docker run --rm --entrypoint "" $(image_name):latest sh -c 'echo ${SHA}'
}

# - - - - - - - - - - - - - - - - - - - - - - - -
image_tag()
{
  local -r sha="$(image_sha)"
  echo "${sha:0:7}"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
release()
{
  [[ "$(git_commit_msg)" =~ RELEASE=([0-9]*.[0-9]*.[0-9]*) ]] \
     && echo ${BASH_REMATCH[1]}
}

# - - - - - - - - - - - - - - - - - - - - - - - -
image_release()
{
  docker --log-level=ERRROR run --rm --entrypoint="" $(image_name):latest sh -c 'echo ${RELEASE}'
}

# - - - - - - - - - - - - - - - - - - - - - - - -
assert_equal()
{
  local -r expected="${1}"
  local -r actual="${2}"
  echo "expected: '${expected}'"
  echo "  actual: '${actual}'"
  if [ "${expected}" != "${actual}" ]; then
    echo "ERROR: inside image $(image_name):latest"
    exit 42
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - -
tag_the_image()
{
  docker tag $(image_name):latest $(image_name):$(image_tag)
  if [ -n "$(image_release)" ]; then
    docker tag $(image_name):latest $(image_name):$(image_release)
  else
    docker tag $(image_name):latest $(image_name):dev_latest
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - -
on_CI()
{
  [ "${CI:-}" == true ]
}

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci_publish_tagged_images()
{
  if ! on_CI; then
    echo 'not in CI Workflow so not publishing image'
    return
  fi
  echo 'on CI Workflow so publishing image'
  echo "${DOCKER_PASS}" | docker login --username "${DOCKER_USER}" --password-stdin
  docker push $(image_name):$(image_tag)
  if [ -n "$(image_release)" ]; then
    docker push $(image_name):$(image_release)
    docker push $(image_name):latest
  else
    # TODO: still used? in commander?
    docker push $(image_name):dev_latest
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci_publish_tagged_images
