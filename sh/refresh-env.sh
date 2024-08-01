#!/usr/bin/env bash
set -Eeu

repo_root() { git rev-parse --show-toplevel; }

$(repo_root)/sh/latest-env.sh    | tee $(repo_root)/app/.env
if [ "${PIPESTATUS[0]}" != '0' ]; then
  exit 42
fi

$(repo_root)/sh/latest-env-md.sh | tee $(repo_root)/app/.env.md
if [ "${PIPESTATUS[0]}" != '0' ]; then
  exit 42
fi
