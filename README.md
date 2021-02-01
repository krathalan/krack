# krack
**Kra**thalan's p**ack**aging softwares. A set of programs for:

1) automated building of Arch Linux packages and uploading to a target remote package dropbox, and
2) receiving said packages in said dropbox at the remote location and adding them to a pacman repository.

The specific use case is having a spare PC at home that you possibly use for a media server, but has enough power to compile some programs. You can set up krack to build your desired packages on this PC, and then upload them to a remote of your chosing, perhaps a VPS that you own that hosts a public pacman repository. Then all your Arch devices can pull in package updates without having to build it themselves. Krack can facilitate this process automatically, but takes some setup.

The setup section below explains what the ideal setup for the software will be, not what it currently is. This is a major WIP.

## Setup
### System users
Set up a building user on the builder PC, and a receiving user on the remote PC. Ensure that you can SSH into both accounts, preferably via keys. Ensure that the builder user can SSH into the receiving user.

Your builder user will also need a GPG key for signing packages.

### Pacman repo
Set up a pacman repo on the remote PC at a directory of your choosing.

### Conf files
Then you need to specify these in the conf file at `/etc/krack/build.conf` on the builder PC:

```
#!/usr/bin/env bash
readonly BUILD_USER="builder"
readonly MAKECHROOTPKG_DIR="/var/lib/makechrootpkg"
readonly SIGNING_KEY="1C52FC395F059E60180BB53BCD9097F0E64296BB"
readonly DROPBOX_PATH="krack-receive@krathalan.net:/home/krack-receive/package-dropbox"
```

`$MAKECHROOTPKG_DIR` is where the Arch chroot will live that will be used to build packages. You can specify any directory you like here; Krack will create the Arch chroot for you once you try to build a package. `$SIGNING_KEY` should be the GPG key ID of the signing key you wish to use, in the `$BUILD_USER`'s keyring. `$DROPBOX_PATH` is the path where packages will be pushed to over SSH.

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
You will need tmux installed on the builder PC so that you can leave a session logged in. This is necessary so that ssh-agent and gpg-agent will work for signing and sending packages over SSH.

### Ccache compliance

### Building packages
Krack will create the directories `~/aur` and `~/.cache/ccache` in the builder user's home directory.
