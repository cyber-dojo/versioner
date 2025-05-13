#!/usr/bin/env bash
set -Eeu

readonly ROOT_DIR="$(cd "$(dirname "${0}")/.." && pwd)"

from_outside_run_all_tests()
{
  local -r image=cyberdojo/docker-base # for [docker] cmd
  docker run \
    --env CI \
    --env INSIDE_CONTAINER_UUID=yup \
    --interactive \
    --rm \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    --volume "${ROOT_DIR}/app/.env:/app/.env:ro" \
    --volume "${ROOT_DIR}/app/json:/app/json:ro" \
    --volume "${ROOT_DIR}/test:/app/test:ro" \
    ${image} \
      "/app/test/service_image_tests.sh"
}

from_inside_run_all_tests()
{
  cd "${ROOT_DIR}/test"
  TEST_FILES=(test_*.rb)
  ruby -W2 -e "%w( ${TEST_FILES[*]} ).shuffle.map{ |file| require './'+file }"
}

outside_container()
{
  [ -z "${INSIDE_CONTAINER_UUID:-}" ]
}

service_image_tests()
{
  if outside_container; then
    from_outside_run_all_tests
  else
    from_inside_run_all_tests
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - -
service_image_tests