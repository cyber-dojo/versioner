#!/usr/bin/env bash
set -Eeu

# Script to create .env file from Artifacts running in prod.
# Use: $ ./sh/service-latest-env.sh | tee ./app/.env

# TODO: exit_non_zero_if_not_installed kosli docker
# TODO: a CI workflow could create the :latest docker images and push them to dockerhub
# TODO:    it would need ECR auth credentials to pull the image.

readonly TMP_DIR=$(mktemp -d ~/tmp.cyber-dojo.versioner.XXXXXX)
remove_tmp_dir() { rm -rf "${TMP_DIR}" > /dev/null; }
trap remove_tmp_dir EXIT

upper_case()
{
  printf "${1}" | tr [a-z] [A-Z] | tr [\\-] [_]
}

untagged_image_name()
{
  local -r name="${1}" # eg runner
  echo "cyberdojo/${name}"
}

docker_image_pull()
{
  local -r image="${1}"
  docker pull "${image}" > /dev/null 2>&1
}

echo_digest()
{
  local -r image="${1}" # eg cyberdojo/runner:latest
  local -r full_name=$(docker inspect --format='{{index .RepoDigests 0}}' "${image}")
  echo "${full_name:(-64)}"
}

service_sha()
{
  local -r image="${1}"
  docker run --rm --entrypoint="" "${image}" sh -c 'echo -n ${SHA}' 2> /dev/null
}

service_base_sha()
{
  local -r image="${1}"
  docker run --rm --entrypoint="" "${image}" sh -c 'echo -n ${BASE_SHA}' 2> /dev/null
}

sha_tag_digest_port_env_var()
{
  local -r image=$(untagged_image_name "${1}")
  docker_image_pull "${image}"
  #local -r full_name="$(docker inspect --format='{{index .RepoDigests 0}}' "${image}")"
  local -r digest="$(echo_digest "${image}")"

  if [ "${1}" == 'start-points-base' ]; then
    local -r sha=$(service_base_sha "${image}")
  else
    local -r sha=$(service_sha "${image}")
  fi
  local -r tag=${sha:0:7}
  echo "CYBER_DOJO_$(upper_case "${1}")_IMAGE=${image}"
  echo "CYBER_DOJO_$(upper_case "${1}")_SHA=${sha}"
  echo "CYBER_DOJO_$(upper_case "${1}")_TAG=${tag}"
  echo "CYBER_DOJO_$(upper_case "${1}")_DIGEST=${digest}"

  case "${1}" in
    custom-start-points    ) echo CYBER_DOJO_CUSTOM_START_POINTS_PORT=4526;;
    exercises-start-points ) echo CYBER_DOJO_EXERCISES_START_POINTS_PORT=4525;;
    languages-start-points ) echo CYBER_DOJO_LANGUAGES_START_POINTS_PORT=4524;;

    creator    ) echo CYBER_DOJO_CREATOR_PORT=4523;;
    dashboard  ) echo CYBER_DOJO_DASHBOARD_PORT=4527;;
    differ     ) echo CYBER_DOJO_DIFFER_PORT=4567;;
    nginx      ) echo CYBER_DOJO_NGINX_PORT=80;;
    runner     ) echo CYBER_DOJO_RUNNER_PORT=4597;;
    saver      ) echo CYBER_DOJO_SAVER_PORT=4537;;
    web        ) echo CYBER_DOJO_WEB_PORT=3000;;
  esac
}

k8s_install_env_var()
{
  git clone "https://github.com/cyber-dojo/k8s-install.git" "${TMP_DIR}" > /dev/null 2>&1
  local -r sha="$(cd ${TMP_DIR} && git rev-parse HEAD)"
  echo "CYBER_DOJO_K8S_INSTALL_SHA=${sha}"
}

readonly services=(
  commander
  start-points-base
  custom-start-points
  exercises-start-points
  languages-start-points
  creator
  dashboard
  differ
  nginx
  runner
  saver
  web
)

# ---------------------------------------------------

snapshot="$(kosli get snapshot aws-prod --org=cyber-dojo --api-token=dummy-unused --output=json)"
# "artifacts": [
#   {"name": "244531986313.dkr.ecr.eu-central-1.amazonaws.com/runner:c31ef46@sha256:42fb72727fd50a0c1127be2ef036f2ee0a6aa9be9df5838055e65e55a37cd7ea"},
#   {},
#   ...
#   ]
artifacts_length=$(echo "${snapshot}" | jq -r '.artifacts | length')
for a in $(seq 0 $(( ${artifacts_length} - 1 )))
do
    artifact="$(echo "${snapshot}" | jq -r ".artifacts[$a]")"
    annotation_type="$(echo "${artifact}" | jq -r ".annotation.type")"
    if [ "${annotation_type}" != "exited" ] ; then
      artifact_name="$(echo "${artifact}" | jq -r ".name")"
      echo "${artifact_name}"
   fi
done

# TODO: I do not have auth credentials to docker pull...
#   But I don't need to do a docker pull
#   244531986313.dkr.ecr.eu-central-1.amazonaws.com/runner:c31ef46@sha256:42fb72727fd50a0c1127be2ef036f2ee0a6aa9be9df5838055e65e55a37cd7ea
#   Gives me the tag, digest, and I can get the sha with a CURL call...
#   curl --fail --silent --request GET https://cyber-dojo.org/differ/sha | jq '.sha'

# TODO: how do I get the BASE_SHA for start-points-base?
#   Do I need an API end-point for that?
#   Suppose
#      curl --fail --silent --request GET https://cyber-dojo.org/custom-start-points/sha | jq '.sha'
#   Gives
#      1889f63226f4dcaadc7a5270212fa099458c6358
#
# This would equate to [docker run --rm -it cyberdojo/versioner] giving
#   CYBER_DOJO_CUSTOM_START_POINTS_IMAGE=cyberdojo/custom-start-points
#   CYBER_DOJO_CUSTOM_START_POINTS_SHA=1889f63226f4dcaadc7a5270212fa099458c6358
#   CYBER_DOJO_CUSTOM_START_POINTS_TAG=1889f63
#   CYBER_DOJO_CUSTOM_START_POINTS_DIGEST=0b0f77cdcdac61f9465174928f328cd107521227eb62e6cc279a6a0134ae3c65
#   CYBER_DOJO_CUSTOM_START_POINTS_PORT=4526
#
#   CYBER_DOJO_START_POINTS_BASE_IMAGE=cyberdojo/start-points-base
#   CYBER_DOJO_START_POINTS_BASE_SHA=07292391023dff901e6a7a42f7ab639f29855579
#   CYBER_DOJO_START_POINTS_BASE_TAG=0729239
#   CYBER_DOJO_START_POINTS_BASE_DIGEST=873077616665f4d1391a0c011cd6570814b866c00d04f62be611a8e60b58ee77
#
#  Now if I do [docker run --rm -it --entrypoint="" cyberdojo/custom-start-points:1889f63 env
#  I get
#     BASE_SHA=fec4aaf95a00ec9be252eec2b12fb1dbad5df970
#     IMAGE_TYPE=custom
#     BASE_IMAGE=cyberdojo/start-points-base:fec4aaf
#
# So I need to expose base_sha as an end-point.
# And cyberdojo/custom-start-points:1889f63 is not in ECR, so I can docker pull it and get its digest
# Would be better if the BASE_IMAGE included the digest...
# That should be possible, since commander should have access to all env-vars...

exit 42

echo
for service in "${services[@]}"
do
  #sha_tag_digest_port_env_var "${service}"
  echo "${service}"
  #echo
done
#k8s_install_env_var
