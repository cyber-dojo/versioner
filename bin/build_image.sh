#!/usr/bin/env bash
set -Eeu

readonly ROOT_DIR="$(cd "$(dirname "${0}")/.." && pwd)"
source "${ROOT_DIR}/bin/lib.sh"

# - - - - - - - - - - - - - - - - - - - - - - - -
build_image()
{
  docker build \
    --build-arg SHA="$(git_commit_sha)" \
    --build-arg RELEASE="$(release)" \
    --tag $(image_name):latest \
    "${ROOT_DIR}"
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
  [[ "$(git_commit_msg)" =~ RELEASE=([0-9]*.[0-9]*.[0-9]*) ]] && echo "${BASH_REMATCH[1]}"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
image_release()
{
  docker --log-level=ERROR run --rm --entrypoint "" $(image_name):latest sh -c 'echo ${RELEASE}'
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
build_image
assert_equal "SHA=$(git_commit_sha)" "SHA=$(image_sha)"
assert_equal "RELEASE=$(release)"    "RELEASE=$(image_release)"
tag_the_image
