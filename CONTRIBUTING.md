All issues/PRs welcome. Please include all relevant info (don't be afraid to be verbose or over-document).

# Project layout

```
 anders@delta ~/git/krack master
 > exa --tree --group-directories-first
.
├── bash-completion
│  └── krackctl
├── bin
│  ├── krack-build
│  └── krackctl
├── etc
│  ├── build.conf
│  └── receive.conf
├── lib
│  ├── systemd
│  │  └── system
│  │     └── krack-receive.service
│  ├── build
│  ├── common
│  └── receive
├── man
│  ├── krack-build.1.scd
│  ├── krack-receive.1.scd
│  ├── krack.1.scd
│  └── krackctl.1.scd
├── CONTRIBUTING.md
├── LICENSE
├── README.md
└── TODO
```

## krack-build
Wrapper script at `bin/krack-build` that runs `lib/build`. `bin/krack-build` is used to easily facilitate logging.

## krack-receive
Runs `lib/receive` via the systemd unit `krack-receive.service`.

## krackctl
Standalone script at `bin/krackctl` that reads data from the hidden directory `~/.local/share/krack/.status` to report information about the running krack-build instance. You can find the variable names of all the files under the status directory in `lib/common`.

### bash completion
If you add new functionality to krackctl, make sure to add new commands/completions to `bash-completion/krackctl`.

# Packaging

Generally:

- everything under `bin/` goes to `/usr/bin/`, 
- everything under `etc/` to `/etc/krack/`, 
- everything under `lib/` to `/usr/lib/krack/`,
- and man pages under `man/` get generated with `scdoc` and go to `/usr/share/man/man1/`.