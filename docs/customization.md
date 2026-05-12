# Customization 가이드

Core는 작게 유지합니다. 로컬 규칙은 package 기본값이 아니라 각 project file에 추가합니다.

좋은 module 후보:

- ROS 2 cleanup
- ROS 2 MCP introspection
- local wiki logging
- notifications
- output style
- auto-stage
- markdown commit policy
- Playwright 같은 browser automation MCP snippet

공개 package에 넣지 말아야 할 것:

- 개인 경로
- private repository 이름
- credentials
- 조직 내부 보고 형식
- 로컬 model preference
- paid 또는 usage-metered integration을 기본 설치 동작으로 만드는 것

## MCP

Starter package는 Playwright MCP snippet만 기본으로 포함합니다. Firecrawl처럼 usage-metered 성격이 있는 서비스는 local opt-in으로 유지해서, 공개 설치가 account-specific setup이나 billing 판단을 요구하지 않게 합니다.

ROS 2 MCP support는 default dependency가 아니라 optional module입니다. 이 module은 wrapper와 client snippet만 설치합니다. 어떤 ROS MCP server를 고를지, workspace path, ROS domain, write permission은 사용자가 직접 통제합니다.

## Markdown Commit Policy

`README.md` 외 `.md` 파일을 기본 commit 대상에서 제외하는 규칙은 긴 지시문보다 hook/auto-stage 정책에 더 가깝습니다. 공개 package 기본값에는 넣지 않고, 필요한 팀이나 개인이 optional module로 추가하는 편이 좋습니다.
