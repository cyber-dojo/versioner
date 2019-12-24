[![CircleCI](https://circleci.com/gh/cyber-dojo/versioner.svg?style=svg)](https://circleci.com/gh/cyber-dojo/versioner)

# cyberdojo/versioner docker image

The [cyber-dojo](https://github.com/cyber-dojo/commander/blob/master/cyber-dojo) bash script
uses a cyberdojo/versioner docker image when bringing up a cyber-dojo server.
For example, suppose `cyberdojo/versioner:**latest**` is a tag for `cyberdojo/versioner:**0.1.35**`,
and we bring up a cyber-dojo server:
```bash
$ cyber-dojo up
Using version=0.1.35 (public)
...
Using runner=cyberdojo/runner:f03228c
Using web=cyberdojo/web:05e89ee
...
```
This means cyberdojo/versioner:`0.1.35` specifies a consistent working set of
image tags for a cyber-dojo server's micro-services, as follows:
*  the cyberdojo/[runner](https://github.com/cyber-dojo/runner/tree/f03228c8e7e2ebc02b30d4e0c79c25cb6a79e815) image with the tag `f03228c`
*  the cyberdojo/[web](https://github.com/cyber-dojo/web/tree/05e89eee29666e5474ddd486938f33127b0c2471) image with the tag `05e89ee`
* etc...

- - - -

The `/app/.env` file holds a consistent set of image tags.
For example:
```bash
$ docker run --rm cyberdojo/versioner:0.1.35 sh -c 'cat /app/.env'
...
CYBER_DOJO_START_POINTS_BASE_IMAGE=cyberdojo/start-points-base
CYBER_DOJO_START_POINTS_BASE_SHA=b9c7459b07d337a890e5d22a9c805f372bda758f
CYBER_DOJO_START_POINTS_BASE_TAG=b9c7459
...
CYBER_DOJO_CUSTOM_START_POINTS=cyberdojo/custom-start-points:f3020d2
CYBER_DOJO_EXERCISES_START_POINTS=cyberdojo/exercises-start-points:ebdd09f
CYBER_DOJO_LANGUAGES_START_POINTS=cyberdojo/languages-start-points-common:6604370
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
- The start-points-base entries specify the [cyber-dojo start-point create] base-image
- The start-points entries are image names.
- The remaining entries are image names, commit shas, image tags, and port numbers.
- The tag is always the first seven chars of the sha (docker-compose yml files
  can use `${TAG}` but cannot use `${SHA:0:7}`).
- Integration tests can export `/app/.env` and use the env-vars in a docker-compose.yml file. For example:
  ```bash
  #!/bin/bash
  set -e
  export $(docker run --rm cyberdojo/versioner:latest sh -c 'cat /app/.env')
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

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
