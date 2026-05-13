# snippets/mcp/

MCP(Model Context Protocol) 서버를 도구별 설정 파일에 **수동으로 붙여 넣는** 예시 snippet 모음입니다. `install.sh`는 이 파일들을 자동으로 도구 설정에 주입하지 않습니다.

## 포함 snippet

| 파일 | 대상 도구 | 붙여 넣을 위치 |
|---|---|---|
| `codex-playwright.toml`   | OpenAI Codex CLI | `~/.codex/config.toml` 끝에 추가 (`[mcp_servers.playwright]` 블록) |
| `claude-playwright.md`    | Claude Code     | 안내에 따라 `claude mcp add` 명령 실행 또는 `~/.claude/settings.json`의 `mcpServers` 블록에 병합 |
| `cursor-playwright.json`  | Cursor          | `.cursor/mcp.json`에 병합 (없으면 새로 생성) |

## 왜 자동 주입을 안 하나

MCP 서버는 외부 프로세스를 실행할 권한을 agent에게 부여합니다. starter가 사용자의 글로벌 설정을 조용히 바꾸면 보안 경계가 흐려지므로, **사용자가 직접 한 번 검토 후 붙여 넣는 것**을 원칙으로 합니다.

## Playwright만 기본 포함하는 이유

API 키나 과금이 필요한 서비스(Firecrawl, Notion 등)는 기본에서 제외했습니다. Playwright는 로컬에서 무료로 동작하고, UI 확인용 MCP의 대표 예시이기 때문에 포함했습니다.
