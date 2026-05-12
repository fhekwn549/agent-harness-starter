#!/usr/bin/env bash
set -euo pipefail

if command -v powershell.exe >/dev/null 2>&1; then
  powershell.exe -NoProfile -Command "[console]::beep(800,250); [console]::beep(1000,250)" >/dev/null 2>&1 &
else
  printf '\a' >&2
fi

printf '{}\n'

