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
custom_env_var()
{
  local -r sha_env_var_name="CYBER_DOJO_CUSTOM_SHA"
  local -r tag_env_var_name="CYBER_DOJO_CUSTOM_TAG"
  docker_image_pull custom
  local -r sha=$(service_sha custom)
  local -r tag=${sha:0:7}
  echo "${sha_env_var_name}=${sha}"
  echo "${tag_env_var_name}=${tag}"
}

# ---------------------------------------------------
exercises_env_var()
{
  local -r sha_env_var_name="CYBER_DOJO_EXERCISES_SHA"
  local -r tag_env_var_name="CYBER_DOJO_EXERCISES_TAG"
  docker_image_pull exercises
  local -r sha=$(service_sha exercises)
  local -r tag=${sha:0:7}
  echo "${sha_env_var_name}=${sha}"
  echo "${tag_env_var_name}=${tag}"
}

# ---------------------------------------------------
languages_env_var()
{
  local -r sha_env_var_name="CYBER_DOJO_LANGUAGES_SHA"
  local -r tag_env_var_name="CYBER_DOJO_LANGUAGES_TAG"
  docker_image_pull languages-common
  local -r sha=$(service_sha languages-common)
  local -r tag=${sha:0:7}
  echo "${sha_env_var_name}=${sha}"
  echo "${tag_env_var_name}=${tag}"
}

# ---------------------------------------------------
sha_env_var()
{
  docker_image_pull ${1}
  sha_env_var_name="CYBER_DOJO_$(upper_case $1)_SHA" # eg CYBER_DOJO_WEB_SHA
  tag_env_var_name="CYBER_DOJO_$(upper_case $1)_TAG" # eg CYBER_DOJO_WEB_TAG
  sha=$(service_sha $1)
  tag=${sha:0:7}
  if [ "${1}" == 'web' ]; then
    echo 'CYBER_DOJO_WEB_IMAGE=cyberdojo/web'
  fi
  if [ "${1}" == 'nginx' ]; then
    echo 'CYBER_DOJO_NGINX_IMAGE=cyberdojo/nginx'
  fi
  echo "${sha_env_var_name}=${sha}"
  echo "${tag_env_var_name}=${tag}"
}

# ---------------------------------------------------
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

# ---------------------------------------------------

echo
sha_env_var commander
echo
starter_base_env_var
echo
echo 'CYBER_DOJO_CUSTOM_PORT=4526'
echo 'CYBER_DOJO_EXERCISES_PORT=4525'
echo 'CYBER_DOJO_LANGUAGES_PORT=4524'
echo
start_point_env_var CUSTOM    custom-start-points
start_point_env_var EXERCISES exercises-start-points
start_point_env_var LANGUAGES languages-common
echo
echo "CYBER_DOJO_PORT=80"
echo
for service in "${services[@]}";
do
  sha_env_var ${service}
  echo
done
