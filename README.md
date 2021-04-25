# krack

![Image of a running krack-build instance](https://krathalan.net/krack.webp)

**Kra**thalan's p**ack**aging softwares. A set of programs for:

1) automated building of Arch Linux packages and uploading to a target remote package dropbox, and
2) receiving said packages in said dropbox at the remote location and adding them to a pacman repository.

The specific use case is having a spare PC at home that has enough power to compile some programs. You can set up krack to build and upload your desired packages on this PC, and then receive them at a remote PC of your choosing that hosts a pacman repository. Then all your Arch devices can pull in package updates from that remote PC, without having to build them manually on any device.

All of the documentation comes in the form of man pages. You should read them in this order (click to read on Github):

- [`man krack`](man/krack.1.scd)
- [`man krackctl`](man/krackctl.1.scd)
- [`man krack-build`](man/krack-build.1.scd)
- [`man krack-receive`](man/krack-receive.1.scd)

## Features
1. Automated building every user-specified X hours.
2. Ccache compliance for reduced build times and power usage.
3. Per-package hooks, pre/post-gitpull and pre/post-makechrootpkg, for user script execution (for patching PKGBUILDs, config files, etc.)
4. Diffs from `git pull`s are saved and stored for later manual review (with `krackctl list-diffs` and `krackctl review-diffs`).
5. Advanced logging (custom, and optionally systemd) that saves and indexes build failures for easy diagnosis (with `krackctl failed-builds`).
6. Saves last package build times for next new package build reporting (with `krackctl watch-status`).
7. Lets you request package builds (with `kracktl request-build ${pkgname}`) and manage your pending build requests (with `krackctl pending-builds` and `krackctl cancel-all-requests`).
7. Low overhead.

### Outstanding issues
1. No option to auto-import GPG keys for source file verification.
2. No support for non-zstd compressed packages.

## Installation
Install `krack` from the AUR: https://aur.archlinux.org/packages/krack/

## More info
See `man krack`.
