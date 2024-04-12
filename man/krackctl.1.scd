krackctl(1) ["Version 0.4.2"]

# NAME

krackctl - Control the running krack-build

# SYNOPSIS

krackctl [*COMMAND*] [_args_]...

# DESCRIPTION

Krackctl gives you insight into the running krack-build instance and gives you some control over its behavior. *Krackctl must be run as the same user running krack-build.*

# COMMANDS

## Insights

krackctl *failed-builds*
	Lists all of the failed build logs. You can use your favorite pager to view these logs.

krackctl *list-diffs*
	Lists all of the diffs from git pulls in package directories.

krackctl *review-diffs*
	Review each diff file with *bat* if installed, otherwise use $PAGER or fall back to *less*. Then asks the user if they want to delete all diff files.

krackctl *pending-builds*
	Lists the number of packages with a 'krack-request-build' file in their package directory. In other words, the list of packages that krack guarantees to attempt to build during the next build cycle.

krackctl *stats* _packages_
	Prints stats (average build time, number of times built, etc.) for specified packages. If no packages are specified, prints stats for all packages.

krackctl *status* _loglines_
	Display the current state of the running krack-build, as well as the latest _loglines_ number of log lines. If you don't specify the number of _loglines_, the latest 10 lines will be displayed. If the krack-build service is not running, this command will display a summary of the last build cycle.

krackctl *watch-status*
	Runs 'krackctl status' every two seconds (by default), filling the entire terminal. You can change how often the command will refresh by changing the KRACKCTL_WATCHSTATUS_INTERVAL value in /etc/krack/build.conf.

## Control

krackctl *build-all*
	Creates an empty file 'krack-request-build' in every package directory and clears the krack-build package cache. This will force krack-build to attempt to build and upload every package during the next build cycle.

krackctl *request-build* _package_
	Creates an empty file 'krack-request-build' in the specified package's directory. This will force krack-build to attempt to build it during the next build cycle. However, the rebuilt package will not be uploaded if the rebuilt package filename matches the filename of a preexisting package in the local krack-build cache.

krackctl *cancel-all-requests*
	Deletes all 'krack-request-build' files in all package directories, cancelling all requested package builds.

## Miscellaneous

krackctl *create-chroot*
	This command must be run as a user with sudo privileges. This command will create a build chroot at the defined MAKECHROOTPKG_DIR in /etc/krack/build.conf if that directory doesn't exist yet.

# SEE ALSO
*krack*(1), *krack-build*(1)

# BUGS

Please file requests, suggestions, and report any bugs at: https://github.com/krathalan/krack/issues

# LICENSES

All krack programs are licensed under the GPLv3.
