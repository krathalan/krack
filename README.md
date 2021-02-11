# krack
**Kra**thalan's p**ack**aging softwares. A set of programs for:

1) automated building of Arch Linux packages and uploading to a target remote package dropbox, and
2) receiving said packages in said dropbox at the remote location and adding them to a pacman repository.

The specific use case is having a spare PC at home that you possibly use for a media server, but has enough power to compile some programs. You can set up krack to build your desired packages on this PC, and then upload them to a remote of your choosing (perhaps a VPS that you own that hosts a public pacman repository). Then all your Arch devices can pull in package updates without having to build it themselves. Krack can facilitate this process automatically, but takes some setup.

The setup section below explains what the ideal setup for the software will be, not what it currently is. This is a major WIP.

## Setup
### System users
Set up a building user on the builder PC, and a receiving user on the remote PC. Ensure that you can SSH into both accounts, preferably via keys. Ensure that the builder user can SSH into the receiving user.

Your builder user will also need a GPG key for signing packages.

You will also need to set up sudo permissions for your builder user to be able to use `makechrootpkg` without having to enter a password. You can do this by inserting this into `/etc/sudoers`:

```
builder-user ALL=(ALL) NOPASSWD:/usr/bin/makechrootpkg
```

Change `builder-user` to whatever the name of your builder user is.

### Pacman repo
Set up a pacman repo on the remote PC at a directory of your choosing.

### Conf files
Then you need to specify these in the conf file at `/etc/krack/build.conf` on the builder PC:

```
#!/usr/bin/env bash
readonly MAKECHROOTPKG_DIR="/var/lib/makechrootpkg"
readonly SIGNING_KEY="1C52FC395F059E60180BB53BCD9097F0E64296BB"
readonly DROPBOX_PATH="krack-receive@krathalan.net:/home/krack-receive/package-dropbox"
```

`$MAKECHROOTPKG_DIR` is where the Arch chroot will live that will be used to build packages. You can specify any directory you like here; Krack will create the Arch chroot for you once you try to build a package. `$SIGNING_KEY` should be the GPG key ID of the signing key you wish to use, in the `$BUILD_USER`'s keyring. `$DROPBOX_PATH` is the path where packages will be pushed to over SSH to the receiving user on the remote PC.

And in the conf file `/etc/krack/receive.conf` on the remote PC:

```
#!/usr/bin/env bash
readonly REPO_ROOT="/var/www/builds/x86_64"
readonly REPO_DB_FILE="krathalan.db.tar"
readonly DROPBOX_PATH="/home/krack-receive/package-dropbox"
```

The `$REPO_ROOT` should be where the pacman repo is you wish to push packages to. `$REPO_DB_FILE` is the name of the database file for the repo. Finally `$DROPBOX_PATH` is where you will be sending packages; this should be the same path as `$DROPBOX_PATH` in the previous file, but without the preceding SSH user/IP.

### UsePAM
On the builder PC, make sure you have UsePAM set to yes in `/etc/ssh/sshd_config`:

```
UsePAM yes
```

This will make systemd instatiate user sessions upon login via SSH. This will allow the builder user to run ssh-agent and gpg-agent for signing and uploading packages. Make sure to restart `sshd.service`.

Set up ssh-agent on the builder user. More information here: https://wiki.archlinux.org/index.php/SSH_keys#Start_ssh-agent_with_systemd_user

### Tmux
You will need tmux installed on the builder PC so that you can leave a session logged in. This is necessary so that ssh-agent and gpg-agent will work for signing and sending packages over SSH. It also lets you easily attach to the running `krack-build` instance.

### Ccache compliance
Krack will install the `ccache` package into the Arch chroot when it is created, and will handle binding the `$CCACHE_DIR` from your build user's home directory to the chroot for building. Krack depends on `ccache` on the builder PC and in the build chroot. If you point Krack to a build chroot you already have, make sure it has `ccache` installed.

### Building packages
Krack will create the directories `~/.local/share/krack` and `~/.cache/ccache` in the builder user's home directory. `~/.cache/ccache` will be bound to the build chroot at build time. 

You should fill `~/.local/share/krack/packages` with directories containing PKGBUILDS and other build files, as if just cloned from the AUR. You can do this manually:

```
$ cd ~/.local/share/krack/packages
$ git clone https://aur.archlinux.org/packagename.git
```

Put as many package directories as you like in here.

If you keep a personal git repository of package directories, simply create a link (`ln -s`) to each package directory in `~/.local/share/krack/packages`.

### Requesting package builds
Simply:

> `$ touch krack-request-build`

in the directory of the package you wish to build next time `krack-build` wakes up, and it will be built regardless of update status. The file will be deleted the next time the package is built.

Keep in mind that `*-git` packages are always rebuilt upon wakeup. Also note that `krack-build` won't send the packages over `rsync` if there's already a package with the same name in `~/.local/share/krack/cache`.

### Build hooks
Krack supports pre-pull, post-pull, and post-build actions. Pre-pull actions occur before the `PKGBUILD` is checked out and a `git pull` is performed; post-pull happens after that. Post-build occurs after `makechrootpkg` has finished building the package.

Simply create scripts in package directories with the appropriate names:

- `krack-prepull.sh`
- `krack-postpull.sh`
- `krack-postbuild.sh`

You can put whatever valid shell you want into these scripts. Krack will `source` them at the indicated point in time.

These script files can live in the package builds safely and will survive git pulls and rebuilds.

`krack-postpull.sh` specifically is useful for applying custom patches to PKGBUILDs.

Keep in mind that Krack will check for a `krack-request-build` file immediately after the `krack-postpull.sh` script. If you are `cd`-ing in your Krack scripts, ensure that the `krack-request-build` file is in the final package directory after both `krack-prepull.sh` and `krack-postpull.sh` to have Krack acknowledge your build request.

### Logs
`krack-build` will create a log each time it is invoked containing its output. These logs are kept in `~/.local/share/krack/logs`.

### krack-build options
```
--start-asleep   Starts krack-build as if it had just finished building
                 packages. Useful after updating Krack.
```

### Commands
These commands must be ran as the builder user.
```
$ krackctl create-chroot  Creates the Arch chroot for makechrootpkg to build
                          packages in.
                          
$ krackctl status  Prints the current status of the running krack-build.

$ krackctl awaken  Wakes krack-build up to start building packages immediately.
                   Resets the next build time. If Krack is currently building
                   packages, builds will start immediately again after Krack is
                   finished with the current set.

$ krackctl build-all  Touches krack-request-build in every package directory,
                      forcing all builds the next time krack-build wakes up.
                      Also clears the krack-build package cache.
```