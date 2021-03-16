krack(1) ["Version 0.1.0"]

# NAME

krack - A set of programs for building, uploading, and receiving packages

# OVERVIEW

"Krack" comprises several programs: krack-build, krack-receive, and krackctl.

Krack-build is designed to run on one computer, which will build packages and send them over rsync to another computer: the receiving computer, where krack-receive runs as a daemon that watches a directory for new packages to add to a pacman repo.

The specific use case krack is built for, is having a PC at home which can build packages, and having a pacman repo hosted on a receiving low-cost, low-power remote VPS.

## KRACK-BUILD

Krack-build is the largest program of the bunch and will run on an open tmux instance on the building PC as a user specifically made for building and sending packages. It will create a directory ~/.local/share/krack in the invoking user's home directory. Under this directory, several more are created: logs, for holding logs automatically created by krack-build; packages, for holding package directories containing PKGBUILDs and other source files, and pkgcache, for holding the latest built packages.

The logs directory will be filled with logs containing the entirety of krack-build's output, including all of makechrootpkg's output. These logs can grow quite large, so krackctl can help you parse these logs easily and get a good feel for the health of your running krack-build instance.

You should fill the packages directory with other directories, each containing PKGBUILDs and other build files, as if just cloned from the AUR. If you have personal packages, you can link them from other directories into krack-build's package directory and it will treat them as any other package.

The pkgcache directory will contain the latest built package for every package in the package directory, if it has been built at least once.

Immediately after starting krack-build, it will begin the *build cycle*, checking in each package directory if it should build that package.

Krack-build will only initiate an individual build under three circumstances:

. New commit(s) were pulled in via "git pull"
. The package name ends in "-git"
. The file "krack-request-build" exists in the package's directory

Krack-build will always upload a newly built package, unless a package with the same filename (and therefore version) exists in the local krack-build pkgcache.

After the build cycle is finished, the *sleep cycle* begins, lasting for the defined number of SLEEP_HOURS in /etc/krack/build.conf.

## KRACK-RECEIVE

Krack-receive will run as a system daemon on the receiving system which hosts a pacman repository. Krack-receive will watch the specified DROPBOX_PATH for new packages to add to the specified REPO_ROOT (directory of pacman repository). The path of these directories should be specified in /etc/krack/receive.conf on the receiving PC.

See *man krack-receive* for more details.

## KRACKCTL

Krackctl can be used on the builder PC as the builder user to control the running krack-build instance. See *man krackctl* for a full list and explanation of available commands.

# SETUP

## RECEIVER PC

Set up a pacman repository at the desired directory on your receiver PC. You can then host this directory with web server software like Nginx or Apache. The instructions for both of these steps are outside the scope of this man page.

After that, you will need to create a user specifically for receiving packages. Ensure that you can ssh into this user, preferably via keys. Create a directory in this user's home directory to act as a dropbox where packages will be rsync'ed to from the building PC.

Edit /etc/krack/receive.conf with your specific paths.

- $REPO_ROOT should be where the pacman repo is that you set up earlier.
- $REPO_DB_FILE is the name of the database file for the repo (e.g. reponame.db.tar).
- $DROPBOX_PATH is where you will be sending packages; this should be the same directory you created earlier in the user's home directory.

Finally, enable and start krack-receive.service.

## BUILDER PC

You will need to create a user specifically for krack-build on the builder PC. You will also need to create a GPG and an ssh key on this user, for signing and uploading packages respectively. Ensure you can ssh from your builder user on your builder PC to your receiving user on your receiving PC. Ensure you can sign files with your new GPG key.

You will need to set up sudo permissions such that your builder user can use makechrootpkg and arch-nspawn (to update the build chroot) without having to enter a password. You can do this with the following line in /etc/sudoers:

builder-user ALL=(ALL) NOPASSWD:/usr/bin/makechrootpkg, /usr/bin/arch-nspawn

Change "builder-user" to whatever the name of your builder user is on the builder PC.

Finally, you will need to edit /etc/krack/build.conf for your specific setup.

