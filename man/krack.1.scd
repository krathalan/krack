krack(1) ["Version 0.4.2"]

# NAME

krack - A set of programs for building, uploading, and receiving packages

# OVERVIEW

"Krack" comprises several programs: krack-build, krack-receive, and krackctl.

Krack-build is designed to run on one computer, which will build packages and send them over rsync to another computer: the receiving computer, where krack-receive runs as a daemon that watches a directory for new packages to add to a pacman repo.

The specific use case krack is built for, is having a PC at home which can build packages, and having a pacman repo hosted on a receiving low-cost, low-power remote VPS.

## KRACK-BUILD

Krack-build is the largest program of the bunch and will run via a systemd unit triggered periodically by a systemd timer on the building PC as a user specifically made for building and sending packages. It will create a directory ~/.local/share/krack/ in the invoking user's home directory. Under this directory, several more are created: 

- logs/, for holding logs automatically created by krack-build;
- packages/, for holding package directories containing PKGBUILDs and other source files (referred to henceforth as the "package directory"); and
- pkgcache/, for holding the latest built packages.

The logs directory will be filled with logs containing the entirety of krack-build's output, including all of makechrootpkg's output. These logs can grow quite large, so krackctl can help you parse these logs easily and get a good feel for the health of your running krack-build instance. You can read more about krackctl in *READING LOGS*.

You should fill the package directory with other directories, each containing PKGBUILDs and other build files, as if just cloned from the AUR. If you have personal packages, you can link them from other directories into krack-build's package directory and it will treat them as any other package.

Krack-build can also handle packages from the Arch Build System, but you will have to checkout the package files outside of the krack-build directory tree and then link the "package/trunk" directory into the krack-build package directory. For example, to build redshift, you could create a directory ~/abs, and then run *asp checkout redshift* inside that directory. Then link the "trunk" directory of that package into the krack-build package directory with *ln -sf ~/abs/redshift/trunk ~/.local/share/krack/packages/redshift*.

The pkgcache directory will contain the latest built package for every package in the package directory, if it has been built at least once.

Immediately after starting krack-build, it will begin the *build cycle*, checking in each package directory if it should build that package.

Krack-build will only initiate an individual package build under three circumstances:

. New commit(s) were pulled in via "git pull"
. The package name ends in "-git"
. The file "krack-request-build" exists in the package's directory

Krack-build will always upload a newly built package, unless a package with the same filename (and therefore version) exists in the local krack-build pkgcache.

After the build cycle is finished, the *sleep cycle* begins. You can customize how long you want krack-build to sleep for by editing the "OnUnitInactiveSec=" option in the krack-build@.timer unit.

## KRACK-RECEIVE

Krack-receive will run as a systemd service (daemon) on the receiving system which hosts a pacman repository. Krack-receive will watch for new packages to add to the specified REPO_ROOT (directory of pacman repository). The path of your pacman repo, as well as the database filename, should be specified in /etc/krack/receive.conf on the receiving PC.

See *man krack-receive* for more details.

## KRACKCTL

Krackctl can be used on the builder PC, as the builder user, to control the running krack-build instance. See *man krackctl* for a full list and explanation of available commands.

# SETUP

## RECEIVER PC

If you haven't yet already, set up a pacman repository at the desired directory on your receiver PC. You can then host this directory with web server software like Nginx or Apache. The instructions for both of these steps are outside the scope of this man page.

After that, you will need to create a user with the username "krack-receive" specifically for receiving packages. Ensure that you can ssh into this user, preferably via keys, from your builder user on the builder PC. Create a directory "package-dropbox" in this user's home directory to act as a dropbox where packages will be rsync'ed to from the building PC. 

*WARNING! You MUST:*

- name the user "krack-receive" or the systemd unit sandboxing will render the unit broken.
- create the dropbox directory at "~/package-dropbox" or krack-receive will not work at all.
- ensure the hosted pacman repository directory and all files within are owned by the krack-receive user/group.

Edit /etc/krack/receive.conf with your specific paths:

- $REPO_ROOT should be where the pacman repo is that you set up earlier.
- $REPO_DB_FILE is the name of the database file for the repo, e.g. reponame.db.tar.

Finally, enable and start krack-receive.service.

## BUILDER PC

First, you will need to enable PAM in your sshd config. Insert or uncomment the following line in /etc/ssh/sshd_config:

UsePAM yes

Enabling PAM is required to instatiate systemd user sessions upon login via ssh, so that the gpg-agent and ssh-agent user services work correctly, for signing and uploading packages respectively. Since UsePAM enables PasswordAuthentication and ChallengeResponseAuthentication by default, ensure you have both set to "no", if you are using keys for authentication (which you should be).

You will need to make an Arch chroot for building packages. You can create one with the command *sudo krackctl create-chroot* on a user on your builder PC with sudo privileges. Alternatively, you can create one manually with the *mkarchroot* command. If you choose to do it manually, make sure to install the ccache package in the chroot.

Next, you will need to create a user specifically for krack-build on the builder PC. You can name this user whatever you want to. You will also need to create a GPG and an ssh key on this user, for signing and uploading packages respectively. Ensure you can ssh from your builder user on your builder PC to your receiving user on your receiving PC. Ensure you can sign files with your new GPG key.

You will need to set up sudo permissions such that your builder user can use makechrootpkg and arch-nspawn (to update the build chroot) without having to enter a password. Additionally, as of devtools-20211129, you must allow your builder user to keep the BUILDTOOL and BUILDTOOLVER environment variables when using sudo. You can do this by adding the following lines to /etc/sudoers:

