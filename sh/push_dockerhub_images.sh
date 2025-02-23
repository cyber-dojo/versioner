#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
push_dockerhub_image()
{
  local -r service="${1}"
  local -r filename="${service}.json"
  local -r json="$(cat "${ROOT_DIR}/app/json/${filename}")"
  local -r image="$(echo "${json}" | jq -r '.image')"
  local -r tag="$(echo "${json}" | jq -r '.tag')"

  local -r tagged_image="cyberdojo/${service}:${tag}"
  echo "  Creating ${tagged_image}"
  docker pull "${image}"
  docker tag "${image}" "${tagged_image}"
  docker push "${tagged_image}"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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

echo Create Dockerhub Images
for service in "${services[@]}"
do
  push_dockerhub_image "${service}"
done
