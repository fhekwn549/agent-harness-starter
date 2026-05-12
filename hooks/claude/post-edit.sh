#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../common/lib.sh
. "$SCRIPT_DIR/../common/lib.sh"

input="$(cat)"
tool_name="$(printf '%s' "$input" | jq -r '.tool_name // empty')"
file_path=""

case "$tool_name" in
  Edit|Write)
    file_path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"
    ;;
esac

if [ -n "$file_path" ]; then
  if ! result="$(run_ruff_for_path "$file_path" 2>&1)"; then
    printf '%s\n' "ruff check failed for $file_path:" >&2
    printf '%s\n' "$result" >&2
  fi
fi

exit 0

