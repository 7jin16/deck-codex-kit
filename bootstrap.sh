#!/usr/bin/env bash
set -Eeuo pipefail

readonly REPOSITORY="https://github.com/7jin16/deck-codex-kit.git"
readonly INSTALL_DIR="${DECK_CODEX_KIT_DIR:-${HOME}/.local/share/deck-codex-kit}"

die() { printf '[deck-codex-kit] error: %s\n' "$*" >&2; exit 1; }

command -v git >/dev/null || die "Git is required on the SteamOS host."

if [[ -d "${INSTALL_DIR}/.git" ]]; then
  printf '[deck-codex-kit] Updating the existing setup kit...\n'
  git -C "${INSTALL_DIR}" pull --ff-only
elif [[ -e "${INSTALL_DIR}" ]]; then
  die "${INSTALL_DIR} already exists but is not a deck-codex-kit Git checkout."
else
  printf '[deck-codex-kit] Downloading the setup kit...\n'
  mkdir -p "$(dirname -- "${INSTALL_DIR}")"
  git clone --depth 1 "${REPOSITORY}" "${INSTALL_DIR}"
fi

cd "${INSTALL_DIR}"
chmod +x install.sh doctor.sh uninstall.sh
./install.sh
./doctor.sh

