#!/bin/bash -Eeu

# Script to create .env file from pulled :latest images
# Use: $ ./sh/latest-env.sh | tee ./app/.env

readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

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
  echo "CYBER_DOJO_$(upper_case "${1}")_IMAGE=${image}"
  echo "CYBER_DOJO_$(upper_case "${1}")_SHA=${sha}"
  echo "CYBER_DOJO_$(upper_case "${1}")_TAG=${tag}"
  case "${1}" in
  creator   ) echo CYBER_DOJO_CREATOR_PORT=4523;;

  custom-start-points    ) echo CYBER_DOJO_CUSTOM_START_POINTS_PORT=4526;;
  exercises-start-points ) echo CYBER_DOJO_EXERCISES_START_POINTS_PORT=4525;;
  languages-start-points ) echo CYBER_DOJO_LANGUAGES_START_POINTS_PORT=4524;;

  custom-chooser    ) echo CYBER_DOJO_CUSTOM_CHOOSER_PORT=4536;;
  exercises-chooser ) echo CYBER_DOJO_EXERCISES_CHOOSER_PORT=4535;;
  languages-chooser ) echo CYBER_DOJO_LANGUAGES_CHOOSER_PORT=4534;;

  avatars   ) echo CYBER_DOJO_AVATARS_PORT=5027;;
  differ    ) echo CYBER_DOJO_DIFFER_PORT=4567;;
  nginx     ) echo CYBER_DOJO_NGINX_PORT=80;;
  puller    ) echo CYBER_DOJO_PULLER_PORT=5017;;
  runner    ) echo CYBER_DOJO_RUNNER_PORT=4597;;
  saver     ) echo CYBER_DOJO_SAVER_PORT=4537;;
  web       ) echo CYBER_DOJO_WEB_PORT=3000;;
  zipper    ) echo CYBER_DOJO_ZIPPER_PORT=4587;;
  esac
}

# ---------------------------------------------------
readonly services=(
  commander
  start-points-base
  custom-start-points
  exercises-start-points
  languages-start-points
  custom-chooser
  exercises-chooser
  languages-chooser
  avatars
  creator
  differ
  nginx
  puller
  runner
  saver
  web
)

# ---------------------------------------------------
echo
for service in "${services[@]}"
do
  sha_env_var "${service}"
  echo
done
