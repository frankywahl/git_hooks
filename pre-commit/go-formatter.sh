#!/usr/bin/env bash

if [ "${1}" == "--about" ]; then
  echo "Run Golang formatter errors"
  exit 0
fi

if which gofmt >/dev/null; then
  DIFF=$(git diff --name-only --cached -- \*.go | xargs gofmt -d)
  if [ -n "${DIFF}" ]; then # String is not null
    echo "You have formatting errors"
    echo "Please run \`gofmt\` before committing"
    exit 1
  else
    exit 0
  fi
fi
