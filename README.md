[![CircleCI](https://circleci.com/gh/cyber-dojo/versioner.svg?style=svg)](https://circleci.com/gh/cyber-dojo/versioner)

# cyberdojo/versioner docker image

- A docker image for [cyber-dojo](http://cyber-dojo.org).
- Records a consistent set of image tags for all the cyber-dojo server's micro-services on [dockerhub](https://hub.docker.com/r/cyberdojo/versioner/tags)
- Used by the main [cyber-dojo](https://github.com/cyber-dojo/commander/blob/master/cyber-dojo) script

The .env file holds the commit-shas -> image-tags comprising a consistent set of images
which can be used to bring up a cyber-dojo server.
For example, suppose there is an image cyberdojo/versioner:1.24.0, created from
a commit to this repo, and its .env file specifies tags (1st seven chars of the sha)
of 5c95484 for differ, 380c557 for nginx, etc.
```bash
$ cyber-dojo update 1.24.0
$ cyber-dojo up
...
Using differ=cyberdojo/differ:5c95484
Using nginx=cyberdojo/nginx:380c557
...
```

The commit-shas/image-tags are held inside the versioner image in its /app/.env file.
```bash
$ docker run --rm cyberdojo/versioner:1.24.0 sh -c 'cat /app/.env'
CYBER_DOJO_PORT=80

CYBER_DOJO_CUSTOM=cyberdojo/custom:0d80805
CYBER_DOJO_EXERCISES=cyberdojo/exercises:7ca6d19
CYBER_DOJO_LANGUAGES=cyberdojo/languages-common:4b35db8

CYBER_DOJO_STARTER_BASE_SHA=008bef6f212089051ff9571576a805ef65e353d9
CYBER_DOJO_STARTER_BASE_TAG=008bef6

CYBER_DOJO_COMMANDER_SHA=448c12c8d08eef4758bbd684dc7d22993aec5dd2
CYBER_DOJO_COMMANDER_TAG=448c12c

CYBER_DOJO_DIFFER_SHA=d0a4b2e776ab5805b071dc0ee73e21c2a19df3b0
CYBER_DOJO_DIFFER_TAG=d0a4b2e

CYBER_DOJO_MAPPER_SHA=66ad99b4fda57332c60d58ab7c2709ef568c35ea
CYBER_DOJO_MAPPER_TAG=66ad99b

CYBER_DOJO_NGINX_SHA=276bc15c646d8a472ded4ed9eb3684ee45c90d2a
CYBER_DOJO_NGINX_TAG=276bc15

CYBER_DOJO_PULLER_SHA=f0ddebc0b077c09d7e9ae235ad8cf9de1248e1f0
CYBER_DOJO_PULLER_TAG=f0ddebc

CYBER_DOJO_RAGGER_SHA=94d9eea335a463adc845ff7ae51f24424f120b69
CYBER_DOJO_RAGGER_TAG=94d9eea

CYBER_DOJO_RUNNER_SHA=3d210eda82602f65467fd5a05c7b3c7aa86e4ee3
CYBER_DOJO_RUNNER_TAG=3d210ed

CYBER_DOJO_SAVER_SHA=a7f8fe50d412d0eb94b7184667dfd74bc5aaed87
CYBER_DOJO_SAVER_TAG=a7f8fe5

CYBER_DOJO_WEB_SHA=ac9952bc01f0708cf383264fcddd2536e9d077c4
CYBER_DOJO_WEB_TAG=ac9952b

CYBER_DOJO_ZIPPER_SHA=42e684bc231a3a3818b551fab4a3eaf0984d6d0e
CYBER_DOJO_ZIPPER_TAG=42e684b
```

- The custom/exercises/languages start-point entries are image names.
- The remaining core-service entries are commit shas. Each core-service
image is tagged with the first 7 characters of its commit sha.
For example
  - [cyberdojo/differ:5c95484](https://hub.docker.com/r/cyberdojo/differ/tags)
  - [cyberdojo/runner:1b06f00](https://hub.docker.com/r/cyberdojo/runner/tags)

- - - -

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
