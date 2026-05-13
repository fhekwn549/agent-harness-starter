# modules/

`install.sh --module <이름>`으로 **선택적으로 켜는 확장**입니다. 기본 설치에는 포함되지 않고, 필요할 때만 켜서 불필요한 규칙이 agent context에 섞이지 않도록 합니다.

## 모듈 목록

| 모듈 | 한 줄 설명 | 켜는 명령 |
|---|---|---|
| `auto-stage` | 파일 수정 직후 변경된 파일을 자동으로 `git add` (커밋은 안 함) | `--module auto-stage` |
| `notifications` | 세션 종료/도구 완료 시 데스크탑 알림 표시 | `--module notifications` |
| `output-style` | 짧고 일관된 응답 톤(`SHORT_OUTPUT.md`)을 agent에게 주입 | `--module output-style` |
| `ros2-cleanup` | ROS 2/Gazebo/RViz 작업 시 좀비 프로세스 정리 + `ROS2_RULES.md` 로드 | `--module ros2-cleanup` |
| `ros2-mcp` | 외부 ROS 2 MCP server 연결을 위한 wrapper와 snippet (서버 자동 설치 X) | `--module ros2-mcp` |
| `wiki` | Obsidian으로 열 수 있는 LLM wiki vault scaffold 생성기 | `--module wiki` |

## 언제 켤까

- 모든 환경에 필요한 것이 아니라면 **켜지 않습니다**. p9 "범용 vs 개인 분리" 원칙.
- ROS 2 작업이 아니면 `ros2-*` 두 모듈은 켜지 않습니다.
- `wiki`는 Obsidian([https://obsidian.md](https://obsidian.md))을 직접 설치한 사람만 의미가 있습니다.

상세 사용법은 각 모듈 폴더 안의 README나 본문 주석을 참고하세요.
