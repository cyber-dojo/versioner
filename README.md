[![CircleCI](https://circleci.com/gh/cyber-dojo/versioner.svg?style=svg)](https://circleci.com/gh/cyber-dojo/versioner)

# cyberdojo/versioner docker image

The main [cyber-dojo](https://github.com/cyber-dojo/commander/blob/master/cyber-dojo) bash script
uses the `cyberdojo/versioner:latest` docker image when bringing up a cyber-dojo server.
For example, suppose `cyberdojo/versioner:latest` is a tag for `cyberdojo/versioner:0.1.35`,
and we bring up a cyber-dojo server:
```bash
$ cyber-dojo up
Using version=0.1.35 (public)
...
Using runner=cyberdojo/runner:f03228c
Using web=cyberdojo/web:05e89ee
...
```
This means cyberdojo/versioner:`0.1.35` specifies a set of
images and tags for a cyber-dojo server's micro-services:
*  the cyberdojo/[runner](https://github.com/cyber-dojo/runner/tree/f03228c8e7e2ebc02b30d4e0c79c25cb6a79e815) image with the tag `f03228c`
*  the cyberdojo/[web](https://github.com/cyber-dojo/web/tree/05e89eee29666e5474ddd486938f33127b0c2471) image with the tag `05e89ee`
* etc...

- - - -
The entrypoint for a `cyberdojo/versioner` docker image prints a set of
environment variables. For example:
```bash
$ docker run --rm cyberdojo/versioner:0.1.35
...
CYBER_DOJO_RUNNER_IMAGE=cyberdojo/runner
CYBER_DOJO_RUNNER_SHA=f03228c8e7e2ebc02b30d4e0c79c25cb6a79e815
CYBER_DOJO_RUNNER_TAG=f03228c
CYBER_DOJO_RUNNER_PORT=4597
...
CYBER_DOJO_WEB_IMAGE=cyberdojo/web
CYBER_DOJO_WEB_SHA=ac9952bc01f0708cf383264fcddd2536e9d077c4
CYBER_DOJO_WEB_TAG=ac9952b
CYBER_DOJO_WEB_PORT=3000
...
```
- Entries are image names, commit-shas, image-tags, and port-numbers.
- The image-tag is always the first seven chars of the commit-sha (docker-compose yml files
  can use `${TAG}` but cannot use `${SHA:0:7}`).
- Integration tests can export `/app/.env` and use the env-vars in a docker-compose.yml file.
  For example:
  ```bash
  #!/bin/bash -Eeu
  export $(docker run --rm cyberdojo/versioner:latest)
  docker-compose --file my-docker-compose.yml up --detach
  # ...wait for all services to be ready
  # ...run your tests which depend on, eg, runner...
  #
  ```
  ```yml
  # my-docker-compose.yml
  services:
    runner:
      image: ${CYBER_DOJO_RUNNER_IMAGE}:${CYBER_DOJO_RUNNER_TAG}
      ...
  ```
- Integration tests using the main `cyber-dojo` script may need to build
  a _fake_ `cyberdojo/versioner:latest` image. For example:
  ```bash
  #!/bin/bash -Eeu
  readonly ROOT_DIR="$( cd "$( dirname "${0}" )/.." && pwd )"
  readonly TMP_DIR="$(mktemp -d /tmp/start-points-base.XXXXXXX)"
  remove_TMP_DIR() { rm -rf "${TMP_DIR} > /dev/null"; }
  trap remove_TMP_DIR INT EXIT
  # - - - - - - - - - - - - - - - - - - - - - - - -
  build_fake_versioner()
  {
    # Build a fake cyberdojo/versioner:latest image that serves
    # CYBER_DOJO_START_POINTS_BASE SHA/TAG values for the local
    # start-points-base repo.
    local -r sha_var_name=CYBER_DOJO_START_POINTS_BASE_SHA
    local -r tag_var_name=CYBER_DOJO_START_POINTS_BASE_TAG

    local -r fake_sha="$(git_commit_sha)"
    local -r fake_tag="${fake_sha:0:7}"

    local env_vars="$(docker run --rm cyberdojo/versioner:latest)"
    env_vars=$(replace_with "${env_vars}" "${sha_var_name}" "${fake_sha}")
    env_vars=$(replace_with "${env_vars}" "${tag_var_name}" "${fake_tag}")

    echo "${env_vars}" > ${TMP_DIR}/.env
    local -r fake_image=cyberdojo/versioner:latest
    {
      echo 'FROM alpine:latest'
      echo 'COPY . /app'
      echo 'ARG SHA'
      echo 'ENV SHA=${SHA}'
      echo 'ARG RELEASE'
      echo 'ENV RELEASE=${RELEASE}'
      echo 'ENTRYPOINT [ "cat", "/app/.env" ]'
    } > ${TMP_DIR}/Dockerfile
    docker build \
      --build-arg SHA="${fake_sha}" \
      --build-arg RELEASE=999.999.999 \
      --tag "${fake_image}" \
      "${TMP_DIR}"
  }
  # - - - - - - - - - - - - - - - - - - - - - - - -
  replace_with()
  {
    local -r env_vars="${1}"
    local -r name="${2}"
    local -r fake_value="${3}"
    local -r all_except=$(echo "${env_vars}" | grep --invert-match "${name}")
    printf "${all_except}\n${name}=${fake_value}\n"
  }
  # - - - - - - - - - - - - - - - - - - - - - - - -  
  git_commit_sha()
  {
    # eg 3240bfbcf3f02a9625e1ce55d054126c1a1c2cf1
    echo $(cd "${ROOT_DIR}" && git rev-parse HEAD)
  }
  # - - - - - - - - - - - - - - - - - - - - - - - -  
  build_fake_versioner
  ```
- To get the value of a single environment variable:
  ```bash
  #!/bin/bash -Eeu
  readonly runner_tag=$(docker run --entrypoint="" --rm cyberdojo/versioner:latest \
    sh -c 'export $(cat /app/.env) && echo ${CYBER_DOJO_RUNNER_TAG}')
  echo "${runner_tag}" # eg 3240bfb  
  ```

- - - -

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
