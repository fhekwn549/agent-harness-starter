# Claude ROS 2 MCP Snippet

`claude mcp add-json` 또는 Claude MCP settings UI에 추가하기 전에 path와 command를 검토합니다.

```json
{
  "ros2": {
    "type": "stdio",
    "command": "$PROJECT/.agent-harness/modules/ros2-mcp/ros2-mcp-wrapper.sh",
    "args": [],
    "env": {
      "ROS_DISTRO": "humble",
      "ROS_DOMAIN_ID": "0",
      "ROS2_MCP_READ_ONLY": "1",
      "ROS_WORKSPACE": "$HOME/ros2_ws",
      "ROS2_MCP_COMMAND": "uv --directory $HOME/src/ros2_mcp run mcp_ros_2_server"
    }
  }
}
```
