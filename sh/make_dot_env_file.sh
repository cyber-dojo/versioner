#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/sh/lib.sh"
exit_non_zero_unless_installed jq

# Script to create .env file content by inspecting json files
#
# Use: $ make dot_env_file
# Use: $ ./sh/make_dot_env_file.sh

echo_env()
{
  local -r service="${1}"
  local -r filename="${service}.json"
  local -r prefix="CYBER_DOJO_$(upper_case "${service}")"
  local -r json="$(cat "${ROOT_DIR}/app/json/${filename}")"
  local -r sha="$(echo "${json}" | jq -r '.sha')"
  local -r tag="$(echo "${json}" | jq -r '.tag')"
  local -r digest="$(echo "${json}" | jq -r '.digest')"
  local -r port="$(echo "${json}" | jq -r '.port')"

  echo
  echo "${prefix}_IMAGE=cyberdojo/${service}"
  echo "${prefix}_SHA=${sha}"
  echo "${prefix}_TAG=${tag}"
  echo "${prefix}_DIGEST=${digest}"
  if [ "${port}" != "0" ]; then
    echo "${prefix}_PORT=${port}"
  fi
}

upper_case()
{
  printf "${1}" | tr [a-z] [A-Z] | tr [\\-] [_]
}

readonly services=(
  commander
  start-points-base
  custom-start-points
  exercises-start-points
  languages-start-points
  creator
  dashboard
  differ
  nginx
  runner
  saver
  web
)

create_env_file()
{
  echo Creating .env file
  dot_env_filename="${ROOT_DIR}/app/.env"
  rm "${dot_env_filename}" 2> /dev/null || true
  for service in "${services[@]}"
  do
    echo_env "${service}" >> "${dot_env_filename}"
  done
}

create_env_file

# Debug
set +e
ls -al "${ROOT_DIR}/app/json/"
cat "${ROOT_DIR}/app/json/custom-start-points.json"
json="$(cat "${ROOT_DIR}/app/json/custom-start-points.json")"
tag="$(echo "${json}" | jq -r '.tag')"
digest="$(echo "${json}" | jq -r '.digest')"
image_name="cyberdojo/custom-start-points:${tag}@sha26:${digest}"
echo "${image_name}"
docker pull "${image_name}"
set -e

echo '-------------------------------'
cat "${dot_env_filename}"
echo '-------------------------------'