- $MAKECHROOTPKG_DIR is where the Arch chroot will live that will be used to build packages. You can specify any directory you like here. /var/lib/makechrootpkg is a safe default.
- $SIGNING_KEY should be the GPG key ID of the signing key you wish to use, in the builder user's keyring that you created earlier.
- $DROPBOX_PATH is the path where packages will be rsynced to the receiving user on the remote PC: e.g. receiver-user@173.195.146.142:/home/receiver-user/drop.
- $LOG_SETTING controls where krack-build will send its output. Note that you cannot disable classic logging, but you can disable systemd journal logging.

## LAST STEP

You are now ready to run krack-build on your builder PC. SSH into the builder user from a personal computer. Create a tmux session and run *krack-build*. It should immediately start napping, since you haven't added any packages to the krack package directory.

Detach from the tmux session and navigate to ~/.local/share/krack/packages. Here you can add package directories, either by cloning from the AUR or copying or linking package directories from somewhere else in your file system. The directory structure should look like this:

```
~/.local/share/krack/packages/
 |
  \\-- babl-git/
      |-- PKGBUILD
 |
  \\-- gegl-git/
      |-- PKGBUILD
      |-- example.install
 |
  \\-- gimp-git/
      |-- PKGBUILD
      |-- ...
```

You can now run *krackctl awaken* to wake krack-build up in the detached tmux session to start building packages. See *man krackctl* for more commands.

# OTHER

## READING LOGS

Krack has several useful ways for you to view and parse logs. By default, krack-build will log to the systemd journal as well as using its own log system. You can disable systemd journal logging, but not the built-in log system.

You can run *krackctl status* on the builder PC to get a good overview of your current running krack-build instance. Using the built-in log system, it will display the current state (e.g. sleeping, building, ...), the current substate if there is one (e.g. building gimp-git), the latest 10 errors from most to least recent, the filename of the current log file, and the last 10 lines of raw output from the running krack-build instance. *krackctl watch-status* does the same thing, but refreshes every second and fills the entire terminal height.

You can also view the raw log files in ~/.local/share/krack/logs. They contain the entire output of the krack-build instance they were generated from, including all makechrootpkg output.

You can also use journalctl to view and parse messages krack-build has sent to the system journal. Run *journalctl -t krack-build* to view all the log entries. Krack-build will only output info and error messages to the journal; no other output (such as from makechrootpkg) will be output here. You can run *journalctl -t krack-build -p err* to view all entries classified as an error; this will list all of the failed package builds. You can combine any of these options and more with the *-f* option for journalctl to tail the log. See *man journalctl* for more options.

If you are not seeing krack-build logs in the systemd journal, ensure that systemd logging is enabled in /etc/krack/build.conf, and ensure that you have sufficient permissions for viewing those log entries.

Krack-receive runs as a systemd service, so you can use any valid journalctl commands with *-u krack-receive* on your receiver PC to view any output.

## BUILD HOOKS

Krack-build supports custom build hooks. The build process for any package happens in the following steps:

. cd into package directory
. source krack-prepull.sh, if it exists
. git checkout PKGBUILD, in case the last build of the package changed it in any way
. git pull
. source krack-postpull.sh, if it exists
. makechrootpkg
. source krack-postbuild.sh, if it exists

You can put any valid Bash in all krack\*.sh scripts, and they will be sourced by krack-build at the indicated step in the build process. These scripts can be used for many things like patching PKGBUILDs or other source files. *But be careful!* Since krack-build is *sourcing* your scripts, if you cd anywhere, krack-build will too.

These scripts should be placed in the package directory that they are affecting.

## CCACHE COMPLIANCE

If ccache is enabled in the builder PC's /etc/makepkg.conf and the builder PC's $MAKECHROOTPKG_DIR/root/etc/makepkg.conf, and the ccache package is installed on both the builder PC and the builder PC's $MAKECHROOTPKG_DIR/root, krack-build will handle creating and binding the CCACHE_DIR on both the builder PC and chroot. Krack-build will create the directory ~/.cache/ccache in the builder user's home directory for this purpose.

## SSH SETTINGS

If your receiver PC's sshd uses a custom port, you can specify it in ~/.ssh/config on the builder user. For example:

```
~/.ssh/config
-------------
Host krathalan.net
        Port 37457
Host 168.200.255.199
        Port 9238
```

# BUGS

Please file requests, suggestions, and report any bugs at: https://todo.sr.ht/~krathalan/krack++
Alternatively, you may send them via email to: ~krathalan/krack@todo.sr.ht

# LICENSES

All krack programs are licensed under the GPLv3.
