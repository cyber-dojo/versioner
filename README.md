[![CircleCI](https://circleci.com/gh/cyber-dojo/versioner.svg?style=svg)](https://circleci.com/gh/cyber-dojo/versioner)

# cyberdojo/versioner docker image

- A docker image for [cyber-dojo](http://cyber-dojo.org).
- Records a consistent set of image tags for all the cyber-dojo server's micro-services on [dockerhub](https://hub.docker.com/r/cyberdojo/versioner/tags)
- Used by the main [cyber-dojo](https://github.com/cyber-dojo/commander/blob/master/cyber-dojo) script

The .env file holds the commit-shas and image-tags comprising a consistent set of images
which can be used to bring up a cyber-dojo server.
For example, suppose there is an image cyberdojo/versioner:**0.1.29**, created from
a commit to this repo, and its .env file specifies:
  * a tag of **47dd256** for the [avatars](https://github.com/cyber-dojo/avatars/tree/47dd256870aa6053734626809dff3d08e963b6c3) service
  * a tag of **610f484** for the [differ](https://github.com/cyber-dojo/differ/tree/610f484e67fde232d9561521590de43e1e365fc3) service
  * a tag of **02183dc** for the [nginx](https://github.com/cyber-dojo/nginx/tree/02183dc03f0ed93d81829f9fca8eaa5eddd913b9) service
  * a tag of **f03228c** for the [runner](https://github.com/cyber-dojo/runner/tree/f03228c8e7e2ebc02b30d4e0c79c25cb6a79e815) service
  * a tag of **05e89ee** for the [web](https://github.com/cyber-dojo/web/tree/05e89eee29666e5474ddd486938f33127b0c2471) service
  * etc...
  ```bash
  $ cyber-dojo update 0.1.29
  $ cyber-dojo up
  Using version=0.1.29 (public)
  ...
  Using avatars=cyberdojo/avatars:47dd256
  Using differ=cyberdojo/differ:610f484
  Using nginx=cyberdojo/nginx:02183dc
  Using ragger=cyberdojo/runner:f03228c
  ...
  Using web=cyberdojo/web:05e89ee
  ...
  ```

The commit-shas/image-tags are held inside the versioner image in its /app/.env file.
```bash
$ docker run --rm cyberdojo/versioner:0.1.29 sh -c 'cat /app/.env'
CYBER_DOJO_PORT=80

CYBER_DOJO_CUSTOM=cyberdojo/custom:0d80805
CYBER_DOJO_EXERCISES=cyberdojo/exercises:7ca6d19
CYBER_DOJO_LANGUAGES=cyberdojo/languages-common:4b35db8

CYBER_DOJO_STARTER_BASE_SHA=008bef6f212089051ff9571576a805ef65e353d9
CYBER_DOJO_STARTER_BASE_TAG=008bef6

CYBER_DOJO_AVATARS_SHA=47dd256870aa6053734626809dff3d08e963b6c3
CYBER_DOJO_AVATARS_TAG=47dd256

CYBER_DOJO_COMMANDER_SHA=448c12c8d08eef4758bbd684dc7d22993aec5dd2
CYBER_DOJO_COMMANDER_TAG=448c12c

CYBER_DOJO_DIFFER_SHA=610f484e67fde232d9561521590de43e1e365fc3
CYBER_DOJO_DIFFER_TAG=610f484

CYBER_DOJO_MAPPER_SHA=66ad99b4fda57332c60d58ab7c2709ef568c35ea
CYBER_DOJO_MAPPER_TAG=66ad99b

CYBER_DOJO_NGINX_SHA=02183dc03f0ed93d81829f9fca8eaa5eddd913b9
CYBER_DOJO_NGINX_TAG=02183dc

CYBER_DOJO_PULLER_SHA=f0ddebc0b077c09d7e9ae235ad8cf9de1248e1f0
CYBER_DOJO_PULLER_TAG=f0ddebc

CYBER_DOJO_RAGGER_SHA=94d9eea335a463adc845ff7ae51f24424f120b69
CYBER_DOJO_RAGGER_TAG=94d9eea

CYBER_DOJO_RUNNER_SHA=f03228c8e7e2ebc02b30d4e0c79c25cb6a79e815
CYBER_DOJO_RUNNER_TAG=f03228c

CYBER_DOJO_SAVER_SHA=a7f8fe50d412d0eb94b7184667dfd74bc5aaed87
CYBER_DOJO_SAVER_TAG=a7f8fe5

CYBER_DOJO_WEB_IMAGE=cyberdojo/web
CYBER_DOJO_WEB_SHA=ac9952bc01f0708cf383264fcddd2536e9d077c4
CYBER_DOJO_WEB_TAG=ac9952b

CYBER_DOJO_ZIPPER_SHA=42e684bc231a3a3818b551fab4a3eaf0984d6d0e
CYBER_DOJO_ZIPPER_TAG=42e684b
```

- The custom/exercises/languages start-point entries are image names.
- The remaining core-service entries are commit shas and image tags.
- The tag is always the first seven chars of the sha.
- To run your own web service forked from [web](https://github.com/cyber-dojo/web)
specify its tag **and** its image name. For example:
  ```bash
  $ export CYBER_DOJO_WEB_IMAGE=turtlesec/web
  $ export CYBER_DOJO_WEB_TAG=84d6d0e
  $ cyber-dojo up ...
  Using avatars=cyberdojo/avatars:47dd256
  Using differ=cyberdojo/differ:610f484
  Using nginx=cyberdojo/nginx:02183dc
  Using ragger=cyberdojo/runner:f03228c
  ...
  Using web=turtlesec/web:84d6d0e
  ...
  ```
  ```yml
  # docker-compose.yml (used by cyber-dojo script)
  services:
    web:
      image: ${CYBER_DOJO_WEB_IMAGE}:${CYBER_DOJO_RUNNER_TAG}
      ...
  ```  
- Integration tests can cat /app/.env to /tmp, source it, and use
  the tag env-vars, eg, in a docker-compose.yml files. For example:
  ```bash
  #!/bin/bash
  set -e
  TAG=${CYBER_DOJO_VERSION:-latest}
  docker run --rm cyberdojo/versioner:${TAG} \
    sh -c 'cat /app/.env' \
      > /tmp/cyber-dojo-image-tags.sh
  set -a # -o allexport
  source /tmp/cyber-dojo-image-tags.sh
  set +a
  docker-compose --file my-docker-compose.yml up -d
  # ...wait for all services to be ready
  # ...run your tests which depend on differ and runner...
  ```
  ```yml
  # my-docker-compose.yml
  services:
    differ:
      image: cyberdojo/differ:${CYBER_DOJO_DIFFER_TAG}
      ...
    runner:
      image: cyberdojo/runner:${CYBER_DOJO_RUNNER_TAG}
      ...
  ```

- - - -

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
