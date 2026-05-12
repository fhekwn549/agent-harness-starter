#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="$(mktemp -d)"
trap 'rm -rf "$TARGET"' EXIT

"$ROOT/install.sh" --target "$TARGET" --tool codex --module ros2-cleanup --module ros2-mcp --module output-style --module wiki
"$ROOT/doctor.sh" "$TARGET"

test -f "$TARGET/AGENTS.md"
test -f "$TARGET/.agent-harness/snippets/codex-config.toml"
test -f "$TARGET/.agent-harness/snippets/codex-ros2-cleanup.toml"
test -x "$TARGET/.agent-harness/hooks/codex/pre-bash.sh"
test -x "$TARGET/.agent-harness/modules/ros2-cleanup/check-ros2-processes.sh"
test -f "$TARGET/.agent-harness/modules/ros2-cleanup/ROS2_RULES.md"
test -x "$TARGET/.agent-harness/modules/ros2-mcp/ros2-mcp-wrapper.sh"
test -f "$TARGET/.agent-harness/modules/ros2-mcp/README.md"
test -f "$TARGET/.agent-harness/snippets/mcp/codex-ros2-mcp.toml"
test -f "$TARGET/.agent-harness/snippets/mcp/claude-ros2-mcp.md"
test -f "$TARGET/.agent-harness/snippets/mcp/cursor-ros2-mcp.json"
test -x "$TARGET/.agent-harness/modules/wiki/init-wiki.sh"

VAULT="$TARGET/wiki-vault"
"$TARGET/.agent-harness/modules/wiki/init-wiki.sh" --vault "$VAULT" --project "$TARGET" --name demo-agent-project >/tmp/agent-harness-wiki.out
test -f "$VAULT/LLM Wiki Home.md"
test -f "$VAULT/40_project_maps/Project Map - demo-agent-project.md"
test -f "$VAULT/90_context_packs/demo-agent-project-start-context.md"

set +e
printf '{"tool_input":{"command":"git reset --hard HEAD"}}' | "$TARGET/.agent-harness/hooks/codex/pre-bash.sh" >/tmp/agent-harness-smoke.out 2>&1
status=$?
set -e
[ "$status" -eq 2 ]

rm -f /tmp/agent-harness-smoke.out /tmp/agent-harness-wiki.out
printf 'Smoke passed\n'
