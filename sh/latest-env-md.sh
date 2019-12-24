#!/bin/bash
set -e

# Script to create .env.md as a hyperlinked version of .env
# Used by .git/hooks/pre-push
# Use: $ ./sh/latest-env-md.sh | tee .env.md

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
source "${ROOT_DIR}/.env"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
upper_case() { printf "${1}" | tr [a-z] [A-Z] | tr [\\-] [_]; }

sha()
{
  docker run --rm ${1} sh -c 'echo -n ${SHA}'
}

cel_var()
{
  echo "CYBER_DOJO_$(upper_case "${1}")"
}

cel_value()
{
  local -r name="${1}"
  local -r env_var_name="$(cel_var ${name})"
  echo ${!env_var_name}
}

cel_sha()
{
  local -r name="${1}" # eg languages-start-points
  sha $(cel_value "${name}")
}

cel_url()
{
  local -r name="${1}" # eg languages-start-points
  echo "https://github.com/cyber-dojo/${name}/commit/$(cel_sha ${name})"
}

cel_env_var()
{
  local -r name="${1}"  # eg languages-start-points
  echo "$(cel_var "${name}")=[$(cel_value "${name}")]($(cel_url "${name}"))<br/>"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sha_var()
{
  echo "CYBER_DOJO_$(upper_case "${1}")_SHA"
}

sha_value()
{
  local name=$(sha_var ${1})
  echo ${!name}
}

sha_url()
{
  local -r sha=$(sha_value ${1})
  local -r name=$(echo ${1} | tr '_' '-')
  echo "https://github.com/cyber-dojo/${name}/commit/${sha}"
}

sha_env_var()
{
  if [ "${1}" == 'languages-start-points' ]; then
    local -r name=languages-start-points-common
  else
    local -r name="${1}"
  fi
  echo "CYBER_DOJO_$(upper_case "${1}")_IMAGE=cyberdojo/${name}"
  echo "$(sha_var ${1})=[$(sha_value ${1})]($(sha_url ${1}))<br/>"
  echo "$(tag_var ${1})=[$(tag_value ${1})]($(tag_url ${1}))<br/>"
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
  nginx     ) printf 'CYBER_DOJO_NGINX_PORT=80 # Default in: $ cyber-dojo up\n';;
  puller    ) printf 'CYBER_DOJO_PULLER_PORT=5017\n';;
  ragger    ) printf 'CYBER_DOJO_RAGGER_PORT=5537\n';;
  runner    ) printf 'CYBER_DOJO_RUNNER_PORT=4597\n';;
  saver     ) printf 'CYBER_DOJO_SAVER_PORT=4537\n';;
  web       ) printf 'CYBER_DOJO_WEB_PORT=3000\n';;
  zipper    ) printf 'CYBER_DOJO_ZIPPER_PORT=4587\n';;
  esac
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
tag_var()
{
  echo "CYBER_DOJO_$(upper_case "${1}")_TAG"
}

tag_value()
{
  local name=$(tag_var ${1})
  echo ${!name:0:7}
}

tag_url()
{
  if [ "${1}" == 'languages-start-points' ]; then
    local -r name=languages-start-points-common
  else
    local -r name="${1}" # eg runner
  fi
  # Relies on :latest being pulled in latest-env.sh
  local -r tag="$(tag_value ${1})"
  local digest=$(docker inspect --format='{{index .RepoDigests 0}}' cyberdojo/${name}:latest)
  echo "https://hub.docker.com/layers/cyberdojo/${name}/${tag}/images/sha256-${digest:(-64)}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
readonly services=(
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

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
echo '### $ cyber-dojo commands delegate to commander'
echo
sha_env_var commander
echo
echo '### Base image tag used in: $ cyber-dojo start-point create'
echo
sha_env_var start-points-base
echo
echo '### Default start-points images used in: $ cyber-dojo up'
echo
cel_env_var custom-start-points
cel_env_var exercises-start-points
cel_env_var languages-start-points
echo
echo '### HTTP web services used in: $ cyber-dojo up'
echo
for svc in "${services[@]}";
do
  sha_env_var ${svc}
  echo
done
