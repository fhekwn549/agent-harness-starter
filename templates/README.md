# templates/

각 도구가 세션 시작 시 자동으로 읽는 **지시문 템플릿** 모음입니다. `install.sh`가 target project로 복사합니다.

## 파일 구성

| 파일 | 대상 도구 | 역할 |
|---|---|---|
| `AGENTS.md`             | OpenAI Codex CLI / Cursor | Codex가 자동으로 읽는 진입점 |
| `CLAUDE.md`             | Claude Code               | Claude Code가 자동으로 읽는 진입점 |
| `common-agent-rules.md` | 공통                       | 두 진입점이 공유하는 규칙 본체 |
| `cursor/`               | Cursor                    | `.cursor/rules/*.mdc` 형태의 Cursor 전용 rule |

## 합쳐지는 방식

- `AGENTS.md`와 `CLAUDE.md`는 본문이 **거의 같습니다.** 도구가 자동으로 읽는 파일명만 다를 뿐, 안에 적은 규칙은 동일합니다.
- 공통 규칙은 `common-agent-rules.md`에 한 번만 적고, 두 진입점에서 *"공통 규칙은 `common-agent-rules.md`를 따른다"*고 참조해 중복을 줄이는 패턴을 권장합니다.
- Cursor는 shell hook이 항상 실행되지 않으므로 `cursor/`의 `.mdc` rule에 보호 동작이 한 번 더 명시되어 있습니다.

## 사용자가 손대는 영역

각 template 끝의 **`## Project Notes`** 섹션이 사용자 customization 자리입니다. 빌드/테스트/도메인 규칙은 이 아래에 추가합니다. 그 위 본문(Hook 보호 / Agent 책임 / Planning)은 starter가 보장하는 최소 규칙이므로 가급적 수정하지 않습니다.

## 개인 정책은 여기 두지 않습니다

응답 언어, 한글 폰트, 커밋 메시지 스타일, 출력 길이 같은 **개인 작업 방식**은 starter template이 아니라 사용자 글로벌 위치(`~/.codex/AGENTS.md`, `~/.claude/CLAUDE.md`)에 둡니다. p9 "범용 vs 개인 분리" 원칙입니다.
