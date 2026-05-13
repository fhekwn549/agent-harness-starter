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

if [ -f "$TARGET/AGENTS.md" ] || [ -f "$TARGET/CLAUDE.md" ]; then
  printf 'PASS instruction file exists\n'
else
  printf 'FAIL no AGENTS.md or CLAUDE.md\n' >&2
  failures=$((failures + 1))
fi

if [ -d "$TARGET/.agent-harness" ]; then
  while IFS= read -r script; do
    check "syntax $(basename "$script")" bash -n "$script"
  done < <(find "$TARGET/.agent-harness" -type f -name '*.sh' | sort)
fi

run_pre_bash_check() {
  local tool="$1" label="$2" payload="$3"
  local hook="$TARGET/.agent-harness/hooks/$tool/pre-bash.sh"
  [ -x "$hook" ] || return 0
  set +e
  printf '%s' "$payload" | "$hook" >/tmp/agent-harness-doctor.out 2>&1
  local status=$?
  set -e
  if [ "$status" -eq 2 ]; then
    printf 'PASS [%s] %s\n' "$tool" "$label"
  else
    printf 'FAIL [%s] %s\n' "$tool" "$label" >&2
    failures=$((failures + 1))
  fi
}

run_pre_file_check() {
  local tool="$1"
  local hook="$TARGET/.agent-harness/hooks/$tool/pre-file.sh"
  [ -x "$hook" ] || return 0
  set +e
  printf '{"tool_input":{"file_path":"%s/.env"}}' "$TARGET" | "$hook" >/tmp/agent-harness-doctor.out 2>&1
  local status=$?
  set -e
  if [ "$status" -eq 2 ]; then
    printf 'PASS [%s] block .env file\n' "$tool"
  else
    printf 'FAIL [%s] block .env file\n' "$tool" >&2
    failures=$((failures + 1))
  fi
}

for tool in codex claude; do
  run_pre_bash_check "$tool" "block git identity" \
    '{"tool_input":{"command":"git config user.email test@example.com"}}'
  run_pre_bash_check "$tool" "block rm -rf" \
    '{"tool_input":{"command":"rm -rf build"}}'
  run_pre_file_check "$tool"
done

rm -f /tmp/agent-harness-doctor.out

if [ "$failures" -gt 0 ]; then
  printf 'Doctor found %s failure(s)\n' "$failures" >&2
  exit 1
fi

printf 'Doctor passed\n'

