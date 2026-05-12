#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../common/lib.sh
. "$SCRIPT_DIR/../common/lib.sh"

input="$(cat)"
command="$(printf '%s' "$input" | jq -r '.tool_input.command // empty')"

block() {
  printf '%s\n' "$1" >&2
  exit 2
}

is_git_identity_change "$command" && block "Changing git user.name/user.email is blocked."
is_rm_rf "$command" && block "rm -rf is blocked. Explain the exact command and let the user run it."
is_destructive_git "$command" && block "Destructive git operation is blocked."
is_system_mutation "$command" && block "Privileged/system mutation command is blocked."
command_mentions_secret_path "$command" && block "Secret file access is blocked. Use example/template files instead."

exit 0

