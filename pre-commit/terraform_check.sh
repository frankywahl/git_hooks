#!/usr/bin/env bash

if [ "${1}" == "--about" ]; then
  echo "Run Terraform errors"
  exit 0
fi

if [[ ! $(git diff --name-only --cached -- \*.tf) ]]; then
  exit 0
fi

if which terraform >/dev/null; then
  echo "Running terraform fmt"
  terraform fmt --diff --check --recursive 
  if [ $? -ne 0 ]; then
    echo "Invalid terraform fmt"
    exit 1
  fi
  echo "Running terraform validate"
  terraform validate 

  if [ $? -ne 0 ]; then
    echo "Invalid terraform validate"
    exit 1
  fi
fi
