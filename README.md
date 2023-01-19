# krack

![Image of a running krack-build instance](https://krathalan.net/krack1.webp)

**Kra**thalan's p**ack**aging softwares. You can think of `krack` as an automated building system for the ABS/AUR, split between two machines: one that builds and sends packages, and one that receives and hosts them.

The specific use case for `krack` is having a spare PC at home that has enough power to compile some programs. You can set up `krack` to build and upload your desired packages on this PC, and then receive them at a remote PC of your choosing that hosts a pacman repository, such as a low-power, inexpensive VPS. Then all your Arch devices can pull in package updates from that repository, without having to build them manually on any device or pay exorbiant fees for a powerful VPS.

All of the **documentation** comes in the form of man pages. Before using `krack`, you should read them in this order (click to read on Github):

- [`man krack`](man/krack.1.scd)
- [`man krackctl`](man/krackctl.1.scd)
- [`man krack-build`](man/krack-build.1.scd)
- [`man krack-receive`](man/krack-receive.1.scd)

## Features
0. GPG package signing.
1. Automated building every user-specified X hours.
2. Ccache compliance for faster build times and power usage.
3. Optional zero config per-package hooks, pre/post-gitpull and pre/post-makechrootpkg, for user script execution (for patching PKGBUILDs, config files, etc.)
4. Diffs from `git pull`s are saved and stored for later manual review (with `krackctl list-diffs` and `krackctl review-diffs`).
5. Advanced logging (custom, and optionally on-by-default systemd) that saves and indexes build failures for easy diagnosis (with `krackctl failed-builds`).
6. Saves last package build times for next new package build reporting (with `krackctl watch-status`).
7. Lets you request package builds (with `kracktl request-build ${pkgname}`) and manage your pending build requests (with `krackctl pending-builds` and `krackctl cancel-all-requests`).
8. Low overhead.
9. Since all krack executables are run as a systemd system service, they restart automatically on reboot and have a number of other advantages, such as being able to limit the amount of system resources they are allowed to use.

### Outstanding issues
1. No option to auto-import GPG keys for source file verification.
2. No support for non-zstd compressed packages.
3. No option to not use GPG package signing.

### Project update goals
1. Change krack-build to run on a systemd @.service/timer
2. Implement a "rebuild" feature that bumps pkgrel by +1. This would have to track external pkgrel bumps until the pkgver increases.

## Installation
Install `krack` from the AUR: https://aur.archlinux.org/packages/krack/

## Contributing
See [`CONTRIBUTING.md`](CONTRIBUTING.md).

## Other similar projects
ABS_CD: https://github.com/bionade24/abs_cd
