#!/usr/bin/env bash
set -euo pipefail

ROS_DISTRO="${ROS_DISTRO:-humble}"
ROS_DOMAIN_ID="${ROS_DOMAIN_ID:-0}"
ROS2_MCP_READ_ONLY="${ROS2_MCP_READ_ONLY:-1}"

if [ -f "/opt/ros/$ROS_DISTRO/setup.bash" ]; then
  # shellcheck disable=SC1090
  source "/opt/ros/$ROS_DISTRO/setup.bash"
else
  printf 'Missing ROS setup file: /opt/ros/%s/setup.bash\n' "$ROS_DISTRO" >&2
  exit 2
fi

if [ -n "${ROS_WORKSPACE:-}" ]; then
  if [ -f "$ROS_WORKSPACE/install/setup.bash" ]; then
    # shellcheck disable=SC1091
    source "$ROS_WORKSPACE/install/setup.bash"
  else
    printf 'ROS_WORKSPACE is set, but install/setup.bash was not found: %s\n' "$ROS_WORKSPACE" >&2
    exit 2
  fi
fi

export ROS_DOMAIN_ID ROS2_MCP_READ_ONLY
export ROS_LOG_DIR="${ROS_LOG_DIR:-/tmp/agent-harness-ros-logs}"
mkdir -p "$ROS_LOG_DIR"

if [ -z "${ROS2_MCP_COMMAND:-}" ]; then
  printf 'Missing ROS2_MCP_COMMAND. Set it to the external ROS MCP server command.\n' >&2
  exit 2
fi

exec bash -lc "$ROS2_MCP_COMMAND"

