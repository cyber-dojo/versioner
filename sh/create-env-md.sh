#!/bin/bash
set -e

# Script to create .env.md as a hyperlinked version of .env
# Used by .git/hooks/pre-push
# which tells you to run
# $ ./sh/create-env-md.sh > .env.md

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
. "${ROOT_DIR}/.env"

# ---------------------------------------------------

sha()
{
  docker run --rm ${1} sh -c 'echo -n ${SHA}'
}

cel_var()
{
  local -r upper=$(echo ${1} | tr [a-z] [A-Z])
   echo "CYBER_DOJO_${upper}"
}

cel_value()
{
  local -r name="$(cel_var ${1})"
  echo ${!name}
}

cel_sha()
{
  sha $(cel_value $1)
}

cel_url()
{
  echo "https://github.com/cyber-dojo/${1}/commit/$(cel_sha ${1})"
}

cel_env_var()
{
  local -r env=$(cel_var ${1})
  echo "$(cel_var ${1})=[$(cel_value ${1})]($(cel_url ${1}))<br/>"
}

# ---------------------------------------------------

sha_var()
{
  local -r upper=$(echo ${1} | tr [a-z] [A-Z])
  echo "CYBER_DOJO_${upper}_SHA"
}

sha_value()
{
  local name=$(sha_var ${1})
  echo ${!name}
}

sha_url()
{
  local -r sha=$(sha_value ${1})
  local -r name=$(echo ${1} | tr '_' '-')
  echo "https://github.com/cyber-dojo/${name}/commit/${sha}"
}

sha_env_var()
{
  echo "$(sha_var ${1})=[$(sha_value ${1})]($(sha_url ${1}))<br/>"
  echo "$(tag_var ${1})=$(tag_value ${1})<br/>"
}

# ---------------------------------------------------

tag_var()
{
  local -r upper=$(echo ${1} | tr [a-z] [A-Z])
  echo "CYBER_DOJO_${upper}_TAG"
}

tag_value()
{
  local name=$(sha_var ${1})
  echo ${!name:0:7}
}

tag_url()
{
  local -r name=$(echo ${1} | tr '_' '-')
  echo "https://hub.docker.com/r/cyberdojo/${name}/tags"
}

tag_env_var()
{
  echo "$(tag_var ${1})=[$(tag_value ${1})]($(tag_url ${1}))<br/>"
}

# ---------------------------------------------------

echo
echo "CYBER_DOJO_PORT=${CYBER_DOJO_PORT}<br/>"

echo
for cel in custom exercises languages
do
  cel_env_var ${cel}
done

echo
sha_env_var starter_base

readonly services=(
  avatars
  commander
  differ
  mapper
  nginx
  puller
  ragger
  runner
  saver
  web
  zipper
)

for svc in "${services[@]}";
do
  echo
  sha_env_var ${svc}
done
