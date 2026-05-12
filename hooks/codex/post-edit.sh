#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../common/lib.sh
. "$SCRIPT_DIR/../common/lib.sh"

input="$(cat)"
tool_name="$(printf '%s' "$input" | jq -r '.tool_name // empty')"
command="$(printf '%s' "$input" | jq -r '.tool_input.command // empty')"
file_path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"

paths=""
if [ -n "$file_path" ]; then
  paths="$file_path"
elif [ "$tool_name" = "apply_patch" ]; then
  paths="$(printf '%s\n' "$command" | sed -nE 's/^\*\*\* (Add|Update) File: (.*)$/\2/p')"
fi

printf '%s\n' "$paths" | while IFS= read -r path; do
  [ -n "$path" ] || continue
  if ! result="$(run_ruff_for_path "$path" 2>&1)"; then
    printf '%s\n' "ruff check failed for $path:" >&2
    printf '%s\n' "$result" >&2
  fi
done

exit 0