builder-user ALL=(ALL) NOPASSWD:/usr/bin/makechrootpkg, /usr/bin/arch-nspawn
Defaults:builder-user env_keep += "BUILDTOOL BUILDTOOLVER"

Change "builder-user" in both lines to the name of your builder user you chose earlier.

Finally, you will need to edit /etc/krack/build.conf for your specific setup:

- $MAKECHROOTPKG_DIR is the location of the Arch chroot that will be used to build packages. /var/lib/makechrootpkg is where *sudo krackctl create-chroot* will create the Arch chroot by default.
- $SIGNING_KEY should be the GPG key ID of the signing key you wish to use, in the builder user's keyring that you created earlier.
- $DROPBOX_PATH is the path to the remote PC using rsync HOST syntax, e.g. 173.195.146.142.

## LAST STEP

Krack-build runs automatically via a systemd timer. This is the intended way of using this software. You can start it with the command *sudo systemctl enable --now krack-build@builder-user.timer*. Make sure to replace *builder-user* with the name of your builder user you chose.

If you run *systemctl status krack-build@builder-user.service*, it should be napping, since you haven't added any packages to the krack package directory.

As the builder user, navigate to ~/.local/share/krack/packages. Here you can add package directories, either by cloning from the AUR or copying or linking package directories from somewhere else in your file system. The directory structure should look like this, for example:

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

You can now run *sudo systemctl start krack-build@builder-user.service* wake krack-build up, and it will start building and uploading packages. See *man krackctl* for more commands.

You can now log out of or reboot your builder PC; krack-build will restart on boot and continually re-build packages.

## CHANGING TIME BETWEEN REBUILDS
To change the time that krack-build@.timer takes to re-trigger krack-build@.service, you can add a drop in file at NYI /// NEEDS EDIT /// TODO

You can customize how long you want krack-build to sleep for by editing the "OnUnitInactiveSec=" option in the krack-build@.timer unit.

# OTHER

## READING LOGS

Krack has several useful ways for you to view and parse logs.

You can run *krackctl status* on the builder PC to get a good overview of your current running krack-build instance. Using the built-in log system, it will display the current state (e.g. sleeping, building, ...), the current substate if there is one (e.g. building gimp-git), the latest 10 important messages from most to least recent, the filename of the current log file, and the last 10 lines of raw output from the running krack-build instance. *krackctl watch-status* does the same thing, but refreshes every second and fills the entire terminal.

If krack-build pulls in new commits during the "git pull" part of the build process, it will save the output of the diff between the new commit and the old commit to a file. Diffs can be listed with the command *krackctl list-diffs*.

Each time krack-build starts building a package, it saves the full output of the makechrootpkg command for that package build to a temporary log file. If the makechrootpkg command fails, the temporary file is made permanent at ~/.local/share/krack/logs/failed-builds. Only the latest failed build log is saved for a given package, so if you leave krack unattended for a few build cycles and a package fails to build a few times, you won't be overwhelmed with multiple failure logs.

Failed build logs can be listed with the command *krackctl failed-builds*. You can use your favorite pager to view these files.

You can view the full log files in ~/.local/share/krack/logs. They contain the entire output of the krack-build instance they were generated from, including all makechrootpkg output.

As krack-build runs as a systemd service, you can also use journalctl commands with *-u krack-build@builder-user.service* to view krack-build logs. If you are not seeing krack-build logs in the systemd journal, ensure that you have sufficient permissions for viewing those log entries.

Krack-receive also runs as a systemd service, so you can use journalctl commands with *-u krack-receive* on your receiver PC to view any output.

## BUILD HOOKS

Krack-build supports custom build hooks. The build process for any package happens in the following steps:

. cd into package directory
. \* source krack-prepull.sh, if it exists
. git checkout PKGBUILD, in case the last build of the package changed it in any way
. git pull
. \* source krack-postpull.sh, if it exists
. makechrootpkg
. \* source krack-postbuild.sh, if it exists

You can put any valid Bash in all krack\*.sh scripts, and they will be sourced by krack-build at the indicated step in the build process. These scripts can be used for many things like patching PKGBUILDs or other source files. *But be careful!* Since krack-build is *sourcing* your scripts, if you cd anywhere, krack-build will too. And if you patch files other than the PKGBUILD, make sure to *git checkout* them out again in krack-prepull.sh if you want to avoid build failures when attempting to merge incompatible files during *git pull* in the build process. (However, this is not always desirable -- you may wish to be notified of incompatible files this way if you want to update your patche(s) to accomodate new changes, if these files are not updated frequently enough to be a nuisance.)

These scripts should be placed in the package directory that they are affecting.

## SYSTEMD FEATURES
By using systemd to run krack-build, you can greatly customize how and when the service runs. Perhaps most importantly, you can use systemd to restrict how much of the system resources the krack-build service uses. To add or change the krack-build service, create a directory at */etc/systemd/system/krack-build@.service.d* and add drop-in .conf files. For example, the following file:

*/etc/systemd/system/krack-build@.service.d/restrict-resources.conf*
```
[Service]
AllowedCPUs=0,1
Nice=19
IOSchedulingPriority=7
```

....would restrict krack-build to only the first two logical CPUs and have lower priority process and IO scheduling. This may be useful if you run other services on your builder PC and want to prioritize those services before krack-build. See *man systemd.resource-control* and *PROCESS PROPERTIES* in *man systemd.exec* for other ways to limit system resources.

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

# SEE ALSO
*krackctl*(1), *krack-build*(1)

# BUGS

Please file requests, suggestions, and report any bugs at: https://github.com/krathalan/krack/issues

# LICENSES

All krack programs are licensed under the GPLv3.
