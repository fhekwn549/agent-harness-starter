#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET=""
TOOL="codex"
MODULES=()

usage() {
  cat <<'EOF'
Usage: ./install.sh --target PATH [--tool codex|claude|cursor|all] [--module NAME]

Modules:
  auto-stage
  notifications
  output-style
  ros2-cleanup
  ros2-mcp
  wiki
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --target)
      TARGET="${2:-}"
      shift 2
      ;;
    --tool)
      TOOL="${2:-}"
      shift 2
      ;;
    --module)
      MODULES+=("${2:-}")
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

[ -n "$TARGET" ] || { printf 'Missing --target\n' >&2; exit 2; }
case "$TOOL" in codex|claude|cursor|all) ;; *) printf 'Invalid --tool: %s\n' "$TOOL" >&2; exit 2 ;; esac

mkdir -p "$TARGET/.agent-harness/hooks" "$TARGET/.agent-harness/modules" "$TARGET/.agent-harness/snippets" "$TARGET/docs/agent-harness"
cp "$ROOT/docs/agent-harness-readme.md" "$TARGET/docs/agent-harness/README.md"

copy_template() {
  local source="$1"
  local dest="$2"
  local suggested_name="$3"

  if [ -e "$dest" ]; then
    cp "$source" "$TARGET/.agent-harness/snippets/$suggested_name"
    printf 'Skipped existing %s; wrote suggested template to .agent-harness/snippets/%s\n' "$dest" "$suggested_name"
  else
    mkdir -p "$(dirname "$dest")"
    cp "$source" "$dest"
  fi
}

install_codex() {
  mkdir -p "$TARGET/.agent-harness/hooks/common" "$TARGET/.agent-harness/hooks/codex"
  copy_template "$ROOT/templates/AGENTS.md" "$TARGET/AGENTS.md" "AGENTS.md"
  cp "$ROOT/hooks/common/lib.sh" "$TARGET/.agent-harness/hooks/common/lib.sh"
  cp "$ROOT/hooks/codex/"*.sh "$TARGET/.agent-harness/hooks/codex/"

  cat > "$TARGET/.agent-harness/snippets/codex-config.toml" <<EOF
# Review before adding to ~/.codex/config.toml
[[hooks.PreToolUse]]
matcher = "^Bash$"

[[hooks.PreToolUse.hooks]]
type = "command"
command = "$TARGET/.agent-harness/hooks/codex/pre-bash.sh"
timeout = 30
statusMessage = "Checking agent harness safety"

[[hooks.PreToolUse]]
matcher = "^(apply_patch|Edit|Write|Read)$"

[[hooks.PreToolUse.hooks]]
type = "command"
command = "$TARGET/.agent-harness/hooks/codex/pre-file.sh"
timeout = 30
statusMessage = "Checking secret file access"

[[hooks.PostToolUse]]
matcher = "^(apply_patch|Edit|Write)$"

[[hooks.PostToolUse.hooks]]
type = "command"
command = "$TARGET/.agent-harness/hooks/codex/post-edit.sh"
timeout = 120
statusMessage = "Running post-edit checks"
EOF
}

install_claude() {
  mkdir -p "$TARGET/.agent-harness/hooks/common" "$TARGET/.agent-harness/hooks/claude"
  copy_template "$ROOT/templates/CLAUDE.md" "$TARGET/CLAUDE.md" "CLAUDE.md"
  cp "$ROOT/hooks/common/lib.sh" "$TARGET/.agent-harness/hooks/common/lib.sh"
  cp "$ROOT/hooks/claude/"*.sh "$TARGET/.agent-harness/hooks/claude/"

  cat > "$TARGET/.agent-harness/snippets/claude-settings-hooks.json" <<EOF
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {"type": "command", "command": "$TARGET/.agent-harness/hooks/claude/pre-bash.sh"}
        ]
      },
      {
        "matcher": "Read|Write|Edit",
        "hooks": [
          {"type": "command", "command": "$TARGET/.agent-harness/hooks/claude/pre-file.sh"}
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {"type": "command", "command": "$TARGET/.agent-harness/hooks/claude/post-edit.sh"}
        ]
      }
    ]
  }
}
EOF
}

install_cursor() {
  mkdir -p "$TARGET/.cursor/rules"
  copy_template "$ROOT/templates/AGENTS.md" "$TARGET/AGENTS.md" "AGENTS.md"
  copy_template "$ROOT/templates/cursor/agent-harness.mdc" "$TARGET/.cursor/rules/agent-harness.mdc" "agent-harness.mdc"
}

install_module() {
  local module="$1"
  case "$module" in
    auto-stage|notifications|output-style|ros2-cleanup|ros2-mcp|wiki)
      mkdir -p "$TARGET/.agent-harness/modules/$module"
      cp -R "$ROOT/modules/$module/." "$TARGET/.agent-harness/modules/$module/"
      if [ "$module" = "ros2-cleanup" ]; then
        cat > "$TARGET/.agent-harness/snippets/codex-ros2-cleanup.toml" <<EOF
# Optional ROS 2 cleanup hook. Review before adding to ~/.codex/config.toml.
[[hooks.PreToolUse]]
matcher = "^Bash$"

[[hooks.PreToolUse.hooks]]
type = "command"
command = "$TARGET/.agent-harness/modules/ros2-cleanup/check-ros2-processes.sh"
timeout = 30
statusMessage = "Checking ROS 2 processes"
EOF
        cat > "$TARGET/.agent-harness/snippets/claude-ros2-cleanup-hooks.json" <<EOF
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {"type": "command", "command": "$TARGET/.agent-harness/modules/ros2-cleanup/check-ros2-processes.sh"}
        ]
      }
    ]
  }
}
EOF
      fi
      if [ "$module" = "ros2-mcp" ]; then
        mkdir -p "$TARGET/.agent-harness/snippets/mcp"
        for snippet in "$TARGET/.agent-harness/modules/ros2-mcp/snippets/"*; do
          name="$(basename "$snippet")"
          sed "s#\\\$PROJECT#$TARGET#g" "$snippet" > "$TARGET/.agent-harness/snippets/mcp/$name"
        done
      fi
      ;;
    "")
      ;;
    *)
      printf 'Unknown module: %s\n' "$module" >&2
      exit 2
      ;;
  esac
}

case "$TOOL" in
  codex) install_codex ;;
  claude) install_claude ;;
  cursor) install_cursor ;;
  all) install_codex; install_claude; install_cursor ;;
esac

for module in "${MODULES[@]}"; do
  install_module "$module"
done

find "$TARGET/.agent-harness" -type f -name '*.sh' -exec chmod +x {} +

printf 'Installed agent harness into %s\n' "$TARGET"
printf 'Review snippets in %s/.agent-harness/snippets\n' "$TARGET"
