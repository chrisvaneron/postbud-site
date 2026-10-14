#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

status=0

echo "Checking local asset references"
for html in *.html; do
  grep -oE '(src|href)="([^"#][^"]*)"' "$html" | \
    sed 's/.*="\(.*\)"/\1/' | \
    grep -v '^https\?://' | \
    grep -v '^mailto:' | \
    grep -v '^/$' | \
    sed 's/?.*//' | \
    { fail=0; while IFS= read -r ref; do
      resolved="${ref#/}"
      if [ -z "$resolved" ] || [ ! -f "$resolved" ]; then
        echo "BROKEN: ${html} references ${ref} (not found)"
        fail=1
      fi
    done; exit "$fail"; } || status=1
done

if [ "$status" -eq 0 ]; then
  echo "verify: all checks passed"
else
  echo "verify: checks failed"
  exit 1
fi
