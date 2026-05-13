# WSL Demo

Windows 환경에서 WSL Ubuntu를 열고, Codex/Claude CLI와 `agent-harness-starter`를 적용하는 최소 데모입니다.

## 1. WSL 설치

```powershell
wsl --install -d Ubuntu-22.04
```

설치 후 Ubuntu terminal을 열고 기본 패키지를 설치합니다.

```bash
sudo apt update
sudo apt install -y git curl jq python3 python3-pip
```

## 2. Codex CLI 설치

Codex CLI 설치를 위해 Node.js LTS와 npm을 준비합니다.

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
. "$HOME/.nvm/nvm.sh"
nvm install --lts
node --version
npm --version
```

```bash
npm i -g @openai/codex
codex --version
```

처음 실행할 때 로그인합니다.

```bash
codex
```

## 3. Claude Code 설치

```bash
curl -fsSL https://claude.ai/install.sh | bash
claude --version
claude doctor
```

처음 실행할 때 로그인합니다.

```bash
claude
```

## 4. Starter 적용

데모용 프로젝트 폴더를 만들고 harness를 설치합니다.

```bash
git clone https://github.com/fhekwn549/agent-harness-starter.git
cd agent-harness-starter
mkdir -p ~/demo-agent-project
./install.sh --target ~/demo-agent-project --tool all
./doctor.sh ~/demo-agent-project
```

설치 결과는 target project 안에 생성됩니다.

```text
~/demo-agent-project/
├── AGENTS.md
├── CLAUDE.md
├── .cursor/rules/
└── .agent-harness/
```

## 5. Agent 설정에 연결

Codex는 생성된 snippet을 검토한 뒤 `~/.codex/config.toml`에 필요한 hook 항목을 추가합니다.

```text
~/demo-agent-project/.agent-harness/snippets/codex-config.toml
```

Claude Code는 생성된 settings snippet을 검토한 뒤 `~/.claude/settings.json`에 병합합니다.

```text
~/demo-agent-project/.agent-harness/snippets/claude-settings-hooks.json
```

Cursor는 `.cursor/rules/agent-harness.mdc`가 프로젝트 안에 생성됩니다.

## 6. 사용

프로젝트 폴더에서 원하는 agent를 실행합니다.

```bash
cd ~/demo-agent-project
codex
```

또는:

```bash
cd ~/demo-agent-project
claude
```

이후 agent가 shell command나 파일 작업을 수행할 때 연결된 hook이 위험 명령과 민감 파일 접근을 먼저 검사합니다.
