
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
