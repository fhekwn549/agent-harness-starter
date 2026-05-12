#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: init-wiki.sh --vault PATH --project PATH [--name NAME]

Creates a small Obsidian-compatible LLM wiki scaffold for one project.
It does not install Obsidian and does not enable automatic logging.
EOF
}

VAULT=""
PROJECT=""
NAME=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --vault)
      VAULT="${2:-}"
      shift 2
      ;;
    --project)
      PROJECT="${2:-}"
      shift 2
      ;;
    --name)
      NAME="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown argument: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

[ -n "$VAULT" ] || { printf 'Missing --vault\n' >&2; exit 2; }
[ -n "$PROJECT" ] || { printf 'Missing --project\n' >&2; exit 2; }
[ -d "$PROJECT" ] || { printf 'Project directory not found: %s\n' "$PROJECT" >&2; exit 2; }

VAULT="$(mkdir -p "$VAULT" && cd "$VAULT" && pwd)"
PROJECT="$(cd "$PROJECT" && pwd)"
[ -n "$NAME" ] || NAME="$(basename "$PROJECT")"

mkdir -p \
  "$VAULT/00_inbox" \
  "$VAULT/10_concepts" \
  "$VAULT/20_decisions" \
  "$VAULT/30_playbooks" \
  "$VAULT/40_project_maps" \
  "$VAULT/70_work_logs" \
  "$VAULT/85_plans" \
  "$VAULT/90_context_packs"

write_if_missing() {
  local file="$1"
  if [ -e "$file" ]; then
    printf 'skip existing: %s\n' "$file"
    return 0
  fi
  mkdir -p "$(dirname "$file")"
  cat > "$file"
  printf 'created: %s\n' "$file"
}

git_branch="not a git repository"
git_head="not a git repository"
if git -C "$PROJECT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git_branch="$(git -C "$PROJECT" branch --show-current 2>/dev/null || true)"
  [ -n "$git_branch" ] || git_branch="detached"
  git_head="$(git -C "$PROJECT" rev-parse --short HEAD 2>/dev/null || true)"
  [ -n "$git_head" ] || git_head="no commits"
fi

write_if_missing "$VAULT/LLM Wiki Home.md" <<EOF
# LLM Wiki Home

이 vault는 agent가 세션을 넘어 재사용할 수 있는 project context를 저장합니다.

## 주요 폴더

- [[10_concepts/LLM Wiki Note Types]]
- [[20_decisions]]
- [[30_playbooks]]
- [[40_project_maps]]
- [[70_work_logs]]
- [[85_plans]]
- [[90_context_packs]]

## 등록된 project

- [[40_project_maps/Project Map - $NAME]]
EOF

write_if_missing "$VAULT/10_concepts/LLM Wiki Note Types.md" <<'EOF'
# LLM Wiki Note Types

## Concept
반복해서 쓰는 용어와 판단 기준.

## Decision
왜 그렇게 하기로 했는지 남기는 결정 기록.

## Playbook
반복 작업 절차와 검증 command.

## Project Map
폴더 구조, 주요 entrypoint, 테스트 방법, 주의점.

## Work Log
작업 단위별 변경 요약과 검증 결과.

## Context Pack
새 agent 세션 시작 시 먼저 읽을 압축 context.
EOF

write_if_missing "$VAULT/40_project_maps/Project Map - $NAME.md" <<EOF
# Project Map - $NAME

## 기본 정보

- Project path: \`$PROJECT\`
- Git branch: \`$git_branch\`
- Git head: \`$git_head\`

## 목적

이 project의 목적을 3-5줄로 정리합니다.

## 주요 구조

\`\`\`text
$(find "$PROJECT" -maxdepth 2 -mindepth 1 -not -path '*/.git*' -printf '%P\n' 2>/dev/null | sort | sed -n '1,80p')
\`\`\`

## 자주 쓰는 command

\`\`\`bash
# build/test/lint command를 추가합니다.
\`\`\`

## Agent 주의점

- 사용자 변경을 되돌리지 않습니다.
- 검증 결과 없이 완료를 선언하지 않습니다.
- project-specific rule은 이 note에 계속 갱신합니다.
EOF

write_if_missing "$VAULT/90_context_packs/$NAME-start-context.md" <<EOF
# $NAME Start Context

새 agent session에서 이 파일을 먼저 읽고 작업을 시작합니다.

## 먼저 읽을 note

- [[40_project_maps/Project Map - $NAME]]
- [[10_concepts/LLM Wiki Note Types]]

## 현재 기준

- Project path: \`$PROJECT\`
- Git branch: \`$git_branch\`
- Git head: \`$git_head\`

## 시작 프롬프트 예시

\`\`\`text
$VAULT/90_context_packs/$NAME-start-context.md 를 먼저 읽고,
project map과 최근 work log를 바탕으로 오늘 할 일을 정리해줘.
그 다음 필요한 skill을 고르고 실행 plan을 제안해줘.
\`\`\`
EOF

write_if_missing "$VAULT/70_work_logs/$NAME.md" <<EOF
# Work Log - $NAME

## YYYY-MM-DD

- Goal:
- Changed:
- Verification:
- Next:
EOF

printf '\nWiki scaffold ready.\n'
printf 'Vault: %s\n' "$VAULT"
printf 'Project: %s\n' "$PROJECT"
printf 'Open the vault directory in Obsidian.\n'
