# deck-codex-kit

> Turn your Steam Deck into a portable ChatGPT and Codex workstation.

The official ChatGPT Linux app is not packaged for SteamOS. OpenAI distributes it for Ubuntu, Debian, and Fedora, while SteamOS is an immutable Arch-based system. Installing those packages directly is not the normal supported path, and unlocking SteamOS's read-only base makes the setup fragile across system updates.

**`deck-codex-kit` is the compatibility bridge.** It creates an Ubuntu 24.04 environment in Distrobox, installs the official ChatGPT Linux app and Codex CLI there, and exposes ChatGPT in the SteamOS application menu like a normal desktop app. Your files remain in the normal Steam Deck home directory.

No unofficial ChatGPT client. No web-app wrapper. No modification of the read-only SteamOS base.

## What it installs

- Ubuntu 24.04 in Distrobox
- Git, Node.js, npm, and build tools
- Codex CLI using OpenAI's official standalone installer
- The official ChatGPT Linux app preview
- A SteamOS application-menu launcher with the ChatGPT icon
- `doctor.sh` for post-install diagnostics

## Requirements

- A Steam Deck in Desktop Mode
- Internet access
- Distrobox, Git, and Podman or Docker available on SteamOS
- At least 2 GiB of free space; 3 GiB or more is recommended
- A configured `deck` user password for commands that require `sudo` inside Ubuntu

## Quick start

Open Konsole in Desktop Mode and run:

```bash
curl -fsSL https://raw.githubusercontent.com/7jin16/deck-codex-kit/main/bootstrap.sh | bash
```

The bootstrap script keeps a copy in `~/.local/share/deck-codex-kit`, runs the installer, and then runs the diagnostic check. If you prefer to inspect the code first, use the manual setup below.

### Manual setup

```bash
git clone https://github.com/7jin16/deck-codex-kit.git
cd deck-codex-kit
./install.sh
./doctor.sh
```

After installation, open the SteamOS application launcher and search for **ChatGPT**. To use Codex CLI:

```bash
distrobox enter deck-codex-ubuntu-v2
codex
```

## Update or uninstall

If you used Quick start:

```bash
cd ~/.local/share/deck-codex-kit
git pull --ff-only
./install.sh
```

To remove the launcher and optionally delete the Ubuntu environment:

```bash
cd ~/.local/share/deck-codex-kit
./uninstall.sh
```

## Project status

Experimental v0.1, developed and validated on a Steam Deck using Codex. See [Architecture](docs/architecture.md) and [Troubleshooting](docs/troubleshooting.md).

This is an unofficial community project and is not affiliated with or endorsed by OpenAI, Valve, or Distrobox. ChatGPT and Codex availability and requirements may change while the Linux app remains in preview.

## Official documentation

- [Codex CLI](https://learn.chatgpt.com/docs/codex/cli)
- [ChatGPT Linux app](https://learn.chatgpt.com/docs/linux/linux-app)

## License

MIT. See [LICENSE](LICENSE).
