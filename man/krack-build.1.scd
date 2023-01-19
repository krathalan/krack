krack-build(1) ["Version 0.4.2"]

# NAME

krack-build - Build and upload Arch packages headlessly, automatically, at a defined interval

# SYNOPSIS

krack-build [_--flags_]...

# DESCRIPTION

krack-build will read configuration options from /etc/krack/build.conf. The default /etc/krack/build.conf file included with the krack package has comments in the file explaining each configuration option.

Note that you will likely not want to run krack-build manually, but instead use the _krack-build@.service/timer_ systemd system service to manage (start on boot/restart on failure) your krack-build process. See *krack*(1) for more information on using systemd with krack.

# SEE ALSO
*krack*(1), *krackctl*(1)

# BUGS

Please file requests, suggestions, and report any bugs at: https://github.com/krathalan/krack/issues

# LICENSES

All krack programs are licensed under the GPLv3.
