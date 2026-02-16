#!/usr/bin/env bash
set -Eeu

# Builds a fake cyberdojo/versioner:latest image that serves
# CYBER_DOJO_XXXX SHA/TAG values for local images

readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TMP_DIR="$(mktemp -d /tmp/XXXXXXX)"
remove_TMP_DIR() { rm -rf "${TMP_DIR} > /dev/null"; }
trap remove_TMP_DIR INT EXIT

function echo_env_vars() 
{ 
  docker --log-level=ERROR run --rm cyberdojo/versioner:latest
}

function build_fake_versioner_with_sha_and_tag_for_local_dev()
{
  local env_vars="$(echo_env_vars)"

  # Repeat these 6 lines for each service
  local sha_var_name=CYBER_DOJO_RUNNER_SHA
  local tag_var_name=CYBER_DOJO_RUNNER_TAG
  local fake_sha=cf7cd4a9999e6343d871a24a56fb079415437be0
  local fake_tag="${fake_sha:0:7}"
  env_vars=$(replace_with "${env_vars}" "${sha_var_name}" "${fake_sha}")
  env_vars=$(replace_with "${env_vars}" "${tag_var_name}" "${fake_tag}")

  # Now recreate .env
  echo "${env_vars}" > ${TMP_DIR}/.env
  
  local -r fake_image=cyberdojo/versioner:latest
  {
    echo 'FROM alpine:latest'
    echo 'ARG SHA'
    echo 'ENV SHA=${SHA}'
    echo 'ARG RELEASE'
    echo 'ENV RELEASE=${RELEASE}'
    echo 'COPY . /app'
    echo 'ENTRYPOINT [ "cat", "/app/.env" ]'
  } > ${TMP_DIR}/Dockerfile
  
  docker build \
    --build-arg SHA="${fake_sha}" \
    --build-arg RELEASE=999.999.999 \
    --tag "${fake_image}" \
    "${TMP_DIR}"
}

function replace_with()
{
  local -r env_vars="${1}"
  local -r name="${2}"
  local -r fake_value="${3}"
  local -r all_except=$(echo "${env_vars}" | grep --invert-match "${name}")
  printf "${all_except}\n${name}=${fake_value}\n"
}
 
build_fake_versioner_with_sha_and_tag_for_local_dev
