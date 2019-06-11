#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
. "${ROOT_DIR}/.env"

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
  echo "$(cel_var ${1})=[$(cel_value ${1})]($(cel_url ${1}))  "
}

# ---------------------------------------------------

svc_var()
{
  local -r upper=$(echo ${1} | tr [a-z] [A-Z])
  echo "CYBER_DOJO_${upper}_SHA"
}

svc_value()
{
  local name=$(svc_var ${1})
  echo ${!name}
}

svc_url()
{
  local -r sha=$(svc_value ${1})
  local -r name=$(echo ${1} | tr '_' '-')
  echo "https://github.com/cyber-dojo/${name}/commit/${sha}"
}

svc_env_var()
{
  echo "$(svc_var ${1})=[$(svc_value ${1})]($(svc_url ${1}))  "
}

# ---------------------------------------------------

echo
echo "CYBER_DOJO_PORT=${CYBER_DOJO_PORT}  "
echo
for cel in custom exercises languages
do
  cel_env_var ${cel}
done
echo
for svc in commander differ mapper nginx ragger runner saver starter_base web zipper grafana prometheus
do
  svc_env_var ${svc}
done
