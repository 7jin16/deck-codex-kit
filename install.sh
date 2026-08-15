#!/usr/bin/env bash
set -Eeuo pipefail

readonly KIT_VERSION="0.1.0"
readonly BOX_NAME="deck-codex-ubuntu-v2"
readonly MIN_FREE_KB=$((2 * 1024 * 1024))

log() { printf '[deck-codex-kit] %s\n' "$*"; }
warn() { printf '[deck-codex-kit] warning: %s\n' "$*" >&2; }
die() { printf '[deck-codex-kit] error: %s\n' "$*" >&2; exit 1; }
box_exists() { distrobox list 2>/dev/null | grep -Fq "${BOX_NAME}"; }

[[ "${EUID}" -ne 0 ]] || die "Run this script as the deck user, not root."
[[ "$(uname -s)" == "Linux" ]] || die "Linux is required."
[[ "$(uname -m)" == "x86_64" ]] || die "This release supports the x86_64 Steam Deck only."
[[ -r /etc/os-release ]] || die "Cannot identify the host operating system."

# shellcheck source=/dev/null
source /etc/os-release
if [[ "${ID:-}" != "steamos" && "${VARIANT_ID:-}" != "steamos" ]]; then
  warn "This does not look like SteamOS (${ID:-unknown}). Continuing because the host is Linux."
fi
if [[ "${USER:-}" != "deck" && "${HOME:-}" != /home/deck ]]; then
  warn "Expected the Steam Deck user to be deck; detected ${USER:-unknown}."
fi

log "Checking host prerequisites..."
command -v distrobox >/dev/null || die "Distrobox is required on the SteamOS host."
command -v git >/dev/null || die "Git is required on the SteamOS host."
if ! command -v podman >/dev/null && ! command -v docker >/dev/null; then
  die "Distrobox needs Podman or Docker on the SteamOS host."
fi

if box_exists; then
  log "Ubuntu Distrobox already exists: ${BOX_NAME}"
else
  available_kb="$(df -Pk "${HOME}" | awk 'NR == 2 {print $4}')"
  if [[ ! "${available_kb}" =~ ^[0-9]+$ ]] || (( available_kb < MIN_FREE_KB )); then
    die "At least 2 GiB of free space is required before creating the Ubuntu environment."
  fi
  log "Creating Ubuntu Distrobox: ${BOX_NAME}"
  distrobox create --name "${BOX_NAME}" --image ubuntu:24.04 --yes
fi

log "Installing development tools, Codex CLI, and ChatGPT inside ${BOX_NAME}..."
# The variables in this single-quoted script are expanded inside Ubuntu.
# shellcheck disable=SC2016
distrobox enter "${BOX_NAME}" -- bash -lc '
  set -Eeuo pipefail
  sudo apt-get update
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y git curl ca-certificates build-essential nodejs npm bubblewrap

  printf "[deck-codex-kit] Installing Codex CLI...\n"
  curl -fsSL "https://chatgpt.com/codex/install.sh" | sh
  command -v codex >/dev/null || test -x "${HOME}/.local/bin/codex" || test -x "${HOME}/.codex/bin/codex"

  printf "[deck-codex-kit] Installing the ChatGPT Linux app preview...\n"
  if dpkg-query -W -f="\${Status}" chatgpt 2>/dev/null | grep -Fq "ok installed"; then
    sudo apt-get install -y --only-upgrade chatgpt
  else
    trap "rm -f /tmp/chatgpt_amd64.deb" EXIT
    curl -fL "https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest/chatgpt_amd64.deb" -o /tmp/chatgpt_amd64.deb
    sudo apt-get install -y /tmp/chatgpt_amd64.deb
  fi
  command -v chatgpt >/dev/null

  if command -v distrobox-export >/dev/null; then
    distrobox-export --app chatgpt --export-label "ChatGPT" || true
  fi
'

# Distrobox-export can leave TryExec pointing at the container-only binary,
# which makes KDE hide the entry. Keep a host-valid launcher explicitly.
mkdir -p "${HOME}/.local/share/applications"
cat > "${HOME}/.local/share/applications/chatgpt.desktop" <<EOF
[Desktop Entry]
Name=ChatGPT
Comment=ChatGPT desktop app in Ubuntu Distrobox
Exec=distrobox enter ${BOX_NAME} -- /usr/bin/chatgpt %U
TryExec=distrobox
Icon=chatgpt
Terminal=false
Type=Application
Categories=Office;Utility;
StartupWMClass=chatgpt
EOF

if command -v kbuildsycoca6 >/dev/null; then
  kbuildsycoca6 --noincremental >/dev/null 2>&1 || true
fi

log "ChatGPT is registered in the desktop application menu."
log "Setup complete (deck-codex-kit ${KIT_VERSION}). Run ./doctor.sh to verify the workstation."
