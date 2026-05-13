# hooks/

Agent가 도구를 실행하기 **직전·직후**에 자동으로 끼어드는 shell script 모음입니다.
사람이 매번 "이거 하지 마"라고 말하지 않아도 시스템이 막아주는 것이 목적입니다.

## 폴더 구성

- `common/` — 모든 도구가 공유하는 보조 함수 (`lib.sh`)
- `codex/`  — OpenAI Codex CLI 전용 hook
- `claude/` — Claude Code 전용 hook

## 각 hook이 하는 일

| 파일 | 시점 | 차단/실행 |
|---|---|---|
| `pre-bash.sh` | 명령 실행 직전 | 위험 명령 차단 — `rm -rf`, `sudo rm`, `mkfs`, privileged mutation, 위험한 git(`reset --hard`, `clean -fd`, `push --force`), `.env`·credentials·`.ssh`·`.aws`·`.kube` 접근, `git config user.name/email/signingkey` 변경 |
| `pre-file.sh` | 파일 읽기/쓰기 직전 | 민감 파일 경로 접근 차단 |
| `post-edit.sh` | 파일 수정 직후 | Python 파일이면 `ruff check`로 가벼운 lint 수행 |

`pre-bash.sh`는 단일 dispatcher로 위 차단 항목을 한 곳에서 처리합니다. 항목별로 별도 `.sh`를 두지 않은 이유는 각 차단이 매우 짧고, 하나의 진입점에서 결정하는 편이 디버깅과 토큰 비용 양쪽에서 유리하기 때문입니다.

## Cursor는?

Cursor는 shell hook이 항상 실행되지 않으므로, 같은 보호는 `.cursor/rules/*.mdc`의 rule 문장으로 대신 전달됩니다. install.sh가 `--tool cursor`로 설치 시 자동으로 처리합니다.

## 직접 손대지 않는다

이 폴더의 `.sh` 파일은 `install.sh`가 target project의 `.agent-harness/hooks/`로 복사합니다. 동작이 의심되면 `doctor.sh`로 먼저 점검하고, 본문 수정은 fork 후 진행하는 것을 권장합니다.
