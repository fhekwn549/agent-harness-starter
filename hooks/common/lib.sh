#!/usr/bin/env bash

is_git_identity_change() {
  printf '%s\n' "$1" | grep -qE '(^|[[:space:];|&])git([[:space:]]+-C[[:space:]]+[^[:space:];|&]+)?[[:space:]]+config[[:space:]]+(--global[[:space:]]+)?user\.(name|email)([[:space:]]|$)'
}

is_rm_rf() {
  printf '%s\n' "$1" | grep -qE '(^|[[:space:];|&])rm[[:space:]]+(-[A-Za-z]*r[A-Za-z]*f|-[A-Za-z]*f[A-Za-z]*r)([[:space:]]|$)'
}

is_destructive_git() {
  local command="$1"
  printf '%s\n' "$command" | grep -qE '(^|[[:space:];|&])git([[:space:]]+-C[[:space:]]+[^[:space:];|&]+)?[[:space:]]+reset[[:space:]][^;|&]*--hard([[:space:];|&]|$)' && return 0
  printf '%s\n' "$command" | grep -qE '(^|[[:space:];|&])git([[:space:]]+-C[[:space:]]+[^[:space:];|&]+)?[[:space:]]+clean[[:space:]][^;|&]*-[^[:space:];|&]*f' && return 0
  printf '%s\n' "$command" | grep -qE '(^|[[:space:];|&])git([[:space:]]+-C[[:space:]]+[^[:space:];|&]+)?[[:space:]]+push[[:space:]][^;|&]*(--force|-f|--force-with-lease)([[:space:];|&]|$)' && return 0
  return 1
}

is_system_mutation() {
  local command="$1"
  printf '%s\n' "$command" | grep -qE '(^|[[:space:];|&])(sudo|su|doas)([[:space:];|&]|$)' && return 0
  printf '%s\n' "$command" | grep -qE '(^|[[:space:];|&])(systemctl|service)[[:space:]]+(start|stop|restart|reload|enable|disable|mask|unmask)([[:space:];|&]|$)' && return 0
  printf '%s\n' "$command" | grep -qE '(^|[[:space:];|&])(apt|apt-get|dnf|yum|pacman|zypper|snap)[[:space:]]+(install|remove|purge|upgrade|dist-upgrade|autoremove)([[:space:];|&]|$)' && return 0
  printf '%s\n' "$command" | grep -qE '(^|[[:space:];|&])chmod[[:space:]][^;|&]*-R[^;|&]*(777|a\+w)[[:space:]]+(/|~|\$HOME)([[:space:]/;|&]|$)' && return 0
  return 1
}

is_secret_path() {
  local path="$1"
  local base
  base="$(basename "$path")"

  case "$path" in
    */.ssh/*|*/.aws/credentials|*/.config/gcloud/application_default_credentials.json|*/.kube/config|*/.docker/config.json)
      return 0
      ;;
  esac

  printf '%s\n' "$base" | grep -qE '^\.env$|^\.env\.(local|development|production|staging|test)$|^\.?credentials(\.json)?$|^secrets?(\..*)?$|^id_(rsa|ed25519|ecdsa|dsa)$|^\.netrc$|^\.npmrc$|^\.pypirc$'
}

command_mentions_secret_path() {
  local command="$1"
  printf '%s\n' "$command" | grep -qE '(^|[[:space:]/])(\.env($|[[:space:]./])|\.ssh/|\.aws/credentials|\.config/gcloud/application_default_credentials\.json|\.kube/config|\.docker/config\.json|\.?credentials(\.json)?($|[[:space:]/])|secrets?(\.[^[:space:]/]+)?($|[[:space:]/])|id_(rsa|ed25519|ecdsa|dsa)($|[[:space:]/])|\.netrc($|[[:space:]/])|\.npmrc($|[[:space:]/])|\.pypirc($|[[:space:]/]))' &&
    ! printf '%s\n' "$command" | grep -qE '\.env\.example|example|template|sample'
}

run_ruff_for_path() {
  local path="$1"
  [ -n "$path" ] || return 0
  [ -f "$path" ] || return 0
  case "$path" in
    *.py) ;;
    *) return 0 ;;
  esac
  command -v ruff >/dev/null 2>&1 || return 0
  ruff check "$path"
}

