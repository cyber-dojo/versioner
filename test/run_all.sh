#!/bin/bash
set -e

# Script to run the tests from inside a web container
readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

# - - - - - - - - - - - - - - - - - - - - - - - -
outside_container()
{
  [ -z "${INSIDE_CONTAINER_UUID}" ]
}

# - - - - - - - - - - - - - - - - - - - - - - - -
from_outside_run_all_tests()
{
  docker run \
    --env INSIDE_CONTAINER_UUID=yup \
    --rm \
    --tty \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    --volume "${ROOT_DIR}/.env:/app/.env:ro" \
    --volume "${ROOT_DIR}/test:/app/test:ro" \
    cyberdojo/docker-base \
      "/app/test/run_all.sh"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
from_inside_run_all_tests()
{
  cd "${ROOT_DIR}/test"
  TEST_FILES=(test_*.rb)
  ruby -W2 -e "%w( ${TEST_FILES[*]} ).shuffle.map{ |file| require './'+file }"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
if outside_container; then
  from_outside_run_all_tests
else
  from_inside_run_all_tests
fi
