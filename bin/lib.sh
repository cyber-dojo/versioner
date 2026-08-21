
export DOCKER_CLI_HINTS=false

stderr()
{
  local -r message="${1}"
  >&2 echo "ERROR: ${message}"
}

exit_non_zero_unless_installed()
{
  for dependent in "$@"
  do
    if ! installed "${dependent}" ; then
      stderr "${dependent} is not installed"
      exit 42
    fi
  done
}

installed()
{
  local -r dependent="${1}"
  if hash "${dependent}" 2> /dev/null; then
    true
  else
    false
  fi
}

aws_prod_services()
{
  # The names of the services deployed to the aws-prod Environment, and thus
  # present in its Kosli snapshot.
  local -r services=(
    custom-start-points
    exercises-start-points
    languages-start-points
    creator
    dashboard
    differ
    nginx
    runner
    saver
    spooler
    web
  )
  echo "${services[@]}"
}

all_versioned_services()
{
  # The names of every service with a version in the .env file. commander and
  # start-points-base are not deployed to aws-prod, but they are versioned
  # alongside the services that are.
  echo commander start-points-base "$(aws_prod_services)"
}

image_name()
{
  echo cyberdojo/versioner
}

# Keeps :latest, which the build and local tooling read, and the tags named in
# the arguments, which are the ones the build just made. Every older tag goes,
# and an earlier build whose last tag was one of those goes with it, so local
# builds stop accumulating images.
remove_old_images()
{
  local -a kept=("$@")
  local -r name="$(image_name)"
  echo Removing old images
  # grep exits non-zero when the machine holds no versioner image, eg one whose
  # images have just been cleared, so an empty list must not end the build.
  local tagged_name keep
  for tagged_name in $(docker image ls --format '{{.Repository}}:{{.Tag}}' | grep "^${name}:" || true)
  do
    if [ "${tagged_name}" == "${name}:latest" ]; then
      continue
    fi
    local matched=false
    for keep in "${kept[@]}"
    do
      if [ "${tagged_name}" == "${name}:${keep}" ]; then
        matched=true
      fi
    done
    if [ "${matched}" == false ]; then
      # Removing by name:tag untags, so this succeeds even while a container
      # references the image, leaving it dangling until that container goes.
      docker image rm --force "${tagged_name}" || echo "  skipped ${tagged_name} (in use)"
    fi
  done
}

git_commit_sha()
{
  # shellcheck disable=SC2005
  echo "$(cd "${ROOT_DIR}" && git rev-parse HEAD)"
}

git_commit_msg()
{
  # shellcheck disable=SC2005
  echo "$(cd "${ROOT_DIR}" && git log --oneline --format=%B -n 1 HEAD | head -n 1)"
}

on_CI()
{
  [ "${CI:-}" == true ]
}
