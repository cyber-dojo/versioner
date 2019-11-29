#!/bin/bash
set -e

# Script to create .env.md as a hyperlinked version of .env
# Used by .git/hooks/pre-push
# which tells you to run
# $ ./sh/create-env-md.sh > .env.md

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
. "${ROOT_DIR}/.env"

# ---------------------------------------------------

sha()
{
  docker run --rm ${1} sh -c 'echo -n ${SHA}'
}

cel_var()
{
  local -r upper=$(echo ${1} | tr [a-z] [A-Z])
   echo "CYBER_DOJO_${upper}"
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

# ---------------------------------------------------

sha_var()
{
  local -r upper=$(echo ${1} | tr [a-z] [A-Z])
  echo "CYBER_DOJO_${upper}_SHA"
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
  if [ "${1}" == 'web' ]; then
    echo "CYBER_DOJO_WEB_IMAGE=cyberdojo/web"
  fi
  if [ "${1}" == 'nginx' ]; then
    echo "CYBER_DOJO_NGINX_IMAGE=cyberdojo/nginx"
  fi
  echo "$(sha_var ${1})=[$(sha_value ${1})]($(sha_url ${1}))<br/>"
  echo "$(tag_var ${1})=$(tag_value ${1})<br/>"
}

# ---------------------------------------------------

tag_var()
{
  local -r upper=$(echo ${1} | tr [a-z] [A-Z])
  echo "CYBER_DOJO_${upper}_TAG"
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
  custom
  exercises
  languages
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

echo '### $ cyber-dojo bash commands delegate to commander'
echo
sha_env_var commander
echo
echo '### Base image tag used in: $ cyber-dojo start-point create'
echo
sha_env_var starter_base
echo
echo
echo '### Default ports used in: $ cyber-dojo start-point create'
echo
echo 'CYBER_DOJO_CUSTOM_PORT=4526'
echo 'CYBER_DOJO_EXERCISES_PORT=4525'
echo 'CYBER_DOJO_LANGUAGES_PORT=4524'
echo 
echo '### Default start-points images used in: $ cyber-dojo up'
echo
cel_env_var custom     custom
cel_env_var exercises  exercises
cel_env_var languages  languages-common
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
