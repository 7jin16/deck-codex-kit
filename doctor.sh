#!/usr/bin/env bash
set -u

readonly BOX_NAME="deck-codex-ubuntu-v2"
readonly LAUNCHER="${HOME}/.local/share/applications/chatgpt.desktop"
passed=0
failed=0
notes=0

check() {
  local label="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    printf 'PASS  %s\n' "${label}"
    passed=$((passed + 1))
  else
    printf 'FAIL  %s\n' "${label}"
    failed=$((failed + 1))
  fi
}

add_note() {
  printf 'NOTE  %s\n' "$*"
  notes=$((notes + 1))
}

is_steamos() {
  [[ -r /etc/os-release ]] || return 1
  (
    # shellcheck source=/dev/null
    source /etc/os-release
    [[ "${ID:-}" == "steamos" || "${VARIANT_ID:-}" == "steamos" ]]
  )
}

has_container_engine() {
  command -v podman >/dev/null || command -v docker >/dev/null
}

box_exists() {
  distrobox list 2>/dev/null | grep -Fq "${BOX_NAME}"
}

printf 'deck-codex-kit doctor\n\n'
check "Linux host" test "$(uname -s)" = Linux
check "x86_64 host" test "$(uname -m)" = x86_64
check "SteamOS host" is_steamos
check "Distrobox installed" command -v distrobox
check "Podman or Docker installed" has_container_engine
check "Git on host" command -v git
check "Ubuntu box exists" box_exists
check "Git in box" distrobox enter "${BOX_NAME}" -- bash -lc 'command -v git'
check "Node in box" distrobox enter "${BOX_NAME}" -- bash -lc 'command -v node'
# HOME is intentionally expanded by the shell inside the Distrobox.
# shellcheck disable=SC2016
check "Codex CLI in box" distrobox enter "${BOX_NAME}" -- bash -lc 'command -v codex || test -x "${HOME}/.local/bin/codex" || test -x "${HOME}/.codex/bin/codex"'
check "ChatGPT app in box" distrobox enter "${BOX_NAME}" -- bash -lc 'command -v chatgpt'
check "/home/deck visible in box" distrobox enter "${BOX_NAME}" -- test -d /home/deck
check "ChatGPT application launcher" test -f "${LAUNCHER}"
check "Launcher enters Distrobox" grep -Fq "Exec=distrobox enter ${BOX_NAME}" "${LAUNCHER}"
check "Launcher icon configured" grep -Fq "Icon=chatgpt" "${LAUNCHER}"

if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
  check "Wayland session" true
else
  add_note "WAYLAND_DISPLAY is not set (expected when running outside Desktop Mode)."
fi

printf '\nSummary: %d passed, %d failed, %d notes\n' "${passed}" "${failed}" "${notes}"
(( failed == 0 ))
