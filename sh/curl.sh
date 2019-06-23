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
    if eval $(curl_cmd ${port} ready?) > /dev/null 2>&1 ; then
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

docker-compose \
  --file "${ROOT_DIR}/docker-compose.yml" \
  up \
  -d \
  --force-recreate \
  versioner

wait_until_ready test-versioner-server 5647

$(curl_cmd 5647 dot_env)
echo

docker container rm test-versioner-server --force > /dev/null 2>&1
