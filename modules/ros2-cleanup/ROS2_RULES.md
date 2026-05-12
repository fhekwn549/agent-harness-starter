# ROS 2 Rules

현재 workspace가 ROS 2 workspace/package이거나, 사용자가 ROS 2 작업을 명시한 경우에만 이 파일을 사용합니다.

## Environment

- 고정 OS나 ROS distribution을 가정하지 않습니다. 환경이 중요하면 `lsb_release -a`와 `printenv ROS_DISTRO`로 확인합니다.
- `ros2 launch`, `gzserver`, `gz sim`, `rviz`, `gazebo` 실행 전 관련 ROS/Gazebo/RViz process를 정리하고 `pgrep`으로 clean 상태를 확인합니다.
- 설치된 ROS cleanup hook을 존중합니다. Hook이 launch를 막으면 남은 process를 보고하고 정리한 뒤 다시 시도합니다.

## Package Structure

- ROS 2 package name은 `snake_case`를 사용합니다.
- 표준 구조를 우선합니다: `package.xml`, `setup.py` 또는 `CMakeLists.txt`, `launch/`, `config/`, `test/`.
- URDF/Xacro 변경은 visual, collision, inertial data를 함께 고려합니다.
- TF tree는 `map -> odom -> base_footprint -> base_link -> sensor/link` 흐름을 중심으로 검토합니다.

## Architecture

- Domain layer는 ROS 2나 infrastructure에 의존하지 않습니다.
- Application layer는 Domain에만 의존합니다.
- Infrastructure layer는 ROS 2 adapter, hardware, persistence, Domain interface 구현을 담당합니다.
- Presentation layer는 CLI, GUI, API, operator surface에서 Application service를 사용합니다.

## Verification

- Unit, integration, launch, e2e check를 구분합니다.
- 변경 위험도에 맞춰 검증 범위를 정합니다.
- `ros2 topic`, `ros2 node`, `ros2 service`, `ros2 action` discovery가 비정상일 때는 DDS, QoS, code defect로 단정하기 전에 sandbox/network limitation을 먼저 확인합니다.
