#!/usr/bin/env bash

if [ "${1}" == "--about" ]; then
  echo "Check yaml files"
  exit 0
fi

failed_files=()

while IFS= read -r -d '' file; do
  if ! yq '.' "${file}" >/dev/null 2>&1; then
    failed_files+=("${file}")
  fi
done < <(git diff -z --name-only --cached --diff-filter=d -- '*.yml' '*.yaml')

if [ "${#failed_files[@]}" -gt 0 ]; then
  echo "The following yaml files are invalid"
  printf '  - %s\n' "${failed_files[@]}"
  exit 1
fi

exit 0
