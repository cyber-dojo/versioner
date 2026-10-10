#!/usr/bin/env bash
set -Eeu

readonly ROOT_DIR="$(cd "$(dirname "${0}")/.." && pwd)"
source "${ROOT_DIR}/bin/lib.sh"

show_help()
{
  # Prints the usage, with an example, to stdout.
  cat <<EOF
Usage: bin/push_platform_image.sh ARCH

In a CI workflow, pushes the image 'make build_image' built and checked,
$(image_name):latest, as $(image_name):<short-sha>-ARCH. The publish job's
bin/publish_image.sh then names each ARCH's image in one multi-platform index.
Outside CI it pushes nothing.

ARCH is the platform the image was built on, eg amd64 or arm64.

Options:
  -h    Show this help

Example:
  bin/push_platform_image.sh arm64
EOF
}

push_platform_image()
{
  # Pushes :latest under the commit's short sha suffixed with arch $1.
  local -r arch="${1}"
  local -r sha="$(git_commit_sha)"
  local -r tagged="$(image_name):${sha:0:7}-${arch}"
  if ! on_CI; then
    echo "not in CI Workflow so not pushing ${tagged}"
    return
  fi
  # Workflow has done docker login
  docker tag "$(image_name):latest" "${tagged}"
  docker push "${tagged}"
}

if [ "${1:-}" = '-h' ]; then
  show_help
  exit 0
fi
if [ -z "${1:-}" ]; then
  show_help >&2
  exit 42
fi
push_platform_image "${1}"
