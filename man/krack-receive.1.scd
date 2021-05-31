krack-receive(1) ["Version 0.4.2"]

# NAME

krack-receive - Watch a directory for new packages (and signatures) and add them to a pacman repo

# DESCRIPTION

krack-receive will read configuration options /etc/krack/receive.conf. The default receive.conf included with the krack package has comments in the file explaining each configuration option.

You should never run krack-receive from the command line. It should run as a systemd service under krack-receive.service.

# SEE ALSO
*krack*(1), *krackctl*(1)

# BUGS

Please file requests, suggestions, and report any bugs at: https://github.com/krathalan/krack/issues

# LICENSES

All krack programs are licensed under the GPLv3.
