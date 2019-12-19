#!/bin/bash
set -e

# Script to run the tests from outside a web container
ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

# - - - - - - - - - - - - - - - - - - - - - - - -
run_all_tests()
{
  docker run \
    --rm \
    --tty \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    --volume "${ROOT_DIR}/.env:/app/.env:ro" \
    --volume "${ROOT_DIR}/test:/app/test:ro" \
    cyberdojo/docker-base \
      "/app/test/run_all.sh"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
run_one_test()
{
  docker run \
    --rm \
    --tty \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    --volume "${ROOT_DIR}/.env:/app/.env:ro" \
    --volume "${ROOT_DIR}/test:/app/test:ro" \
    cyberdojo/docker-base \
      "/app/test/${1}"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
if [ -z "${1}" ]; then
  run_all_tests
else
  run_one_test "${1}"
fi
