#!/usr/bin/env bash
set -Eeu

# Script to create .env file from pulled :latest images
# Use: $ ./sh/latest-env.sh | tee ./app/.env

readonly TMP_DIR=$(mktemp -d ~/tmp.cyber-dojo.versioner.XXXXXX)
remove_tmp_dir() { rm -rf "${TMP_DIR}" > /dev/null; }
trap remove_tmp_dir EXIT

# ---------------------------------------------------
upper_case()
{
  printf "${1}" | tr [a-z] [A-Z] | tr [\\-] [_]
}

# ---------------------------------------------------
untagged_image_name()
{
  local -r name="${1}" # eg runner
  echo "cyberdojo/${name}"
}

# ---------------------------------------------------
docker_image_pull()
{
  local -r image="${1}"
  docker pull "${image}" > /dev/null 2>&1
}

# ---------------------------------------------------
echo_digest()
{
  local -r image="${1}" # eg cyberdojo/runner:latest
  local -r full_name=$(docker inspect --format='{{index .RepoDigests 0}}' "${image}")
  echo "${full_name:(-64)}"
}

# ---------------------------------------------------
service_sha()
{
  local -r image="${1}"
  docker run --rm --entrypoint="" "${image}" sh -c 'echo -n ${SHA}'
}

# ---------------------------------------------------
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
  #local -r full_name="$(docker inspect --format='{{index .RepoDigests 0}}' "${image}")"
  local -r digest="$(echo_digest "${image}")"

  if [ "${1}" == 'start-points-base' ]; then
    local -r sha=$(service_base_sha "${image}")
  else
    local -r sha=$(service_sha "${image}")
  fi
  local -r tag=${sha:0:7}
  echo "CYBER_DOJO_$(upper_case "${1}")_IMAGE=${image}"
  echo "CYBER_DOJO_$(upper_case "${1}")_SHA=${sha}"
  echo "CYBER_DOJO_$(upper_case "${1}")_TAG=${tag}"
  echo "CYBER_DOJO_$(upper_case "${1}")_DIGEST=${digest}"
  case "${1}" in

  custom-start-points    ) echo CYBER_DOJO_CUSTOM_START_POINTS_PORT=4526;;
  exercises-start-points ) echo CYBER_DOJO_EXERCISES_START_POINTS_PORT=4525;;
  languages-start-points ) echo CYBER_DOJO_LANGUAGES_START_POINTS_PORT=4524;;

  creator    ) echo CYBER_DOJO_CREATOR_PORT=4523;;
  dashboard  ) echo CYBER_DOJO_DASHBOARD_PORT=4527;;
  differ     ) echo CYBER_DOJO_DIFFER_PORT=4567;;
  nginx      ) echo CYBER_DOJO_NGINX_PORT=80;;
  runner     ) echo CYBER_DOJO_RUNNER_PORT=4597;;
  saver      ) echo CYBER_DOJO_SAVER_PORT=4537;;
  web        ) echo CYBER_DOJO_WEB_PORT=3000;;
  esac
}

# ---------------------------------------------------
k8s_install_env_var()
{
  git clone "https://github.com/cyber-dojo/k8s-install.git" "${TMP_DIR}" > /dev/null 2>&1
  local -r sha="$(cd ${TMP_DIR} && git rev-parse HEAD)"
  echo "CYBER_DOJO_K8S_INSTALL_SHA=${sha}"
}

# ---------------------------------------------------
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

# ---------------------------------------------------
echo
for service in "${services[@]}"
do
  sha_env_var "${service}"
  echo
done
k8s_install_env_var
