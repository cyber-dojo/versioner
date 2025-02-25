#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/sh/lib.sh"
exit_non_zero_unless_installed kosli docker jq

# Workflow script to create:
#   json file from Kosli aws-prod snapshot
#   .env file content by inspecting json files
#
# Use: $ ./sh/service-latest-env.sh

echo Taking snapshot of aws-prod Environment...
KOSLI_AWS_PROD=aws-prod
SNAPSHOT="$(kosli get snapshot "${KOSLI_AWS_PROD}" --org=cyber-dojo --api-token=dummy-unused --output=json)"

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sha_tag_digest_port_env_var()
{
  local -r service_name="${1}"  # eg commander

  if [ "${service_name}" == "commander" ]; then
    via_docker "${service_name}"
    return
  fi

  if [ "${service_name}" == "start-points-base" ]; then
    via_base_image "${service_name}"
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
  local -r sha="$(docker --log-level=ERROR run --rm --entrypoint="" "${image_name}" sh -c 'echo -n ${SHA}' 2> /dev/null)"
  local -r digest="$(kosli fingerprint "${image_name}" --artifact-type=docker --debug=false)"
  local -r port=0
  echo_entries "${image_name}" "${sha}" "${digest}" "${port}"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
via_base_image()
{
  local -r service_name="${1}"                                               # eg start-points-base
  local -r base_image="$(echo_base_image "custom-start-points")"             # eg cyberdojo/start-points-base:0729239
  local -r base_sha="$(docker run --rm "${base_image}" sh -c 'echo ${SHA}')" # eg 07292391023dff901e6a7a42f7ab639f29855579
  local -r base_digest="$(kosli fingerprint "${base_image}" --artifact-type=docker --debug=false)"
  local -r port=0
  echo_entries "${base_image}" "${base_sha}" "${base_digest}" "${port}"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
via_curl()
{
  local -r service_name="${1}"  # eg saver
  local -r image_name="${2}"    # eg 244531986313.dkr.ecr.eu-central-1.amazonaws.com/saver:a0f337d@sha256:0505ac397473fa757d2d51a3e88f0995ce3c20696ffb046f62f73b28654df1ec
  local -r sha="$(echo_sha "${service_name}")"
  local -r digest="$(echo_digest "${image_name}")"
  local -r port="$(echo_port "${service_name}")"
  echo_entries "${image_name}" "${sha}" "${digest}" "${port}"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
echo_sha()
{
  local -r service_name="${1}"
  xxx_curl "https://cyber-dojo.org/${service_name}/sha" | jq -r '.sha'
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
echo_base_image()
{
  local -r service_name="${1}"
  xxx_curl "https://cyber-dojo.org/${service_name}/base_image" | jq -r '.base_image'
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
xxx_curl()
{
  local -r url="${1}"
  local -r output_file=$(mktemp)

  http_code=$(curl --request GET \
       --output "${output_file}" \
       --write-out "%{http_code}" \
       --silent \
       "${url}")

  if [[ "${http_code}" -eq "200" ]] ; then
    cat "${output_file}"
    rm "${output_file}"
  else
    rm "${output_file}"
    echo '{"base_image": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", "sha": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}'
  fi
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
echo_digest()
{
  local -r image_name="${1}"  # eg 244531986313.dkr.ecr.eu-central-1.amazonaws.com/saver:a0f337d@sha256:0505ac397473fa757d2d51a3e88f0995ce3c20696ffb046f62f73b28654df1ec
  echo "${image_name:(-64)}"
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

    *) echo 0
  esac
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
upper_case()
{
  printf "${1}" | tr [a-z] [A-Z] | tr [\\-] [_]
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
create_json_file()
{
  local -r service="${1}"
  local -r filename="${service}.json"

  mkdir "${ROOT_DIR}/app/json" 2> /dev/null || true
  echo "  ${filename}"
  {
    echo "{"
    sha_tag_digest_port_env_var "${service}"
    echo "}"
  } > "${ROOT_DIR}/app/json/${filename}"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
echo_env()
{
  local -r service="${1}"
  local -r filename="${service}.json"
  local -r prefix="CYBER_DOJO_$(upper_case "${service}")"
  local -r json="$(cat "${ROOT_DIR}/app/json/${filename}")"
  local -r sha="$(echo "${json}" | jq -r '.sha')"
  local -r tag="$(echo "${json}" | jq -r '.tag')"
  local -r digest="$(echo "${json}" | jq -r '.digest')"
  local -r port="$(echo "${json}" | jq -r '.port')"

  echo
  echo "${prefix}_IMAGE=cyberdojo/${service}"
  echo "${prefix}_SHA=${sha}"
  echo "${prefix}_TAG=${tag}"
  echo "${prefix}_DIGEST=${digest}"
  if [ "${port}" != "0" ]; then
    echo "${prefix}_PORT=${port}"
  fi
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
echo_env_md()
{
  local -r service="${1}"
  local -r filename="${service}.json"
  local -r prefix="CYBER_DOJO_$(upper_case "${service}")"
  local -r json="$(cat "${ROOT_DIR}/app/json/${filename}")"
  local -r sha="$(echo "${json}" | jq -r '.sha')"
  local -r tag="$(echo "${json}" | jq -r '.tag')"
  local -r digest="$(echo "${json}" | jq -r '.digest')"
  local -r port="$(echo "${json}" | jq -r '.port')"

  echo
  echo "${prefix}_IMAGE=cyberdojo/${service}  "
  echo "${prefix}_SHA=[${sha}](https://github.com/cyber-dojo/${service}/commit/${sha})  "
  echo "${prefix}_TAG=${tag}  "
  echo "${prefix}_DIGEST=[${digest}](https://hub.docker.com/layers/cyberdojo/${service}/${tag}/images/sha256-${digest})  "
  if [ "${port}" != "0" ]; then
    echo "${prefix}_PORT=${port}  "
  fi
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

readonly xservices=(
  runner
)

refresh_env()
{
  echo Creating json files...
  mkdir "${ROOT_DIR}/app/json" 2> /dev/null || true
  for service in "${services[@]}"
  do
    create_json_file "${service}"
  done

  echo Creating .env file
  dot_env_filename="${ROOT_DIR}/app/.env"
  rm "${dot_env_filename}" 2> /dev/null || true
  for service in "${services[@]}"
  do
    echo_env "${service}" >> "${dot_env_filename}"
  done

  echo Creating .env.md file
  dot_env_md_filename="${ROOT_DIR}/app/.env.md"
  rm "${dot_env_md_filename}" 2> /dev/null || true
  for service in "${services[@]}"
  do
    echo_env_md "${service}" >> "${dot_env_md_filename}"
  done
}

# - - - - - - - - - - - - - - - - - - - - - - - -
refresh_env

