# Rex 🦖

Rex is a CLI tool that auto-discovers CLI executable scripts from configured directories. Rex helps you create a parent command for your local scripts and helps keeps everything organized and neat under a system of topics and subcommands. Point it at any directory or a list of directories that contain scripts and it builds a structured command interface automatically for you!

I built rex because I kept forgetting what I named a certain automation script, and then I'd to go digging for what it's called, with rex it's significantly easier to find and execute what I need.

## Install

**Homebrew (macOS and Linux):**

```bash
brew install mnk400/tap/rex
```

**Shell script (macOS and Linux):**

```bash
curl -fsSL https://raw.githubusercontent.com/mnk400/rex/main/install.sh | bash
```

**Manual:**

```bash
git clone https://github.com/mnk400/rex.git
export PATH="$PATH:$(pwd)/rex/bin"
```

## Setup

Add a directory of scripts:

```bash
rex dirs add ~/scripts
```

Rex will automatically discover topics and commands from the directories you added.

## How Rex Works

Rex uses directory layout to build a topic/subtopic command structure.

```
~/scripts/
├── nas/                        # Topic: nas
│   ├── nas-mount.sh            # → rex nas mount
│   ├── nas-sync.sh             # → rex nas sync
│   └── backup/                 # Subtopic: backup (requires max_depth >= 2)
│       ├── backup-create.sh    # → rex nas backup create
│       └── backup-restore.sh   # → rex nas backup restore
├── network/                    # Topic: network
│   ├── network-stats.sh        # → rex network stats
│   └── network-speed.sh        # → rex network speed
└── stock-stats.sh               # → rex stock-stats (standalone)
```

**Nomenclature**

- **Topics/Subtopics**: Nested subdirectories become command groups up to `max_depth`
- **Commands**: Executable scripts in a topic/subtopic dir become subcommands (leaf topic prefix is auto-stripped if appended)
- **Standalone**: Executables in the root become top-level commands

## Usage

```bash
rex                                        # Show help
rex list                                   # List all commands
rex <topic> <command> [args...]            # Run a topic command
rex <topic> <subtopic> <command> [args...] # Run a subtopic command (if max_depth allows)
rex <command> [args...]                    # Run a standalone command
rex new <command>                          # Create standalone script
rex new <topic> [subtopic...] <command>    # Create topic/subtopic script
rex edit <command>                         # Open standalone script in $EDITOR
rex edit <topic> [subtopic...] <command>   # Open topic/subtopic script in $EDITOR
```

### Managing directories

```bash
rex dirs                         # List configured directories
rex dirs add <path>              # Add a scripts directory
rex dirs remove <path>           # Remove a scripts directory
```

Multiple directories are supported: topics and commands are merged across all of them.

## Script Metadata

Rex also supports reading script metadata via comments, for example to show command descriptions when running `rex list` you can add a "Description" meta tag to the top of the file:

```bash
#!/bin/bash
# Description: Mount NAS to local filesystem
```

If your existing scripts are built for raycast, good news! we're compatible. Rex will automatically read @raycast.description without any further manual changes needed.

To hide a script from rex:

```bash
# rex.ignore
```

## Shell Completions

Rex supports tab completions! Enable tab completions by adding to your shell profile:

```bash
# bash (~/.bashrc)
eval "$(rex completions bash)"

# zsh (~/.zshrc)
eval "$(rex completions zsh)"
```

This gives you tab completion for topics/subtopics, commands, and built-in subcommands.

## Config

Config lives at `~/.config/rex/config` (or `$XDG_CONFIG_HOME/rex/config`).

Supported config entries:

- Directory paths (one per line)
- `max_depth=<n>` where `<n>` is an integer `>= 1`

Example:

```text
# script directories
/Users/you/scripts
/Users/you/workflows

# enable subtopics to 3 levels deep
max_depth=3
```

Notes:

- Default `max_depth` is `1` (single topic level).
- A directory only registers as a topic if it has a non-ignored executable reachable within `max_depth`. Directories deeper than `max_depth` will not surface, you'll have raise `max_depth` to surface them.
- When a command and a subtopic share a name (e.g. both `nas/nas-backup.sh` and `nas/backup/`), the command always wins.

## License

MIT
