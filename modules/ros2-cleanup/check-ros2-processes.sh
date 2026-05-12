#!/usr/bin/env bash
set -euo pipefail

input="$(cat)"
command="$(printf '%s' "$input" | jq -r '.tool_input.command // empty')"

is_ros_command() {
  printf '%s\n' "$command" | grep -qE '^\s*(ros2\s+launch|gzserver|gz\s+sim|rviz2?|gazebo)'
}

is_ros_workspace() {
  local dir="${1:-$PWD}"

  while [ "$dir" != "/" ] && [ -n "$dir" ]; do
    [ -f "$dir/package.xml" ] && return 0
    [ -d "$dir/src" ] && [ -d "$dir/install" ] && return 0
    dir="$(dirname "$dir")"
  done

  return 1
}

is_ros_command || exit 0
is_ros_workspace "$PWD" || exit 0

pattern="ign|gz sim|gzserver|rviz|parameter_bridge|robot_state_pub|move_group|controller_manager|ros2_control_node|spawner|nav2|amcl|planner_server|controller_server|bt_navigator|behavior_server|lifecycle_manager|map_server|ros2.*launch|ros2.*topic|ros2.*action|ign-transport"
remaining="$(pgrep -af "$pattern" 2>/dev/null | grep -v "grep\|claude\|codex\|unattended\|pgrep\|gvfsd" || true)"

if [ -n "$remaining" ]; then
  printf '%s\n' "ROS 2/Gazebo/RViz processes are still running. Stop and verify them before launching:" >&2
  printf '%s\n' "$remaining" >&2
  exit 2
fi

exit 0

