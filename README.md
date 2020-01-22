[![CircleCI](https://circleci.com/gh/cyber-dojo/versioner.svg?style=svg)](https://circleci.com/gh/cyber-dojo/versioner)

# cyberdojo/versioner docker image

The `entrypoint` for a `cyberdojo/versioner` docker image prints a set of
image-name, commit-sha, image-tag, and port-number, environment variables.
For example:
<pre>
$ docker run --rm <b>cyberdojo/versioner:0.1.89</b>
...
CYBER_DOJO_RUNNER_IMAGE=<b>cyberdojo/runner</b>
CYBER_DOJO_RUNNER_SHA=a74c5bcbb43e8fcf497be997809ce1951979e7a0
CYBER_DOJO_RUNNER_TAG=<b>a74c5bc</b>
CYBER_DOJO_RUNNER_PORT=4597
...
CYBER_DOJO_WEB_IMAGE=<b>cyberdojo/web</b>
CYBER_DOJO_WEB_SHA=333d9be4f64d3950c0bc5a0c450ce892b10e8389
CYBER_DOJO_WEB_TAG=<b>333d9be</b>
CYBER_DOJO_WEB_PORT=3000
...
</pre>

The main [cyber-dojo](https://github.com/cyber-dojo/commander/blob/master/cyber-dojo)
bash script uses these environment variables.
For example, if `cyberdojo/versioner:latest` is a tag for `cyberdojo/versioner:0.1.89`,
and we bring up a cyber-dojo server:
<pre>
$ cyber-dojo up
Using version=<b>0.1.89</b> (public)
...
Using runner=[cyberdojo/runner:a74c5bc](https://github.com/cyber-dojo/runner/tree/a74c5bcbb43e8fcf497be997809ce1951979e7a0)
Using web=[cyberdojo/web:333d9be](https://github.com/cyber-dojo/web/tree/333d9be4f64d3950c0bc5a0c450ce892b10e8389)
...
</pre>

- - - -
Integration tests can `export` these environment variables, and use them
in a `docker-compose.yml` file. For example:
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

- - - -
Integration tests using the main `cyber-dojo` script may need to build
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

- - - -
You can get the value of a single environment variable, without exporting to the
current shell, by exporting inside the docker container. For example:
```bash
#!/bin/bash -Eeu
readonly runner_tag=$(docker run --entrypoint="" --rm cyberdojo/versioner:latest \
  sh -c 'export $(cat /app/.env) && echo ${CYBER_DOJO_RUNNER_TAG}')
echo "${runner_tag}" # eg 3240bfb  
```

- - - -

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
