# Troubleshooting

## The installer says a prerequisite is missing

The kit does not install host packages or unlock SteamOS's read-only system image. Confirm that Distrobox, Git, and either Podman or Docker are available:

```bash
command -v distrobox
command -v git
command -v podman || command -v docker
```

## There is not enough free space

A new Ubuntu environment needs at least 2 GiB free; 3 GiB or more is recommended:

```bash
df -h /home/deck
```

Remove unused applications or containers, then retry. To inspect existing containers:

```bash
distrobox list
podman system df
```

## Distrobox cannot start

Check the container engine and existing environments:

```bash
distrobox list
podman info
```

## Codex CLI is missing

Re-run the installer, then verify Codex inside Ubuntu:

```bash
cd ~/.local/share/deck-codex-kit
./install.sh
distrobox enter deck-codex-ubuntu-v2 -- codex --version
```

Codex is installed with OpenAI's official standalone installer.

## ChatGPT does not appear in the application menu

Re-run the installer. It creates a SteamOS-side launcher because KDE may hide Distrobox's automatically exported entry when `TryExec` points to a container-only binary.

```bash
cd ~/.local/share/deck-codex-kit
./install.sh
```

Close and reopen the application launcher, then search for **ChatGPT** rather than looking in Discover.

## ChatGPT opens with many terminal warnings

Electron and D-Bus warnings can appear because ChatGPT runs inside Distrobox. If the ChatGPT window opens and sign-in works, these messages are usually harmless. Run the diagnostic check to verify the installed components:

```bash
cd ~/.local/share/deck-codex-kit
./doctor.sh
```

## Run ChatGPT directly for diagnosis

```bash
distrobox enter deck-codex-ubuntu-v2 -- /usr/bin/chatgpt
```

