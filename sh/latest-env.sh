#!/bin/bash
set -e

# Script to create .env file from :latest images
# Use:
#   $ ./sh/latest-env.sh | tee .env

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

upper_case() { printf "${1}" | tr [a-z] [A-Z]; }

# ---------------------------------------------------
cd_image_name()
{
  local -r name="${1}"
  local -r tag="${2:-latest}"
  printf "cyberdojo/${name}:${tag}\n"
}

# ---------------------------------------------------
docker_image_pull()
{
  docker pull $(cd_image_name "${1}") > /dev/null 2>&1
}

# ---------------------------------------------------
service_sha()
{
  docker run --rm --entrypoint="" $(cd_image_name "${1}") sh -c 'echo -n ${SHA}'
}

# ---------------------------------------------------
start_point_env_var()
{
  local -r cep="${1}"       # custom|exercises|languages
  docker_image_pull "${2}"  # eg custom-start-points
  local -r sha=$(service_sha "${2}")
  local -r tag=${sha:0:7}
  printf "CYBER_DOJO_${1}=$(cd_image_name "${2}" "${tag}")\n"
}

# ---------------------------------------------------
start_points_base_env_var()
{
  docker_image_pull start-points-base
  local -r sha=$(service_base_sha start-points-base)
  local -r tag=${sha:0:7}
  printf 'CYBER_DOJO_START_POINTS_BASE_IMAGE=cyberdojo/start-points-base\n'
  printf "CYBER_DOJO_START_POINTS_BASE_SHA=${sha}\n"
  printf "CYBER_DOJO_START_POINTS_BASE_TAG=${tag}\n"
}

service_base_sha()
{
  docker run --rm --entrypoint="" $(cd_image_name "${1}") sh -c 'echo -n ${BASE_SHA}'
}

# ---------------------------------------------------
sha_env_var()
{
  docker_image_pull "${1}"
  local -r sha=$(service_sha "${1}")
  local -r tag=${sha:0:7}
  printf "CYBER_DOJO_$(upper_case "${1}")_IMAGE=cyberdojo/${1}\n"
  printf "CYBER_DOJO_$(upper_case "${1}")_SHA=${sha}\n"
  printf "CYBER_DOJO_$(upper_case "${1}")_TAG=${tag}\n"
  case "${1}" in
  creator   ) printf 'CYBER_DOJO_CREATOR_PORT=4523\n';;
  custom    ) printf 'CYBER_DOJO_CUSTOM_PORT=4536\n';;
  exercises ) printf 'CYBER_DOJO_EXERCISES_PORT=4535\n';;
  languages ) printf 'CYBER_DOJO_LANGUAGES_PORT=4534\n';;
  avatars   ) printf 'CYBER_DOJO_AVATARS_PORT=5027\n';;
  differ    ) printf 'CYBER_DOJO_DIFFER_PORT=4567\n';;
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
sha_env_var commander
printf '\n'
start_points_base_env_var
printf '\n'
start_point_env_var CUSTOM    custom-start-points
start_point_env_var EXERCISES exercises-start-points
start_point_env_var LANGUAGES languages-start-points-common
printf '\n'
printf 'CYBER_DOJO_PORT=80\n'
printf '\n'
for service in "${services[@]}";
do
  sha_env_var "${service}"
  printf '\n'
done
