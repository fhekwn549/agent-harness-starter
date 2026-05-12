# Claude Project 지시문

## Agent 운영 규칙

### Hook으로 보호되는 동작

Harness는 secret access, git identity 변경, destructive shell command, destructive git command, privileged system mutation을 차단할 수 있습니다.

- 설치된 hook을 우회, 비활성화, 약화하지 않습니다.
- Hook이 작업을 막으면 차단된 동작을 설명하고, 필요한 경우 사용자가 직접 실행하거나 승인할 정확한 command를 제시합니다.
- Secret이나 environment variable은 실제 파일 대신 example/template file을 사용합니다.

### Agent 책임

- 사용자 변경을 보존합니다. 명시 요청 없이는 직접 수정하지 않은 파일을 되돌리지 않습니다.
- 새 workflow를 임의로 만들기보다 project-local script와 문서화된 command를 우선합니다.
- 도메인별 작업에서는 계획/수정 전에 `.agent-harness/modules/` 아래의 관련 module rule을 읽습니다.
- 완료 전 가능한 가장 좁은 관련 검증 command를 실행합니다.
- 검증을 실행할 수 없으면 이유와 남은 risk를 말합니다.
- 마지막에는 변경 파일과 검증 결과를 요약합니다.

### 계획

- 작고 명확한 변경은 바로 진행하고 짧게 보고합니다.
- 애매하거나 위험한 작업은 편집 전에 목표, 제약, acceptance criteria, 검증 방법을 확인합니다.
- 여러 단계 구현은 파일, command, 예상 check를 포함한 짧은 plan을 작성합니다.

## Project Notes

Project-specific build, test, style, domain rule은 이 아래에 추가합니다.
