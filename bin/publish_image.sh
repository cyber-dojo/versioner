#!/usr/bin/env bash
set -Eeu

readonly ROOT_DIR="$(cd "$(dirname "${0}")/.." && pwd)"
source "${ROOT_DIR}/bin/lib.sh"

# Names the per-platform images that bin/push_platform_image.sh pushed, as
# :<short-sha>-amd64 and :<short-sha>-arm64, in one multi-platform index tagged
# :<short-sha>. A release commit's index is also tagged :<release> and :latest.
# The tag and release come from git, not from a local image, as the job that
# runs this builds nothing.

readonly PLATFORM_SUFFIXES=(amd64 arm64)

image_tag()
{
  local -r sha="$(git_commit_sha)"
  echo "${sha:0:7}"
}

release()
{
  [[ "$(git_commit_msg)" =~ RELEASE=([0-9]*.[0-9]*.[0-9]*) ]]  && echo ${BASH_REMATCH[1]}
}

on_ci_publish_versioner_image()
{
  if ! on_CI; then
    echo 'not in CI Workflow so not publishing versioner image'
    return
  fi
  echo 'in CI Workflow so publishing versioner image'
  local -r tag="$(image_tag)"
  local -r rel="$(release)"
  local -a tags=(--tag "$(image_name):${tag}")
  if [ -n "${rel}" ]; then
    tags+=(--tag "$(image_name):${rel}" --tag "$(image_name):latest")
  fi
  local -a sources=()
  local suffix
  for suffix in "${PLATFORM_SUFFIXES[@]}"; do
    sources+=("$(image_name):${tag}-${suffix}")
  done
  # Workflow has done docker login
  docker buildx imagetools create "${tags[@]}" "${sources[@]}"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci_publish_versioner_image
