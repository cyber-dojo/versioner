#!/bin/bash
set -e

# Script to create .env file from :latest images
# Intended use:
#   $ ./sh/latest_env.sh | tee .env
#   $ ./sh/create-env-md.sh > .env.md

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

# ---------------------------------------------------
cd_image_name()
{
  local -r name=${1}
  local -r tag=${2:-latest}
  echo "cyberdojo/${name}:${tag}"
}

# ---------------------------------------------------
docker_image_pull()
{
  docker pull $(cd_image_name $1) > /dev/null 2>&1
}

# ---------------------------------------------------
service_sha()
{
  docker run --rm --entrypoint="" $(cd_image_name $1) sh -c 'echo -n ${SHA}'
}

# ---------------------------------------------------
service_base_sha()
{
  docker run --rm --entrypoint="" $(cd_image_name $1) sh -c 'echo -n ${BASE_SHA}'
}

# ---------------------------------------------------
start_point_env_var()
{
  local -r env_var_name="CYBER_DOJO_${1}" # eg CYBER_DOJO_CUSTOM
  docker_image_pull ${2}
  local -r sha=$(service_sha $2)
  local -r tag=${sha:0:7}
  echo "${env_var_name}=$(cd_image_name $2 ${tag})"
}

# ---------------------------------------------------
upper_case()
{
  echo ${1} | tr [a-z] [A-Z]
}

# ---------------------------------------------------
starter_base_env_var()
{
  local -r sha_env_var_name="CYBER_DOJO_STARTER_BASE_SHA"
  local -r tag_env_var_name="CYBER_DOJO_STARTER_BASE_TAG"
  docker_image_pull starter-base
  local -r sha=$(service_base_sha starter-base)
  local -r tag=${sha:0:7}
  echo "${sha_env_var_name}=${sha}"
  echo "${tag_env_var_name}=${tag}"
}

# ---------------------------------------------------

readonly services=(
  avatars
  commander
  differ
  mapper
  nginx
  puller
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

for service in "${services[@]}";
do
  docker_image_pull $service
  sha_env_var_name="CYBER_DOJO_$(upper_case $service)_SHA" # eg CYBER_DOJO_WEB_SHA
  tag_env_var_name="CYBER_DOJO_$(upper_case $service)_TAG" # eg CYBER_DOJO_WEB_TAG
  sha=$(service_sha $service)
  tag=${sha:0:7}
  echo
  echo "${sha_env_var_name}=${sha}"
  echo "${tag_env_var_name}=${tag}"
done
