#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/bin/lib.sh"
exit_non_zero_unless_installed jq

# Script to create .env.md file content by inspecting json files
#
# Use: $ make dot_env_md_file
# Use: $ ./sh/make_dot_env_md_file.sh

echo_env_md()
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
  echo_md "${prefix}_IMAGE=cyberdojo/${service}"
  if [ "${service}" == "creator" ]; then
    local -r sha_url="https://gitlab.com/cyber-dojo/${service}/-/commit/${sha}"
  else
    local -r sha_url="https://github.com/cyber-dojo/${service}/commit/${sha}"
  fi
  echo_md "${prefix}_SHA=[${sha}](${sha_url})"
  echo_md "${prefix}_TAG=${tag}"
  echo_md "${prefix}_DIGEST=[${digest}](https://hub.docker.com/layers/cyberdojo/${service}/${tag}/images/sha256-${digest})"
  if [ "${port}" != "0" ]; then
    echo_md "${prefix}_PORT=${port}"
  fi
}

upper_case()
{
  printf "%s" "${1}" | tr [a-z] [A-Z] | tr [\\-] [_]
}

echo_md()
{
  local -r line="${1}"
  local -r two_spaces="  "
  echo "${line}${two_spaces}"
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

create_env_md()
{
  echo Creating .env.md file
  dot_env_md_filename="${ROOT_DIR}/app/.env.md"
  rm "${dot_env_md_filename}" 2> /dev/null || true
  for service in "${services[@]}"
  do
    echo_env_md "${service}" >> "${dot_env_md_filename}"
  done
}

create_env_md

