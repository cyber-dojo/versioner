#!/usr/bin/env bash
set -Eeu

# Script to push images in AWS ECR to dockerhub

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
push_dockerhub_image()
{
  local -r service="${1}"                              # eg dashboard
  local -r filename="${service}.json"
  local -r json="$(cat "${ROOT_DIR}/app/json/${filename}")"
  local -r image="$(echo "${json}" | jq -r '.image')"  # eg 244531986313.dkr.ecr.eu-central-1.amazonaws.com/dashboard:550c13b@sha256:8fed4e81b299d4cd1478ca30375463b4fab7465831ae6c2fcb8ce226a5ce94b3
  local -r tag="$(echo "${json}" | jq -r '.tag')"      # eg 550c13b

  local -r tagged_image="cyberdojo/${service}:${tag}"  # eg cyberdojo/dashboard:550c13b
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
