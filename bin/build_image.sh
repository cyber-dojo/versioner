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
  # Captured once: each runs a container to read an env-var out of the image.
  local -r tag="$(image_tag)"
  local -r rel="$(image_release)"
  local versioned_tag
  if [ -n "${rel}" ]; then
    versioned_tag="${rel}"
  else
    versioned_tag=dev_latest
  fi
  docker tag $(image_name):latest $(image_name):"${tag}"
  docker tag $(image_name):latest $(image_name):"${versioned_tag}"
  # After tagging, so removing an earlier build's tags takes its last tag with
  # them and the image itself goes, rather than being left dangling when
  # :latest moves to this build.
  remove_old_images "${tag}" "${versioned_tag}"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
build_image
assert_equal "SHA=$(git_commit_sha)" "SHA=$(image_sha)"
assert_equal "RELEASE=$(release)"    "RELEASE=$(image_release)"
tag_the_image
