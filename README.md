[![CircleCI](https://circleci.com/gh/cyber-dojo/versioner.svg?style=svg)](https://circleci.com/gh/cyber-dojo/versioner)

# cyberdojo/versioner docker image

The [cyber-dojo](https://github.com/cyber-dojo/commander/blob/master/cyber-dojo) bash script
uses a cyberdojo/versioner docker image when bringing up a cyber-dojo server.
For example, suppose cyberdojo/versioner:**latest** is a tag for cyberdojo/versioner:**0.1.35**,
and we bring up a cyber-dojo server:
```bash
$ cyber-dojo up
Using version=0.1.35 (public)
...
Using nginx=cyberdojo/nginx:02183dc
Using runner=cyberdojo/runner:f03228c
Using web=cyberdojo/web:05e89ee
...
```
This means cyberdojo/versioner:**0.1.35** specifies a consistent working set of
image tags for a cyber-dojo server's micro-services, as follows:
*  the [nginx](https://github.com/cyber-dojo/nginx/tree/02183dc03f0ed93d81829f9fca8eaa5eddd913b9) image with the tag **02183dc**
*  the [runner](https://github.com/cyber-dojo/runner/tree/f03228c8e7e2ebc02b30d4e0c79c25cb6a79e815) image with the tag **f03228c**
*  the [web](https://github.com/cyber-dojo/web/tree/05e89eee29666e5474ddd486938f33127b0c2471) image with the tag **05e89ee**
* etc...

- - - -

The ```/app/.env``` file holds the consistent set of image tags.
For example:
```bash
$ docker run --rm cyberdojo/versioner:0.1.35 sh -c 'cat /app/.env'
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

CYBER_DOJO_WEB_SHA=ac9952bc01f0708cf383264fcddd2536e9d077c4
CYBER_DOJO_WEB_TAG=ac9952b

CYBER_DOJO_ZIPPER_SHA=42e684bc231a3a3818b551fab4a3eaf0984d6d0e
CYBER_DOJO_ZIPPER_TAG=42e684b
```

- The custom/exercises/languages start-point entries are image names.
- The remaining entries are commit shas and image tags.
- The tag is always the first seven chars of the sha (docker-compose yml files
  can use ```${ENV_VAR}``` but cannot use ```${ENV_VAR:0:7}```).
- Integration tests can export ```/app/.env``` and use the env-vars in a docker-compose.yml file. For example:
  ```bash
  #!/bin/bash
  set -e
  TAG=${CYBER_DOJO_VERSION:-latest}
  export $(docker run --rm cyberdojo/versioner:${TAG} sh -c 'cat /app/.env')
  docker-compose --file my-docker-compose.yml up -d
  # ...wait for all services to be ready
  # ...run your tests which depend on, eg, runner...
  #
  ```
  ```yml
  # my-docker-compose.yml
  services:
    runner:
      image: cyberdojo/runner:${CYBER_DOJO_RUNNER_TAG}
      ...
  ```

- - - -

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
