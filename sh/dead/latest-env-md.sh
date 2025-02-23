#!/usr/bin/env bash
set -Eeu

# Script to create .env.md as a hyperlinked version of .env
# Used by .git/hooks/pre-push
# Use: $ ./sh/latest-env-md.sh | tee ./app/.env.md
# Must be run after ./sh/latest-env.sh

source "${ROOT_DIR}/app/.env"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
upper_case() { printf "${1}" | tr [a-z] [A-Z] | tr [\\-] [_]; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sha_var()
{
  echo "CYBER_DOJO_$(upper_case "${1}")_SHA"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sha_value()
{
  local name=$(sha_var ${1})
  echo ${!name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sha_url()
{
  local -r sha=$(sha_value ${1})
  local -r name=$(echo ${1} | tr '_' '-')
  echo "https://github.com/cyber-dojo/${name}/commit/${sha}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sha_env_var()
{
  local -r name="${1}" # eg runner
  # Need two end-of-line spaces to force a .md file newline
  echo "CYBER_DOJO_$(upper_case "${1}")_IMAGE=cyberdojo/${name}  "
  echo "$(sha_var ${1})=[$(sha_value ${1})]($(sha_url ${1}))  "
  echo "$(tag_var ${1})=[$(tag_value ${1})]($(tag_url ${1}))  "
  echo "CYBER_DOJO_$(upper_case "${1}")_DIGEST=$(echo_digest "${name}")  "

  case "${1}" in

  custom-start-points    ) printf 'CYBER_DOJO_CUSTOM_START_POINTS_PORT=4526\n';;
  exercises-start-points ) printf 'CYBER_DOJO_EXERCISES_START_POINTS_PORT=4525\n';;
  languages-start-points ) printf 'CYBER_DOJO_LANGUAGES_START_POINTS_PORT=4524\n';;

  creator    ) printf 'CYBER_DOJO_CREATOR_PORT=4523\n';;
  dashboard  ) printf 'CYBER_DOJO_DASHBOARD_PORT=4527\n';;
  differ     ) printf 'CYBER_DOJO_DIFFER_PORT=4567\n';;
  nginx      ) printf 'CYBER_DOJO_NGINX_PORT=80 # Default in: $ cyber-dojo up\n';;
  runner     ) printf 'CYBER_DOJO_RUNNER_PORT=4597\n';;
  saver      ) printf 'CYBER_DOJO_SAVER_PORT=4537\n';;
  web        ) printf 'CYBER_DOJO_WEB_PORT=3000\n';;
  esac
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
tag_var()
{
  echo "CYBER_DOJO_$(upper_case "${1}")_TAG"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
tag_value()
{
  local name=$(tag_var ${1})
  echo ${!name:0:7}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
tag_url()
{
  local -r name="${1}" # eg runner
  local -r tag="$(tag_value ${1})"
  local -r digest="$(echo_digest "${name}")"
  echo "https://hub.docker.com/layers/cyberdojo/${name}/${tag}/images/sha256-${digest}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
echo_digest()
{
  local -r name="${1}" # eg runner
  local -r full_name=$(docker inspect --format='{{index .RepoDigests 0}}' "cyberdojo/${name}:latest")
  echo "${full_name:(-64)}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
k8s_install_env_var()
{
  local -r name='k8s_install'
  echo "$(sha_var ${name})=[$(sha_value ${name})]($(sha_url ${name}))  "
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
readonly services=(
  creator
  dashboard
  differ
  nginx
  runner
  saver
  web
)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
echo '### $ cyber-dojo commands delegate to commander'
echo
sha_env_var commander
echo
echo '### Base image used in: $ cyber-dojo start-point create'
echo
sha_env_var start-points-base
echo
echo '### Default start-points used in: $ cyber-dojo up'
echo
sha_env_var custom-start-points
echo
sha_env_var exercises-start-points
echo
sha_env_var languages-start-points
echo
echo '### Microservices used in: $ cyber-dojo up'
echo
for svc in "${services[@]}"
do
  sha_env_var ${svc}
  echo
done
echo '### Kubernetes install scripts'
k8s_install_env_var
