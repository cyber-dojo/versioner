[![Github Action (main)](https://github.com/cyber-dojo/versioner/actions/workflows/main.yml/badge.svg)](https://github.com/cyber-dojo/versioner/actions)

# cyberdojo/versioner docker image

To create a new versioner image, after updating one or more of the microservice images in prod
(eg runner, web, start-points-base, etc), simply:
- `make all_local`
- `git diff`
- `git add .`
- `git commit -m "[RELEASE=0.1.409] Patch level updates"` (assuming 0.1.408 was the current latest)
- `git push`


The `entrypoint` for a `cyberdojo/versioner` docker image simply prints a
self-consistent, working set of image-name, commit-sha, image-tag, image-digest, and port-number, environment variables.
For example:
<pre>
$ docker run --rm <b>cyberdojo/versioner:latest</b>
...
CYBER_DOJO_RUNNER_IMAGE=cyberdojo/runner
CYBER_DOJO_RUNNER_TAG=c31ef46
CYBER_DOJO_RUNNER_SHA=c31ef46df438c57268be5356e2717eaa822e8334
CYBER_DOJO_RUNNER_DIGEST=42fb72727fd50a0c1127be2ef036f2ee0a6aa9be9df5838055e65e55a37cd7ea
CYBER_DOJO_RUNNER_PORT=4597
...
CYBER_DOJO_WEB_IMAGE=cyberdojo/web
CYBER_DOJO_WEB_TAG=2498759
CYBER_DOJO_WEB_SHA=2498759f03851b85e85de2611a3a3742d54f3a6e
CYBER_DOJO_WEB_DIGEST=dbc41524d532e74b01f4da90ff15b737ac0e33132bf7338b4e20bb027e79d456
CYBER_DOJO_WEB_PORT=3000
...
</pre>

The main [cyber-dojo](https://github.com/cyber-dojo/commander/blob/master/cyber-dojo)
bash script uses these environment variables to:
- control the image identity and port number of all cyber-dojo microservice containers.
- control the [START_POINTS_BASE](https://github.com/cyber-dojo/start-points-base/actions) identity when running `cyber-dojo start-point create ...`

For example, suppose `cyberdojo/versioner:latest` is a tag for `cyberdojo/versioner:0.1.409`
(which we can see a fragment of above), and we bring up a cyber-dojo server:
<pre>
$ cyber-dojo up
Using version=<b>0.1.409</b> (public)
...
Using runner=<a href="https://github.com/cyber-dojo/runner/tree/c31ef46df438c57268be5356e2717eaa822e8334">cyberdojo/runner:c31ef46</a>
Using web=<a href="https://github.com/cyber-dojo/web/tree/2498759f03851b85e85de2611a3a3742d54f3a6e">cyberdojo/web:2498759</a>
...
</pre>

- Note: the runner service identity is `${CYBER_DOJO_RUNNER_IMAGE}:${CYBER_DOJO_RUNNER_TAG}`
- Note: the web service identity is `${CYBER_DOJO_WEB_IMAGE}:${CYBER_DOJO_WEB_TAG}`
- Note: The TAG is currently always the first seven chars of the SHA

- - - -
Integration tests can `export` these environment variables, and use them
in a `docker-compose.yml` file to bring up dependent services.
For example:
```bash
#!/usr/bin/env bash
set -Eeu
echo_env_vars() { docker run --rm cyberdojo/versioner:latest; }
export $(echo_env_vars)
docker compose --file my-docker-compose.yml up --detach
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
If you are working on cyber-dojo, from source,
and you want to run a cyber-dojo server which uses your
locally built image(s) one option is to explicitly replace
specific environment variables.
For example:
```bash
#!/usr/bin/env bash
set -Eeu
echo_env_vars()
{
  # Echoes all current service env-vars. See above.
  docker --log-level=ERROR run --rm cyberdojo/versioner:latest
  # Now override specific env-vars for local work-in-progress
  echo CYBER_DOJO_RUNNER_SHA=c93a9c650a8c4e7cc83545ce3f9108c2c76746d8
  echo CYBER_DOJO_RUNNER_TAG=c93a9c6
  # 
  echo CYBER_DOJO_SAVER_SHA=13b14d947fa9e873820d3e4a1e2f593735e9410a
  echo CYBER_DOJO_SAVER_TAG=13b14d9
  # ...
}
# Now export all echoed env-vars
export $(echo_env_vars)
```

- - - -
Alternatively you can build a `cyberdojo/versioner:latest` _fake_ _image_
which prints SHA/TAG values for your locally built image(s).

For example, if you are working on a local `web` service, you could
- create a fake `cyberdojo/versioner:latest` which prints `CYBER_DOJO_WEB_SHA` and `CYBER_DOJO_WEB_TAG` values matching the git-sha for `cyberdojo/web:TAG` image built from your local `web` git repo
(on `master` at `HEAD`).
- reissue the `cyber-dojo up ...` command.

You can automate creating a fake `cyberdojo/versioner:latest` using this bash script:
```bash
#!/usr/bin/env bash
set -Eeu
# Builds a fake cyberdojo/versioner:latest image that serves
# CYBER_DOJO_WEB SHA/TAG values for a local web image
# whose repo's dir/ contains this script.
readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TMP_DIR="$(mktemp -d /tmp/XXXXXXX)"
remove_TMP_DIR() { rm -rf "${TMP_DIR} > /dev/null"; }
trap remove_TMP_DIR INT EXIT
echo_env_vars() { docker --log-level=ERROR run --rm cyberdojo/versioner:latest; }
# - - - - - - - - - - - - - - - - - - - - - - - -
build_fake_versioner_with_sha_and_tag_for_local_web()
{
  local -r sha_var_name=CYBER_DOJO_WEB_SHA
  local -r tag_var_name=CYBER_DOJO_WEB_TAG
  local -r fake_sha="$(git_commit_sha)"
  local -r fake_tag="${fake_sha:0:7}"
  local env_vars="$(echo_env_vars)"
  env_vars=$(replace_with "${env_vars}" "${sha_var_name}" "${fake_sha}")
  env_vars=$(replace_with "${env_vars}" "${tag_var_name}" "${fake_tag}")
  echo "${env_vars}" > ${TMP_DIR}/.env
  local -r fake_image=cyberdojo/versioner:latest
  {
    echo 'FROM alpine:latest'
    echo 'ARG SHA'
    echo 'ENV SHA=${SHA}'
    echo 'ARG RELEASE'
    echo 'ENV RELEASE=${RELEASE}'
    echo 'COPY . /app'
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
  git rev-parse HEAD  # eg 3240bfbcf3f02a9625e1ce55d054126c1a1c2cf1
}
# - - - - - - - - - - - - - - - - - - - - - - - -  
build_fake_versioner_with_sha_and_tag_for_local_web
```

Alternatively, you can hand edit the SHA (`git rev-parse HEAD`) and TAG values
into `versioner/app/.env` and then build a local `cyberdojo/versioner:latest` image.
```bash
$ ./build_test_publish.sh --build-only
```

- - - -

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
