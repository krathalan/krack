# krack

![Image of a running krack-build instance](https://krathalan.net/krack-build.webp)

**Kra**thalan's p**ack**aging softwares. A set of programs for:

1) automated building of Arch Linux packages and uploading to a target remote package dropbox, and
2) receiving said packages in said dropbox at the remote location and adding them to a pacman repository.

The specific use case is having a spare PC at home that has enough power to compile some programs. You can set up krack to build and upload your desired packages on this PC, and then receive them at a remote PC of your choosing that hosts a pacman repository. Then all your Arch devices can pull in package updates from that remote PC, without having to build them manually on any device.

All of the documentation comes in the form of man pages. `man krack` is the main one, but there are man pages for each Krack program.

## Features
1. Automated building every user-specified X hours.
2. Ccache compliance for reduced build times and power usage.
3. Per-package pre/post-gitpull and pre/post-makechrootpkg user script execution.
4. Diffs from `git pull`s are saved and stored for later manual review.
5. Advanced logging (homegrown and systemd) that saves and indexes build failures for easy diagnosis.
6. Low overhead.

### Outstanding issues
1. No option to auto-import GPG keys for source file verification.

## Installation
Install `krack` from the AUR: https://aur.archlinux.org/packages/krack/

## More info
See `man krack`.
