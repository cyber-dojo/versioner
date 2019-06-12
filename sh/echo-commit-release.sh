#!/bin/bash
set -e
# eg git commit -m "[RELEASE=1.2.3] blah blah"  --> 1.2.3

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly SCRIPT=echo-commit-release.rb

docker run \
  --rm \
  --env GIT_COMMIT_MSG="${GIT_COMMIT_MSG}" \
  --volume ${MY_DIR}/${SCRIPT}:/app/${SCRIPT} \
  cyberdojo/ruby-base:latest \
    /app/${SCRIPT}