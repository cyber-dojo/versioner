
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
