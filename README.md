# Refuge Proton Launcher for Linux

Linux launcher scripts for an existing **Return to Morroc: Refuge** client.
This repository contains no game client, patcher, graphics DLL, account data,
or game assets. Each player must already have a lawful copy of the client.

## Requirements

- A working Steam installation and Proton CachyOS SLR compatibility tool.
- The Refuge client directory containing `PRM.exe`, `_RefugePatcher.exe`, and
  `opensetup.exe`.
- Bash, Python 3, and GNU coreutils. The included `prm-laa.py` uses only
  Python's standard library.

On CachyOS, Proton CachyOS SLR can be installed with
`sudo pacman -S proton-cachyos-slr`. On other distributions, install Proton
CachyOS SLR with ProtonUp-Qt and restart Steam. The launcher looks for common
Steam compatibility-tool locations. If yours is elsewhere, set
`REFUGE_PROTON_RUNNER` to its `proton` executable path.

## Install

Download or clone this repository, then run the installer with the path to the
existing client directory:

```bash
git clone https://github.com/Gildedboy/refuge-proton-linux-launcher.git
cd refuge-proton-linux-launcher
bash install-refuge-linux.sh "/path/to/Refuge-Linux"
```

The installer copies only the Linux launch scripts and LAA helper into the
client directory, marks the launchers executable, and creates **Return to
Morroc: Refuge** and **Settings** entries in the user's application menu. It
uses the client folder's existing Linux PNG icons when present, otherwise it
uses generic desktop icons. It does not need administrator access.

The first launch creates a separate `.protonprefix` next to the game files and
sets the client paths in that prefix. The original Windows client files remain
the user's responsibility. Start the game from the patcher. Use the Settings
menu entry to open OpenSetup and change the saved resolution.

Running the installer again updates the launcher scripts and menu entries.
After moving the client folder, run it again so the menu entries use the new
path.

## Files in this repository

- `install-refuge-linux.sh`: copies the support files into an existing client.
- `refuge.sh`, `refuge-patch.sh`: start the patcher, then PRM from its Start
  button.
- `refuge-settings.sh`: opens OpenSetup through Proton.
- `refuge-proton.sh`: direct PRM launch for troubleshooting.
- `refuge-proton-common.sh`: locates Proton, initializes the separate prefix,
  enables D7VK support, and updates the Ragnarok paths.
- `install-linux-shortcuts.sh`: creates per-user application menu entries.
- `prm-laa.py`: applies Large Address Aware to a 32-bit PRM executable and
  keeps a backup before changing it.

## Tested setup

The launcher enables CachyOS Proton's integrated D7VK option. The workflow was
validated with Proton CachyOS SLR: OpenSetup settings persisted and the patcher
launched PRM. The current client also contains local D7VK 2.2, which takes
precedence when present. Other distributions and client revisions may need
adjustments.
