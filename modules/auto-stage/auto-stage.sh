#!/usr/bin/env bash
set -euo pipefail

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
  [ -f "$path" ] || continue
  dir="$(dirname "$path")"
  if git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git -C "$dir" add "$path" 2>/dev/null || true
  fi
done

exit 0

