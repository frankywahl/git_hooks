#!/usr/bin/env bash

if [ "${1}" == "--about" ]; then
  echo "Run rubocop on changed files"
  exit 0
fi

if which rubocop >/dev/null; then
  git diff --name-only --cached -- \*.rb | xargs rubocop
fi
