# WSL Demo

```powershell
wsl --install
```

Ubuntu 안에서 실행:

```bash
git clone https://github.com/fhekwn549/agent-harness-starter.git
cd agent-harness-starter
mkdir -p ~/demo-agent-project
./install.sh --target ~/demo-agent-project --tool codex
./doctor.sh ~/demo-agent-project
```

생성된 Codex snippet을 확인합니다.

```text
~/demo-agent-project/.agent-harness/snippets/codex-config.toml
```

내용을 검토한 뒤 Codex config에 추가합니다.
