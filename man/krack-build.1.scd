krack-build(1) ["Version 0.1.0"]

# NAME

krack-build - Build and upload Arch packages headlessly, automatically, at a defined interval

# SYNOPSIS

krack-build [_--flags_]...

# DESCRIPTION

# FLAGS

*--start-asleep*
	Starts krack-build as if it had just finished a build cycle. It will sleep for the defined SLEEP_HOURS in /etc/krack/build.conf, as usual. This flag is useful after updating krack.++
	e.g. krack-build *--start-asleep*

# BUGS

Please file requests, suggestions, and report any bugs at: https://todo.sr.ht/~krathalan/krack++
Alternatively, you may send them via email to: ~krathalan/krack@todo.sr.ht

# LICENSES

All krack programs are licensed under the GPLv3.
