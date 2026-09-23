# Refuge Proton Launcher for Linux

Linux launcher scripts for an existing **Return to Morroc: Refuge** client.
This repository contains only Linux support scripts and instructions. It does
not provide the game client, `PRM.exe`, patcher, game data, DLLs, account data,
or other game materials; players must obtain those separately.

## Requirements

- Steam installed, with a library directory containing `steamapps`.
- Proton CachyOS SLR installed as a Steam compatibility tool.
- The Refuge client directory containing `PRM.exe`, `_RefugePatcher.exe`, and
  `opensetup.exe`. The folder can have any name; `Refuge-Linux` is only the
  name used for the prepared test copy in this project.
- Bash, Python 3, and GNU coreutils. The included `prm-laa.py` uses only
  Python's standard library.

### CachyOS

If you selected **Install Gaming packages** in CachyOS Hello, the needed packages
should already be installed: `cachyos-gaming-meta` includes
`proton-cachyos-slr`, and `cachyos-gaming-applications` includes Steam. The
official [CachyOS gaming guide](https://wiki.cachyos.org/configuration/gaming/)
documents this setup.

If you did not install those packages, install both with:

```bash
sudo pacman -S cachyos-gaming-meta cachyos-gaming-applications
```

Steam is needed here to provide the Steam installation/runtime path that Proton
uses. The launcher runs Proton directly; the Refuge client itself does not need
to be downloaded from Steam or added to the Steam library. The launcher checks
for a Steam library containing `steamapps` and passes its path to Proton.
By default, it looks for Proton SLR at `/usr/share/steam/compatibilitytools.d/`
and in the usual per-user Steam compatibility-tool folders. Other install
locations need `REFUGE_PROTON_RUNNER` to be set to the Proton executable.

### Other Linux distributions

Install Steam and Proton CachyOS SLR with ProtonUp-Qt, then restart Steam. This
launcher has only been tested on CachyOS; on other distributions the install
location, Steam packaging, dependencies, or window behavior may vary. If the
launcher cannot find Proton, set `REFUGE_PROTON_RUNNER` to its `proton`
executable path. If it cannot find the Steam library, set
`STEAM_COMPAT_CLIENT_INSTALL_PATH` to the Steam directory containing
`steamapps`.

## Install

Download or clone this repository, then run the installer with the path to the
existing client directory. This is the folder containing the game files, not
the folder where you cloned this installer repository. For example, if your
game folder is named `Refuge Client` inside `Games`:

```bash
git clone https://github.com/Gildedboy/refuge-proton-linux-launcher.git
cd refuge-proton-linux-launcher
bash install-refuge-linux.sh "$HOME/Games/Refuge Client"
```

### How to find the client folder path

In your file manager, open the client folder (the one where you can see
`PRM.exe`). Right-click an empty area and choose **Open Terminal Here** if that
option is available. Then run:

```bash
pwd
```

Copy the printed path. It may look like
`/home/alex/Games/Refuge Client`. Use that exact path in the installer command,
with quotation marks around it if it contains spaces:

```bash
bash install-refuge-linux.sh "/home/alex/Games/Refuge Client"
```

If your file manager has no **Open Terminal Here** option, open a terminal and
change directory to the client folder first (`cd `, then drag the folder from
the file manager into the terminal and press Enter). Run `pwd` after that to
confirm you are in the folder containing `PRM.exe`.

The installer copies only the Linux launch scripts and LAA helper into the
client directory, marks the launchers executable, and creates **Return to
Morroc: Refuge** and **Settings** entries in the user's application menu. It
uses the client folder's existing Linux PNG icons when present, otherwise it
uses generic desktop icons. Before copying anything, it checks the client files,
all bundled helpers, Proton SLR, Steam's library path, and write permissions. If
it replaces an existing support script, it saves a one-time `.before-refuge-proton`
backup beside that file; existing menu entries get the same kind of backup.
Missing files or failed prerequisite checks stop the installer before it
replaces the scripts. It does not need administrator access.

The first launch creates a separate `.protonprefix` next to the game files and
sets the client paths in that prefix. The original Windows client files remain
the user's responsibility. Start the game from the patcher. Use the Settings
menu entry to open OpenSetup and change the saved resolution.

Running the installer again updates the launcher scripts and menu entries.
After moving the client folder, run it again so the menu entries use the new
path. The launchers also check their required client files and dependencies
and write access before changing registry values, the prefix, or starting a
Windows program, and print a direct error if something is missing.

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

**Tested only on CachyOS Linux with Proton CachyOS SLR.** OpenSetup saved its
settings and the patcher launched PRM on that system. The launcher enables the
integrated D7VK option; the prepared test client also had a local D7VK 2.2 DLL,
which takes precedence when present. The repository does not include that DLL.

No other Linux distribution has been validated. Results can vary with the
distribution, Steam installation method, Proton build, GPU drivers, desktop
environment, and client revision. The scripts may need changes on another
system.
