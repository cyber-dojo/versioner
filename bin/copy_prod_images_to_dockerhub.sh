#!/usr/bin/env bash
set -Eeu

readonly ROOT_DIR="$(cd "$(dirname "${0}")/.." && pwd)"
source "${ROOT_DIR}/bin/lib.sh"
exit_non_zero_unless_installed kosli docker jq

# Workflow script to copy private images (web, runner, saver, etc) in AWS ECR, to dockerhub.
#
# Use: make copy_prod_images_to_dockerhub

echo Taking snapshot of aws-prod Environment...
KOSLI_AWS_PROD=aws-prod
SNAPSHOT="$(kosli get snapshot "${KOSLI_AWS_PROD}" --org=cyber-dojo --api-token=dummy-unused --output=json)"

copy_prod_images_to_dockerhub()
{
  echo Copying aws-prod images to dockerhub...
  for service in $(aws_prod_services)
  do
    echo
    echo "Copying image to dockerhub: ${service}"
    create_public_image "${service}"
  done
}

create_public_image()
{
  local -r service_name="${1}" # eg saver
  local -r artifact="$(artifact_for_service "${service_name}")"
  local -r sha="$(echo "${artifact}" | jq -r ".git_commit")" # eg c56e309a51bfbca8969883ff93e783f446de7dd4
  local -r tag="${sha:0:7}"                                  # eg c56e309
  local -r private_image="$(echo "${artifact}" | jq -r ".name")"
  local -r public_image="cyberdojo/${service_name}:${tag}"  # eg cyberdojo/saver:c56e309

  # The copy must keep the digest Kosli recorded. A multi-platform index is
  # copied registry-side, every platform as it is; a pull would fetch only the
  # runner's platform and the push would publish a different, one-platform
  # image. A single-platform manifest is pulled and pushed, which keeps its
  # digest, where imagetools would wrap it in a new index.
  local -r media_type="$(docker buildx imagetools inspect "${private_image}" \
                           --format '{{ json .Manifest }}' | jq -r .mediaType)"
  case "${media_type}" in
    *image.index*|*manifest.list*)
      docker buildx imagetools create --tag "${public_image}" "${private_image}"
      ;;
    *)
      docker pull "${private_image}"
      docker tag "${private_image}" "${public_image}"
      docker push "${public_image}"
      ;;
  esac
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
        # eg 244531986313.dkr.ecr.eu-central-1.amazonaws.com/saver:c56e309@sha256:4bbb993aa46a8dca26a9e24584f58b1641154d554fc5d2ffbd86925967fa50a3
        if [[ ${image_name} == */${service_name}:* ]]; then
          echo "${artifact}"
          return
        fi
     fi
  done
}

copy_prod_images_to_dockerhub
