# Wiki Module

Obsidian에서 열 수 있는 LLM wiki vault 구조를 만드는 optional module입니다.

이 module은 Obsidian을 자동 설치하지 않고, 자동 logging도 켜지 않습니다. 공개 package에서는 안전한 scaffold만 제공합니다.

## Obsidian 설치

Ubuntu/WSL GUI 환경에서 AppImage 또는 `.deb`를 사용할 수 있습니다.

```bash
# 예시: 공식 사이트에서 .deb를 받은 뒤 설치
sudo apt install ./obsidian_<version>_amd64.deb
```

공식 다운로드:

```text
https://obsidian.md/download
```

설치 확인:

```bash
obsidian --version
```

## Wiki 생성

```bash
.agent-harness/modules/wiki/init-wiki.sh \
  --vault ~/llm_wiki_vault \
  --project ~/demo-agent-project
```

Project 이름을 직접 지정할 수도 있습니다.

```bash
.agent-harness/modules/wiki/init-wiki.sh \
  --vault ~/llm_wiki_vault \
  --project ~/demo-agent-project \
  --name demo-agent-project
```

## 생성 구조

```text
llm_wiki_vault/
├── LLM Wiki Home.md
├── 00_inbox/
├── 10_concepts/
│   └── LLM Wiki Note Types.md
├── 20_decisions/
├── 30_playbooks/
├── 40_project_maps/
│   └── Project Map - <project>.md
├── 70_work_logs/
│   └── <project>.md
├── 85_plans/
└── 90_context_packs/
    └── <project>-start-context.md
```

## Agent 사용 예시

```text
~/llm_wiki_vault/90_context_packs/<project>-start-context.md 를 먼저 읽고,
project map과 최근 work log를 바탕으로 오늘 할 일을 정리해줘.
그 다음 필요한 skill을 고르고 실행 plan을 제안해줘.
```

## 의도적으로 제외한 것

- commit/push hook 기반 자동 logging
- session transcript 자동 저장
- private Obsidian vault path
- 개인 repo 이름
- 조직 내부 보고 형식

이 기능들은 필요할 때 별도 local module로 추가하는 편이 안전합니다.
