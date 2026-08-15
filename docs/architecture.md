# Architecture

`deck-codex-kit` keeps the SteamOS host small and puts development dependencies and the ChatGPT Linux app in an Ubuntu Distrobox.

```text
SteamOS host
├── Distrobox + Podman/Docker
├── ~/.local/share/applications/chatgpt.desktop
│   └── launches ChatGPT through distrobox enter
└── Ubuntu 24.04 container: deck-codex-ubuntu-v2
    ├── Git, Node.js, npm, and build tools
    ├── Codex CLI
    └── ChatGPT Linux app preview
```

SteamOS's read-only system image is not modified. Distrobox shares the user's home directory with Ubuntu, so projects under `/home/deck` are available to both SteamOS and Codex.

The host-side launcher is intentional. Distrobox's generated launcher can contain `TryExec=/usr/bin/chatgpt`; because that binary exists only inside Ubuntu, KDE may hide it. The kit writes a launcher whose host-visible executable is `distrobox`.

The bootstrap checkout is stored at `~/.local/share/deck-codex-kit` so the installation can be updated, diagnosed, or removed later.

