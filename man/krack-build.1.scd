krack-build(1) ["Version 0.3.0"]

# NAME

krack-build - Build and upload Arch packages headlessly, automatically, at a defined interval

# SYNOPSIS

krack-build [_--flags_]...

# DESCRIPTION

krack-build will read configuration options from /etc/krack/build.conf. The default build.conf included with the krack package has comments in the file explaining each configuration option.

# FLAGS

*--start-asleep*
	Starts krack-build as if it had just finished a build cycle. It will sleep for the defined SLEEP_HOURS in /etc/krack/build.conf, as usual. This flag is useful after updating krack.++
	e.g. krack-build *--start-asleep*

# SEE ALSO
*krack*(1), *krackctl*(1)

# BUGS

Please file requests, suggestions, and report any bugs at: https://github.com/krathalan/krack/issues

# LICENSES

All krack programs are licensed under the GPLv3.
