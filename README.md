[![CircleCI](https://circleci.com/gh/cyber-dojo/versioner.svg?style=svg)](https://circleci.com/gh/cyber-dojo/versioner)

# cyberdojo/versioner docker image

- A docker-containerized micro-service for [cyber-dojo](http://cyber-dojo.org).
- Records a set of consistent commits.

For example:
```bash
docker run --rm cyberdojo/versioner:5e3bc0b sh -c 'cat /app/.env'
CYBER_DOJO_PORT=80

CYBER_DOJO_CUSTOM=cyberdojo/custom:a089497
CYBER_DOJO_EXERCISES=cyberdojo/exercises:16fb5d9
CYBER_DOJO_LANGUAGES=cyberdojo/languages-common:8ab7cd9

CYBER_DOJO_COMMANDER_SHA=b291513a6830f55a4a5c57079b7afd29d0f66a03
CYBER_DOJO_DIFFER_SHA=5c95484d60e50ee1a77a5b859bb23a5cdea1cebb
CYBER_DOJO_MAPPER_SHA=5729d568cdbe27c6658064dedd02cc43cc7cf2b5
CYBER_DOJO_NGINX_SHA=380c557848929afec127ce2512c84ad8bd18e6db
CYBER_DOJO_RAGGER_SHA=5998a76e6faa4cc86da6f632ee749bdbe943f9fd
CYBER_DOJO_RUNNER_SHA=1b06f00f2a5bb3ec864cd449303087d9ba347ae1
CYBER_DOJO_SAVER_SHA=8485ef34c0164f6f19ca39bb38957441c0c0665c
CYBER_DOJO_STARTER_BASE_SHA=6f6f8989b9f6de4dfa8a2bb54c00c299772f1a00
CYBER_DOJO_WEB_SHA=c66c2da9c1190a3ea1a9986a1d890fdf2ee0f417
CYBER_DOJO_ZIPPER_SHA=2047f300afc108c3b222e7ef5fbe3d38765b22f2
CYBER_DOJO_GRAFANA_SHA=449370c2993649c9337a4197d124261d2394bb8e
CYBER_DOJO_PROMETHEUS_SHA=f0f7978d0d9cc13bbd5d87cfef2c13a45c5d97cc
```

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
