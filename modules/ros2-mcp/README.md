# ROS 2 MCP Module

외부 MCP server를 통해 ROS 2 introspection을 연결하기 위한 optional bridge입니다.

이 module은 ROS MCP 구현체를 vendor하거나 자동 설치하지 않습니다. Workspace와 safety model에 맞는 서버를 사용자가 고른 뒤 wrapper에 연결합니다.

## 권장 사용

이 module은 읽기 중심 ROS inspection에 사용합니다.

- topic, node, service, action 목록 조회
- topic/message/interface metadata 확인
- 작은 topic payload sample 확인
- 선택한 MCP server가 지원하는 경우 TF 또는 bag data 확인

Launch cleanup과 destructive command protection은 hook에 남깁니다. ROS 설계/디버깅 절차는 rules/skills에 남깁니다.

## Safety Defaults

- read-only/introspection tool을 우선합니다.
- topic publish, service call, action goal, robot motion command는 명시적으로 허용하기 전까지 비활성 상태를 유지합니다.
- 선택한 ROS MCP server가 allowlist를 지원하면 allowlist를 사용합니다.
- live robot 또는 simulator에 연결하기 전 `ROS_DOMAIN_ID`를 의도적으로 설정합니다.

## Wrapper

`ros2-mcp-wrapper.sh`는 ROS setup file과 workspace setup file을 source한 뒤 선택된 외부 MCP command를 실행합니다.

필수 environment:

- `ROS2_MCP_COMMAND`: 외부 MCP server를 시작하는 shell command

선택 environment:

- `ROS_DISTRO`: 기본값 `humble`
- `ROS_DOMAIN_ID`: 기본값 `0`
- `ROS_WORKSPACE`: `install/setup.bash`를 source할 workspace
- `ROS2_MCP_READ_ONLY`: 기본값 `1`

예시:

```bash
export ROS_WORKSPACE="$HOME/ros2_ws"
export ROS2_MCP_COMMAND='uv --directory "$HOME/src/ros2_mcp" run mcp_ros_2_server'
.agent-harness/modules/ros2-mcp/ros2-mcp-wrapper.sh
```
