#!/bin/bash
set -e

# Script to create .env.md as a hyperlinked version of .env
# Use
# $ ./sh/latest-env-md.sh > .env.md
# Used by .git/hooks/pre-push

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
  local -r name="$(cel_var ${1})"
  echo ${!name}
}

cel_sha()
{
  sha $(cel_value $1)
}

cel_url()
{
  echo "https://github.com/cyber-dojo/${2}/commit/$(cel_sha ${1})"
}

cel_env_var()
{
  echo "$(cel_var ${1})=[$(cel_value ${1})]($(cel_url ${1} ${2}))<br/>"
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
  echo "CYBER_DOJO_$(upper_case "${1}")_IMAGE=[cyberdojo/${1}](https://hub.docker.com/r/cyberdojo/${1}/tags)"
  echo "$(sha_var ${1})=[$(sha_value ${1})]($(sha_url ${1}))<br/>"
  echo "$(tag_var ${1})=$(tag_value ${1})<br/>"
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

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
tag_var()
{
  echo "CYBER_DOJO_$(upper_case "${1}")_TAG"
}

tag_value()
{
  local name=$(sha_var ${1})
  echo ${!name:0:7}
}

tag_url()
{
  local -r name=$(echo ${1} | tr '_' '-')
  echo "https://hub.docker.com/r/cyberdojo/${name}/tags"
}

tag_env_var()
{
  echo "$(tag_var ${1})=[$(tag_value ${1})]($(tag_url ${1}))<br/>"
}

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
cel_env_var custom    custom-start-points
cel_env_var exercises exercises-start-points
cel_env_var languages languages-start-points-common
echo
echo '### Default port used in: $ cyber-dojo up'
echo
echo "CYBER_DOJO_PORT=${CYBER_DOJO_PORT}<br/>"
echo
echo '### HTTP web services used in: $ cyber-dojo up'
echo
for svc in "${services[@]}";
do
  sha_env_var ${svc}
  echo
done
