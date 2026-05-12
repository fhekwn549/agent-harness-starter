#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../common/lib.sh
. "$SCRIPT_DIR/../common/lib.sh"

input="$(cat)"
command="$(printf '%s' "$input" | jq -r '.tool_input.command // empty')"
file_path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"

if [ -n "$file_path" ] && is_secret_path "$file_path"; then
  printf '%s\n' "Secret file access is blocked. Use example/template files instead." >&2
  exit 2
fi

if [ -n "$command" ] && command_mentions_secret_path "$command"; then
  printf '%s\n' "Secret file access is blocked. Use example/template files instead." >&2
  exit 2
fi

exit 0
