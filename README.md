# Rex

Rex is a dynamic CLI tool that auto-discovers scripts from configured directories. Point it at any directory of scripts and it builds a structured command interface automatically.

## Install

```bash
brew install mnk400/tap/rex
```

Or clone and add `bin/` to your PATH:

```bash
git clone https://github.com/mnk400/rex.git
export PATH="$PATH:$(pwd)/rex/bin"
```

## Setup

Add a directory of scripts:

```bash
rex dirs add ~/scripts
```

That's it. Rex will discover topics and commands from the directory structure.

## How It Works

Rex uses directory layout to build a two-tier command structure:

```
~/scripts/
├── nas/                        # Topic: nas
│   ├── nas-mount.sh            # → rex nas mount
│   └── nas-sync.sh             # → rex nas sync
├── network/                    # Topic: network
│   ├── network-stats.sh        # → rex network stats
│   └── network-speed.sh        # → rex network speed
└── amzn-stats.sh               # → rex amzn-stats (standalone)
```

- **Topics**: Subdirectories with executable scripts become topics
- **Commands**: Scripts in topic dirs become subcommands (topic prefix is auto-stripped)
- **Standalone**: Executables in the root become top-level commands

## Usage

```bash
rex                              # Show help
rex list                         # List all commands
rex <topic> <command> [args...]  # Run a topic command
rex <command> [args...]          # Run a standalone command
```

### Managing directories

```bash
rex dirs                         # List configured directories
rex dirs add <path>              # Add a scripts directory
rex dirs remove <path>           # Remove a scripts directory
```

Multiple directories are supported: topics and commands are merged across all of them.

## Script Metadata

Add metadata to your scripts via comments:

```bash
#!/bin/bash
# Description: Mount NAS to local filesystem
```

Rex is compatible with your existing raycast scripts as well! 
```bash
# or for Raycast compatibility:
# @raycast.description Mount NAS to local filesystem
```

To hide a script from rex:

```bash
# Rex.ignore
```

## Config

Config lives at `~/.config/rex/config` (or `$XDG_CONFIG_HOME/rex/config`). It's just a list of directory paths, one per line.

## License

MIT
