#!/bin/bash

# eg git commit -m "[RELEASE=1.2.3] blah blah"  --> true

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly SCRIPT=echo-commit-release.rb

docker run \
  --rm \
  --env GIT_COMMIT_MSG="${GIT_COMMIT_MSG}" \
  --volume ${MY_DIR}/${SCRIPT}:/app/${SCRIPT} \
  cyberdojo/versioner:latest \
    /app/${SCRIPT}
