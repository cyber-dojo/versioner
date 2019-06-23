#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

# - - - - - - - - - - - - - - - - - - - - - -

curl_cmd()
{
  local port="${1}"
  local path="${2}"
  local cmd="curl --silent --fail --data '{}' -X GET http://localhost:${port}/${path}"
  if [ -n "${DOCKER_MACHINE_NAME}" ]; then
    cmd="docker-machine ssh ${DOCKER_MACHINE_NAME} ${cmd}"
  fi
  echo "${cmd}"
}

# - - - - - - - - - - - - - - - - - - - - - -

wait_until_ready()
{
  local name="${1}"
  local port="${2}"
  local max_tries=10
  echo -n "Waiting until ${name} is ready"
  for _ in $(seq ${max_tries})
  do
    echo -n '.'
    if $(curl_cmd ${port} ready?) > /dev/null 2>&1 ; then
      echo 'OK'
      return
    else
      sleep 0.1
    fi
  done
  echo 'FAIL'
  echo "${name} not ready after ${max_tries} tries"
  docker logs ${name}
  exit 1
}

# - - - - - - - - - - - - - - - - - - - - - -

exit_unless_clean()
{
  local name="${1}"
  local docker_logs=$(docker logs "${name}")
  echo -n "Checking ${name} started cleanly..."
  if [[ -z "${docker_logs}" ]]; then
    echo 'OK'
  else
    echo 'FAIL'
    echo "[docker logs] not empty on startup"
    echo "<docker_log>"
    echo "${docker_logs}"
    echo "</docker_log>"
    exit 1
  fi
}

# - - - - - - - - - - - - - - - - - - - - - -

docker-compose \
  --file "${ROOT_DIR}/docker-compose.yml" \
  up \
  -d \
  --force-recreate \
  versioner

readonly NAME=test-versioner-server
readonly PORT=5647

wait_until_ready ${NAME} ${PORT}
exit_unless_clean ${NAME}

$(curl_cmd ${PORT} dot_env)

docker container rm ${NAME} --force > /dev/null 2>&1
echo
