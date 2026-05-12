# Agent Harness Starter

AI coding agent를 안전하게 쓰기 위한 작은 starter package입니다.

이 패키지는 프로젝트 안에 지시문 템플릿, hook script, 설정 snippet, `doctor.sh` 점검 스크립트를 설치합니다. 개인 환경 기본값은 넣지 않고, ROS 2 cleanup, wiki logging, notification, output style 같은 기능은 optional module로 분리합니다.

## 설치

```bash
git clone https://github.com/fhekwn549/agent-harness-starter.git
cd agent-harness-starter
./install.sh --target ~/demo-agent-project --tool codex
./doctor.sh ~/demo-agent-project
```

Cursor:

```bash
./install.sh --target ~/demo-cursor-project --tool cursor
```

선택 module:

```bash
./install.sh --target ~/robot-workspace --tool codex --module ros2-cleanup
./install.sh --target ~/robot-workspace --tool codex --module ros2-mcp
./install.sh --target ~/demo-agent-project --tool codex --module wiki
./install.sh --target ~/app --tool codex --module auto-stage --module output-style
```

선택 MCP snippet:

```text
snippets/mcp/codex-playwright.toml
snippets/mcp/claude-playwright.md
snippets/mcp/cursor-playwright.json
```

기본 MCP snippet은 Playwright만 포함합니다. Firecrawl처럼 API credit이나 과금 판단이 필요한 서비스는 starter package 기본값에서 제외합니다.

## 기본 Guardrail

- `rm -rf` 차단
- `git config user.name/user.email` 변경 차단
- secret 파일 접근 차단
- destructive git 명령 차단: `reset --hard`, `clean -f`, force push
- bypass-style agent session에서 privileged/system mutation 명령 차단
- `ruff`가 있으면 Python 파일 수정 후 `ruff check` 실행

지시문 템플릿은 차단 명령을 길게 반복하지 않습니다. agent에게 hook을 존중하고, 사용자 변경을 보존하고, 프로젝트에 문서화된 명령을 우선하고, 검증 결과를 보고하라고 지시합니다. Cursor는 같은 shell hook이 항상 실행되지 않을 수 있으므로 rule에 보호 동작을 더 명시합니다.

## 설계

Hook은 target project의 `.agent-harness/` 안에 설치됩니다. Installer는 도구별 config snippet을 만들지만, 사용자의 global Codex/Claude 설정을 조용히 수정하지 않습니다.

```text
.agent-harness/
├── hooks/
│   ├── common/
│   ├── codex/
│   └── claude/
├── modules/
└── snippets/
```

## 설치 위치

설치 후 target project는 대략 이렇게 구성됩니다.

```text
demo-agent-project/
├── AGENTS.md
├── CLAUDE.md
├── .cursor/rules/
├── .agent-harness/
│   ├── hooks/
│   │   ├── common/
│   │   ├── codex/
│   │   └── claude/
│   ├── modules/
│   └── snippets/
└── docs/agent-harness/README.md
```

도구별 연결 지점:

| Layer | Codex | Claude Code | Cursor |
|---|---|---|---|
| 지시문 | `AGENTS.md` | `CLAUDE.md` | `AGENTS.md` + `.cursor/rules/*.mdc` |
| Hook | `~/.codex/config.toml` snippet | `settings.json` snippet | 기본은 rule 중심 |
| Skill | `~/.agents/skills`, Codex plugin | `~/.claude/skills`, plugin | skills installer / rules |
| MCP | `mcp_servers.*` | `claude mcp add` / settings | `.cursor/mcp.json` |

실행 흐름:

```text
agent command
-> PreToolUse hook이 위험 명령/파일 접근 차단
-> tool 실행
-> PostToolUse hook이 가벼운 후처리 실행
-> skill이 planning, TDD, review, verification 절차 안내
-> MCP가 docs, browser automation 같은 외부 도구 연결
```

## 공개 패키지 경계

기본 포함하지 않는 것:

- 개인 언어 정책
- 로컬 repository 경로
- ROS-specific cleanup
- ROS MCP server implementation
- markdown commit policy
- Obsidian wiki logging
- private skills
- paid/API-credit based MCP services

## ROS 2 Module

`--module ros2-cleanup`은 다음 파일을 설치합니다.

```text
.agent-harness/modules/ros2-cleanup/check-ros2-processes.sh
.agent-harness/modules/ros2-cleanup/ROS2_RULES.md
```

이 hook은 command gate와 workspace gate를 함께 사용합니다. ROS/Gazebo/RViz launch 계열 명령이고, 현재 위치가 ROS workspace/package로 감지될 때만 process 상태를 확인합니다. Rules file은 ROS 2 작업에서만 읽는 것을 전제로 합니다.

## ROS 2 MCP Module

`--module ros2-mcp`은 외부 ROS 2 MCP server를 연결하기 위한 wrapper와 config snippet을 설치합니다.

```text
.agent-harness/modules/ros2-mcp/ros2-mcp-wrapper.sh
.agent-harness/modules/ros2-mcp/README.md
.agent-harness/snippets/mcp/codex-ros2-mcp.toml
.agent-harness/snippets/mcp/claude-ros2-mcp.md
.agent-harness/snippets/mcp/cursor-ros2-mcp.json
```

이 패키지는 ROS MCP server를 자동 clone/install하지 않습니다. ROS introspection을 read-oriented 용도로 사용할 때만 이 module을 켜고, `ROS2_MCP_COMMAND`를 검토한 서버 명령으로 지정합니다. 후보 예시는 `robotmcp/ros-mcp-server`, `wise-vision/ros2_mcp` 등입니다.

## Wiki Module

`--module wiki`는 Obsidian에서 열 수 있는 LLM wiki scaffold 생성 스크립트를 설치합니다.

```bash
.agent-harness/modules/wiki/init-wiki.sh \
  --vault ~/llm_wiki_vault \
  --project ~/demo-agent-project
```

이 module은 Obsidian을 자동 설치하지 않습니다. 설치는 공식 다운로드 페이지에서 진행합니다.

```text
https://obsidian.md/download
```

생성되는 기본 note:

```text
LLM Wiki Home.md
10_concepts/LLM Wiki Note Types.md
40_project_maps/Project Map - <project>.md
70_work_logs/<project>.md
90_context_packs/<project>-start-context.md
```
