#!/usr/bin/env bash
set -Eeu

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && pwd )"

# - - - - - - - - - - - - - - - - - - - - - - - -
image_name()
{
  echo cyberdojo/versioner
}

# - - - - - - - - - - - - - - - - - - - - - - - -
build_image()
{
  docker build \
    --build-arg SHA="$(git_commit_sha)" \
    --build-arg RELEASE="$(release)" \
    --tag $(image_name):latest \
    "${ROOT_DIR}/app"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
git_commit_sha()
{
  cd "${ROOT_DIR}" && git rev-parse HEAD
}

# - - - - - - - - - - - - - - - - - - - - - - - -
git_commit_msg()
{
  cd ${ROOT_DIR} && git log --oneline --format=%B -n 1 HEAD | head -n 1
}

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
  docker run --rm --entrypoint "" $(image_name):latest sh -c 'echo ${RELEASE}'
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
    echo 'not on CI so not publishing tagged images'
    return
  fi
  echo 'on CI so publishing tagged images'
  echo "${DOCKER_PASS}" | docker login --username "${DOCKER_USER}" --password-stdin
  docker push $(image_name):$(image_tag)
  if [ -n "$(image_release)" ]; then
    docker push $(image_name):$(image_release)
    docker push $(image_name):latest
  else
    # TODO: still used? in commander?
    docker push $(image_name):dev_latest
  fi
  docker logout
}

# - - - - - - - - - - - - - - - - - - - - - - - -
build_image
assert_equal "SHA=$(git_commit_sha)" "SHA=$(image_sha)"
assert_equal "RELEASE=$(release)"    "RELEASE=$(image_release)"
tag_the_image
if [ "${1:-}" == '--build-only' ] || [ "${1:-}" == '-bo' ] ; then
  exit 0
fi
${ROOT_DIR}/test/run_all.sh
on_ci_publish_tagged_images
