krackctl(1) ["Version 0.1.0"]

# NAME

krackctl - Control the running krack-build

# SYNOPSIS

krackctl [*COMMAND*] [_args_]...

# DESCRIPTION

Krackctl gives you insight into the running krack-build instance and gives you some control over its behavior. Krackctl must be run as the same user running krack-build.

# COMMANDS

## Insights

krackctl *pending-builds*
	Lists the number of packages with a 'krack-request-build' file in their package directory. In other words, the list of packages that are guaranteed to be built the next time krack-build checks their up-to-date status.

krackctl *status* _loglines_
	Display the current state of the running krack-build, as well as the latest _loglines_ number of log lines. If you don't specify the number of _loglines_, the latest 10 lines will be displayed.

krackctl *watch-status*
	Runs krackctl status every one second, taking up the entire terminal width and height.

## Control

krackctl *awaken*
	If krack-build is sleeping, this command will wake it up immediately to begin building packages again. The next sleep time will be reset. If krack-build is currently awake, it will wake up immediately after the current build cycle is finished.

krackctl *build-all*
	Creates an empty file 'krack-request-build' in every package directory and clears the krack-build cache. This will force krack-build to build and upload every package the next time krack-build checks for each package's up-to-date status.

krackctl *request-build* _package_
	Creates an empty file 'krack-request-build' in the specified package's directory. This will force krack-build to build it the next time it checks for the package's up-to-date status. However, the rebuilt package will not be uploaded if the rebuilt package matches the name of a preexisting package in the local krack-build cache.

krackctl *cancel-all-requests*
	Deletes any 'krack-request-build' files in all package directories, cancelling any requested guaranteed package builds.

## Miscellaneous

krackctl *create-chroot*
	This command must be run as a user with sudo privileges. This command will create a build chroot at the defined MAKECHROOTPKG_DIR in /etc/krack/build.conf if that directory doesn't exist yet.

# BUGS

Please file requests, suggestions, and report any bugs at: https://todo.sr.ht/~krathalan/krack++
Alternatively, you may send them via email to: ~krathalan/krack@todo.sr.ht

# LICENSES

All krack programs are licensed under the GPLv3.