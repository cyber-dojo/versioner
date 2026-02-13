#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/bin/lib.sh"
exit_non_zero_unless_installed kosli docker jq

# Script to create json files for each image. Relies on public dockerhub images.
#
# Use: make json_files
# Use: $ ./sh/make_json_files.sh

echo Taking snapshot of aws-prod Environment...
KOSLI_AWS_PROD=aws-prod
SNAPSHOT="$(kosli get snapshot "${KOSLI_AWS_PROD}" --org=cyber-dojo --api-token=dummy-unused --output=json)"

readonly services=(
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

create_json_files_for_all_micro_services()
{
  echo Creating json files...
  mkdir "${ROOT_DIR}/app/json" 2> /dev/null || true
  for service in "${services[@]}"
  do
    pull_public_image "${service}"
    filename="${service}.json"
    echo "  ${filename}"
    {
      echo "{"
      echo_json_content_for_one_micro_service "${service}"
      echo "}"
    } > "${ROOT_DIR}/app/json/${filename}"
  done
}

pull_public_image()
{
  local -r service_name="${1}" # eg saver
  local -r artifact="$(artifact_for_service "${service_name}")"
  local -r sha="$(echo "${artifact}" | jq -r ".git_commit")"
  local -r tag="${sha:0:7}"
  local -r public_image="cyberdojo/${service_name}:${tag}"  # eg cyberdojo/saver:a0f337d

  docker pull --platform linux/amd64 "${public_image}"
}

echo_json_content_for_one_micro_service()
{
  local -r service_name="${1}"  # eg saver
  local -r artifact="$(artifact_for_service "${service_name}")"
  local -r image_name="$(echo "${artifact}" | jq -r ".name")"
  local -r sha="$(echo "${artifact}" | jq -r ".git_commit")"
  local -r digest="$(echo_digest "${service_name}" "${sha}")"
  local -r port="$(echo_port "${service_name}")"

  echo_entries "${image_name}" "${sha}" "${digest}" "${port}"
}

artifact_for_service()
{
  local -r service_name="${1}"
  local -r artifacts_length=$(echo "${SNAPSHOT}" | jq -r '.artifacts | length')

  for a in $(seq 0 $(( artifacts_length - 1 )))
  do
      artifact="$(echo "${SNAPSHOT}" | jq -r ".artifacts[$a]")"
      annotation_type="$(echo "${artifact}" | jq -r ".annotation.type")"
      if [ "${annotation_type}" != "exited" ] ; then
        image_name="$(echo "${artifact}" | jq -r ".name")"
        # eg 244531986313.dkr.ecr.eu-central-1.amazonaws.com/saver:a0f337d@sha256:0505ac397473fa757d2d51a3e88f0995ce3c20696ffb046f62f73b28654df1ec
        if [[ ${image_name} == */${service_name}:* ]]; then
          echo "${artifact}"
          return
        fi
     fi
  done
}

create_json_file_for_commander()
{
  local -r image_name="cyberdojo/commander:latest"
  docker pull "${image_name}"
  local -r sha="$(docker --log-level=ERROR run --rm --entrypoint="" "${image_name}" sh -c 'echo -n ${SHA}' 2> /dev/null)"
  local -r digest="$(kosli fingerprint "${image_name}" --artifact-type=oci --debug=false)"
  local -r port=0

  local -r filename=commander.json
  echo "  ${filename}"
  {
    echo "{"
    echo_entries "${image_name}" "${sha}" "${digest}" "${port}"
    echo "}"
  } > "${ROOT_DIR}/app/json/${filename}"
}

create_json_file_for_start_points_base()
{
  local -r json="$(cat "${ROOT_DIR}/app/json/custom-start-points.json")"
  local -r tag="$(echo "${json}" | jq -r '.tag')"
  local -r image_name="cyberdojo/custom-start-points:${tag}"

  # Do NOT add @sha256:digest to image_name. It fails in the CI workflow with "unsupported digest algorithm"
  docker pull "${image_name}"

  local -r base_image="$( docker --log-level=ERROR run --rm --entrypoint="" "${image_name}" sh -c 'echo -n ${CYBER_DOJO_START_POINTS_BASE_IMAGE}'  2> /dev/null)"
  local -r base_sha="$(   docker --log-level=ERROR run --rm --entrypoint="" "${image_name}" sh -c 'echo -n ${CYBER_DOJO_START_POINTS_BASE_SHA}'    2> /dev/null)"
  local -r base_digest="$(docker --log-level=ERROR run --rm --entrypoint="" "${image_name}" sh -c 'echo -n ${CYBER_DOJO_START_POINTS_BASE_DIGEST}' 2> /dev/null)"
  local -r port=0

  local -r filename=start-points-base.json
  echo "  ${filename}"
  {
    echo "{"
    echo_entries "${base_image}" "${base_sha}" "${base_digest}" "${port}"
    echo "}"
  } > "${ROOT_DIR}/app/json/${filename}"
}

echo_digest()
{
  local -r service_name="${1}"                              # eg saver
  local -r sha="${2}"                                       # eg a0f337d93ee93f38e89182c49012fb3f8a9915d8
  local -r tag="${sha:0:7}"                                 # eg a0f337d
  local -r public_image="cyberdojo/${service_name}:${tag}"  # eg cyberdojo/saver:a0f337d
  local -r digest="$(kosli fingerprint "${public_image}" --artifact-type=docker --debug=false)"
  echo "${digest}"
}

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

    *) echo 0
  esac
}

echo_entries()
{
  local -r image="${1}"
  local -r sha="${2}"
  local -r digest="${3}"
  local -r port="${4}"
  echo "  \"image\": \"${image}\","
  echo "  \"sha\": \"${sha}\","
  echo "  \"tag\": \"${sha:0:7}\","
  echo "  \"digest\": \"${digest}\","
  echo "  \"port\": ${port}"
}

# Ordering is important here: all_micro_services must come before start_points_base.
# The former creates two things required by the latter:
#  - the json files for the 3 start points images
#  - the 3 public images on dockerhub
create_json_files_for_all_micro_services
create_json_file_for_commander
create_json_file_for_start_points_base

