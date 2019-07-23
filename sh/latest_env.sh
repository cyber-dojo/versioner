#!/bin/bash
set -e

# Script to create .env file from :latest images
# Intended use:
#   $ ./sh/latest_env.sh | tee .env
#   $ ./sh/create-env-md.sh > .env.md

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

# ---------------------------------------------------

docker_pull_quiet()
{
  docker pull ${1} > /dev/null 2>&1
}

# ---------------------------------------------------

start_point_env_var()
{
  local -r env_var_name="CYBER_DOJO_${1}"     # eg CYBER_DOJO_CUSTOM
  local -r image_name="cyberdojo/${2}:latest" # eg cyberdojo/custom:latest
  docker_pull_quiet ${image_name}
  local -r sha=$(docker run --rm --entrypoint="" ${image_name} sh -c 'echo -n ${SHA}')
  local -r tag=${sha:0:7}
  echo "${env_var_name}=cyberdojo/${2}:${tag}"
}

# ---------------------------------------------------

service_env_var()
{
  local -r upper=$(echo ${1} | tr [a-z] [A-Z])
  local -r env_var_name="CYBER_DOJO_${upper}_SHA" # eg CYBER_DOJO_WEB_SHA
  local -r image_name="cyberdojo/${1}:latest"     # eg cyberdojo/web:latest
  docker_pull_quiet ${image_name}
  local -r sha=$(docker run --rm --entrypoint="" ${image_name} sh -c 'echo -n ${SHA}')
  echo "${env_var_name}=${sha}"
}

# ---------------------------------------------------

starter_base_env_var()
{
  local -r env_var_name="CYBER_DOJO_STARTER_BASE_SHA"
  local -r image_name="cyberdojo/starter-base:latest"
  docker_pull_quiet ${image_name}
  local -r base_sha=$(docker run --rm --entrypoint="" ${image_name} sh -c 'echo -n ${BASE_SHA}')
  echo "${env_var_name}=${base_sha}"
}

# ---------------------------------------------------

readonly services=(
  commander
  differ
  mapper
  nginx
  ragger
  runner
  saver
  web
  zipper
)

# ---------------------------------------------------

echo
echo "CYBER_DOJO_PORT=80"

echo
start_point_env_var CUSTOM    custom
start_point_env_var EXERCISES exercises
start_point_env_var LANGUAGES languages-common

echo
starter_base_env_var

echo
for service in "${services[@]}";
do
  service_env_var ${service}
done
