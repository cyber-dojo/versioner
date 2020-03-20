[![CircleCI](https://circleci.com/gh/cyber-dojo/versioner.svg?style=svg)](https://circleci.com/gh/cyber-dojo/versioner)

# cyberdojo/versioner docker image

The docker `entrypoint` for a `cyberdojo/versioner` docker image simply prints a
set of image-name, commit-sha, image-tag, and port-number, environment variables.
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
For example, suppose `cyberdojo/versioner:latest` is a tag for `cyberdojo/versioner:0.1.89`,
and we bring up a cyber-dojo server:
<pre>
$ cyber-dojo up
Using version=<b>0.1.89</b> (public)
...
Using runner=<a href="https://github.com/cyber-dojo/runner/tree/a74c5bcbb43e8fcf497be997809ce1951979e7a0">cyberdojo/runner:a74c5bc</a>
Using web=<a href="https://github.com/cyber-dojo/web/tree/333d9be4f64d3950c0bc5a0c450ce892b10e8389">cyberdojo/web:333d9be</a>
...
</pre>

- - - -
Integration tests `export` these environment variables, and use them
in a `docker-compose.yml` file to bring up dependent services.
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

- - - -
To get the value of a single environment variable, without exporting to the
current shell, you can export inside the docker container and echo.
For example:
```bash
#!/bin/bash -Eeu
readonly runner_tag=$(docker run --entrypoint="" --rm cyberdojo/versioner:latest \
  sh -c 'export $(cat /app/.env) && echo ${CYBER_DOJO_RUNNER_TAG}')
echo "${runner_tag}" # eg a74c5bc  
```

- - - -
If you are working on cyber-dojo, from source, locally,
and you want to run a cyber-dojo server which uses your
locally built image(s) you will need to build
a `cyberdojo/versioner:latest` _fake_ _image_
which prints env-vars for your locally built images.

For example, if you are working on a local `runner` service,
you will need to create a fake `cyberdojo/versioner:latest`
which prints `CYBER_DOJO_RUNNER_SHA` and `CYBER_DOJO_RUNNER_TAG` values
matching the git-sha for the work in your local `runner` git repo.

You can automate this using a script:
```bash
#!/bin/bash -Eeu
readonly ROOT_DIR="$(cd "$(dirname "${0}")" && pwd)"
readonly TMP_DIR="$(mktemp -d /tmp/XXXXXXX)"
remove_TMP_DIR() { rm -rf "${TMP_DIR} > /dev/null"; }
trap remove_TMP_DIR INT EXIT
# - - - - - - - - - - - - - - - - - - - - - - - -
build_fake_versioner()
{
  # Build a fake cyberdojo/versioner:latest image that serves
  # CYBER_DOJO_RUNNER SHA/TAG values for the local runner repo.
  local -r sha_var_name=CYBER_DOJO_RUNNER_SHA
  local -r tag_var_name=CYBER_DOJO_RUNNER_TAG

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

Alternatively, you can hand edit the SHA (`git rev-parse HEAD`) and TAG values
into `versioner/app/.env` and build a local `cyberdojo/versioner:latest` image.
```bash
$ cd versioner
$ ./build_test_tag_publish --no-test
```

- - - -

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
