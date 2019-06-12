#!/bin/bash
set -e

ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

run_all_tests()
{
  for file in ${ROOT_DIR}/test/test_*.rb; do
    filename=$(basename "${file}")
    run_one_test "${filename}"
  done
}

# - - - - - - - - - - - - - - -

run_one_test()
{
  docker run \
    --rm \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    --volume "${ROOT_DIR}/.env:/app/.env:ro" \
    --volume "${ROOT_DIR}/test:/app/test:ro" \
    cyberdojo/docker-base \
      "/app/test/${1}"
}

# - - - - - - - - - - - - - - -

if [ -z "${1}" ]; then
  run_all_tests
else
  run_one_test "${1}"
fi
