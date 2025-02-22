#!/usr/bin/env bash
set -Eeu

# TODO:
#   - Run scripts to create json files with needed contents from live aws-prod
#       one json file PER service
#           eg saver.json, with keys "image", "sha", "tag", "digest", "port"
#       one .env file created from the json files
#   - commit and push
#   Workflow steps
#     1. export $(cat .env)
#     2. run script create dockerhub tagged (non :latest) images
#     3. run script to create versioner images with .env inside


# Workflow script to print .env file content by inspecting json file produced from aws-prod
# Use: $ ./sh/service-latest-env.sh

readonly TMP_DIR=$(mktemp -d ~/tmp.cyber-dojo.versioner.XXXXXX)
remove_tmp_dir() { rm -rf "${TMP_DIR}" > /dev/null; }
trap remove_tmp_dir EXIT

# TODO: exit_non_zero_if_not_installed kosli docker jq

SNAPSHOT="$(kosli get snapshot aws-prod --org=cyber-dojo --api-token=dummy-unused --output=json)"

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sha_tag_digest_port_env_var()
{
  local -r service_name="${1}"  # eg commander

  if [ "${service_name}" == "commander" ]; then
    via_docker "${service_name}"
    return
  fi

  if [ "${service_name}" == "start-points-base" ]; then
    via_docker "${service_name}"
    return
  fi

  artifacts_length=$(echo "${SNAPSHOT}" | jq -r '.artifacts | length')
  for a in $(seq 0 $(( ${artifacts_length} - 1 )))
  do
      artifact="$(echo "${SNAPSHOT}" | jq -r ".artifacts[$a]")"
      annotation_type="$(echo "${artifact}" | jq -r ".annotation.type")"
      if [ "${annotation_type}" != "exited" ] ; then
        image_name="$(echo "${artifact}" | jq -r ".name")"
        # eg 244531986313.dkr.ecr.eu-central-1.amazonaws.com/saver:a0f337d@sha256:0505ac397473fa757d2d51a3e88f0995ce3c20696ffb046f62f73b28654df1ec
        if [[ ${image_name} == */${service_name}:* ]]; then
          via_curl "${service_name}" "${image_name}"
          return
        fi
     fi
  done
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
via_docker()
{
  local -r tool_name="${1}"                       # eg commander
  local -r image_name="cyberdojo/${tool_name}"    # eg cyberdojo/commander   (:latest default tag)

  docker --log-level=ERROR pull "${image_name}" > /dev/null 2>&1

  local -r sha="$(docker --log-level=ERROR run --rm --entrypoint="" "${image_name}" sh -c 'echo -n ${SHA}' 2> /dev/null)"
  local -r tag=${sha:0:7}

  local -r full_name=$(docker --log-level=ERROR inspect --format='{{index .RepoDigests 0}}' "${image_name}")
  local -r digest="${full_name:(-64)}"

  echo "  \"image\": \"${image_name}\","
  echo "  \"sha\": \"${sha}\","
  echo "  \"tag\": \"${tag}\","
  echo "  \"digest\": \"${digest}\","
  echo "  \"port\": 0"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
via_curl()
{
  local -r service_name="${1}"  # eg saver
  local -r image_name="${2}"    # eg 244531986313.dkr.ecr.eu-central-1.amazonaws.com/saver:a0f337d@sha256:0505ac397473fa757d2d51a3e88f0995ce3c20696ffb046f62f73b28654df1ec

  local -r sha="$(echo_sha "${service_name}")"
  local -r tag=${sha:0:7}
  local -r digest="$(echo_digest "${service_name}" "${image_name}")"
  local -r port="$(echo_port "${service_name}")"

  # TODO: check tag matches the one in the image_name

  echo "  \"image\": \"${image_name}\","
  echo "  \"sha\": \"${sha}\","
  echo "  \"tag\": \"${tag}\","
  echo "  \"digest\": \"${digest}\","
  echo "  \"port\": ${port}"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
echo_sha()
{
  local -r service_name="${1}"  # eg saver
  if [ "${service_name}" == "nginx" ]; then
    # TODO: curl of https://beta.cyber-dojo.org/nginx/sha does not yet work
    echo TODO
  else
    curl --fail --silent --request GET "https://beta.cyber-dojo.org/${service_name}/sha" | jq -r '.sha'
  fi
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
echo_digest()
{
  local -r service_name="${1}"  # eg saver
  local -r image_name="${2}"    # eg 244531986313.dkr.ecr.eu-central-1.amazonaws.com/saver:a0f337d@sha256:0505ac397473fa757d2d51a3e88f0995ce3c20696ffb046f62f73b28654df1ec
  if [ "${service_name}" == "creator" ]; then
    #TODO: can't get digest from creator's image_name yet...
    echo TODO
  else
     echo "${image_name:(-64)}"
  fi
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
echo_port()
{
  local -r service_name="${1}"
  case "${service_name}" in
    custom-start-points    ) echo 4526;;
    exercises-start-points ) echo 4525;;
    languages-start-points ) echo 4524;;

    creator    ) echo 4523;;
    dashboard  ) echo 4527;;
    differ     ) echo 4567;;
    nginx      ) echo 80;;
    runner     ) echo 4597;;
    saver      ) echo 4537;;
    web        ) echo 3000;;
  esac
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
readonly xservices=(
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

#readonly services=(
#  creator
#)

# TODO: each of these needs to be redirected to create a json file for each service
echo "{"
for service in "${services[@]}"
do
  sha_tag_digest_port_env_var "${service}"
done
echo "}"