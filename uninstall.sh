#!/usr/bin/env bash
set -Eeuo pipefail

readonly BOX_NAME="deck-codex-ubuntu-v2"
readonly LAUNCHER="${HOME}/.local/share/applications/chatgpt.desktop"

log() { printf '[deck-codex-kit] %s\n' "$*"; }
box_exists() { distrobox list 2>/dev/null | grep -Fq "${BOX_NAME}"; }

if [[ -f "${LAUNCHER}" ]]; then
  rm -f -- "${LAUNCHER}"
  log "Removed the ChatGPT application launcher."
fi

if command -v distrobox >/dev/null && box_exists; then
  read -r -p "Remove Distrobox ${BOX_NAME} and everything installed inside it? [y/N] " answer
  if [[ "${answer}" == "y" || "${answer}" == "Y" ]]; then
    distrobox rm --force "${BOX_NAME}"
    log "Removed Distrobox ${BOX_NAME}."
  else
    log "Kept Distrobox ${BOX_NAME}."
  fi
fi

if command -v kbuildsycoca6 >/dev/null; then
  kbuildsycoca6 --noincremental >/dev/null 2>&1 || true
fi

log "Uninstall complete."

