#!/bin/bash
set -e

# Script to create .env file from pulled :latest images
# Use: $ ./sh/latest-env.sh | tee .env

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

upper_case() { printf "${1}" | tr [a-z] [A-Z] | tr [\\-] [_]; }

# ---------------------------------------------------
untagged_image_name()
{
  if [ "${1}" == 'languages-start-points' ]; then
    local -r name='languages-start-points-common'
  else
    local -r name="${1}"
  fi
  echo "cyberdojo/${name}"
}

# ---------------------------------------------------
docker_image_pull()
{
  local -r image="${1}"
  docker pull "${image}" > /dev/null 2>&1
}

# ---------------------------------------------------
service_sha()
{
  local -r image="${1}"
  docker run --rm --entrypoint="" "${image}" sh -c 'echo -n ${SHA}'
}

service_base_sha()
{
  local -r image="${1}"
  docker run --rm --entrypoint="" "${image}" sh -c 'echo -n ${BASE_SHA}'
}

# ---------------------------------------------------
sha_env_var()
{
  local -r image=$(untagged_image_name "${1}")
  docker_image_pull "${image}"
  if [ "${1}" == 'start-points-base' ]; then
    local -r sha=$(service_base_sha "${image}")
  else
    local -r sha=$(service_sha "${image}")
  fi
  local -r tag=${sha:0:7}
  printf "CYBER_DOJO_$(upper_case "${1}")_IMAGE=${image}\n"
  printf "CYBER_DOJO_$(upper_case "${1}")_SHA=${sha}\n"
  printf "CYBER_DOJO_$(upper_case "${1}")_TAG=${tag}\n"
  case "${1}" in
  creator   ) printf 'CYBER_DOJO_CREATOR_PORT=4523\n';;

  custom    ) printf 'CYBER_DOJO_CUSTOM_PORT=4536\n';;
  exercises ) printf 'CYBER_DOJO_EXERCISES_PORT=4535\n';;
  languages ) printf 'CYBER_DOJO_LANGUAGES_PORT=4534\n';;

  custom-start-points    ) printf 'CYBER_DOJO_CUSTOM_START_POINTS_PORT=4526\n';;
  exercises-start-points ) printf 'CYBER_DOJO_EXERCISES_START_POINTS_PORT=4525\n';;
  languages-start-points ) printf 'CYBER_DOJO_LANGUAGES_START_POINTS_PORT=4524\n';;

  avatars   ) printf 'CYBER_DOJO_AVATARS_PORT=5027\n';;
  differ    ) printf 'CYBER_DOJO_DIFFER_PORT=4567\n';;
  nginx     ) printf 'CYBER_DOJO_NGINX_PORT=80\n';;
  puller    ) printf 'CYBER_DOJO_PULLER_PORT=5017\n';;
  ragger    ) printf 'CYBER_DOJO_RAGGER_PORT=5537\n';;
  runner    ) printf 'CYBER_DOJO_RUNNER_PORT=4597\n';;
  saver     ) printf 'CYBER_DOJO_SAVER_PORT=4537\n';;
  web       ) printf 'CYBER_DOJO_WEB_PORT=3000\n';;
  zipper    ) printf 'CYBER_DOJO_ZIPPER_PORT=4587\n';;
  esac
}

# ---------------------------------------------------
readonly services=(
  commander
  start-points-base
  custom-start-points
  exercises-start-points
  languages-start-points
  #creator
  #custom
  #exercises
  #languages
  avatars
  differ
  nginx
  puller
  ragger
  runner
  saver
  web
  zipper
)

# ---------------------------------------------------
printf '\n'
for service in "${services[@]}";
do
  sha_env_var "${service}"
  printf '\n'
done
