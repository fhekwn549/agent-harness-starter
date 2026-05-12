#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-}"
[ -n "$TARGET" ] || { printf 'Usage: ./doctor.sh TARGET\n' >&2; exit 2; }

failures=0

check() {
  local name="$1"
  shift
  if "$@"; then
    printf 'PASS %s\n' "$name"
  else
    printf 'FAIL %s\n' "$name" >&2
    failures=$((failures + 1))
  fi
}

has_file() {
  [ -f "$1" ]
}

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

check "target exists" test -d "$TARGET"
check "git available" has_cmd git
check "jq available" has_cmd jq
check "bash available" has_cmd bash
check "python available" has_cmd python3
check "AGENTS.md exists" has_file "$TARGET/AGENTS.md"

if [ -d "$TARGET/.agent-harness" ]; then
  while IFS= read -r script; do
    check "syntax $(basename "$script")" bash -n "$script"
  done < <(find "$TARGET/.agent-harness" -type f -name '*.sh' | sort)
fi

if [ -x "$TARGET/.agent-harness/hooks/codex/pre-bash.sh" ]; then
  set +e
  printf '{"tool_input":{"command":"git config user.email test@example.com"}}' | "$TARGET/.agent-harness/hooks/codex/pre-bash.sh" >/tmp/agent-harness-doctor.out 2>&1
  status=$?
  set -e
  [ "$status" -eq 2 ] && printf 'PASS block git identity\n' || { printf 'FAIL block git identity\n' >&2; failures=$((failures + 1)); }

  set +e
  printf '{"tool_input":{"command":"rm -rf build"}}' | "$TARGET/.agent-harness/hooks/codex/pre-bash.sh" >/tmp/agent-harness-doctor.out 2>&1
  status=$?
  set -e
  [ "$status" -eq 2 ] && printf 'PASS block rm -rf\n' || { printf 'FAIL block rm -rf\n' >&2; failures=$((failures + 1)); }
fi

if [ -x "$TARGET/.agent-harness/hooks/codex/pre-file.sh" ]; then
  set +e
  printf '{"tool_input":{"file_path":"%s/.env"}}' "$TARGET" | "$TARGET/.agent-harness/hooks/codex/pre-file.sh" >/tmp/agent-harness-doctor.out 2>&1
  status=$?
  set -e
  [ "$status" -eq 2 ] && printf 'PASS block .env file\n' || { printf 'FAIL block .env file\n' >&2; failures=$((failures + 1)); }
fi

rm -f /tmp/agent-harness-doctor.out

if [ "$failures" -gt 0 ]; then
  printf 'Doctor found %s failure(s)\n' "$failures" >&2
  exit 1
fi

printf 'Doctor passed\n'

