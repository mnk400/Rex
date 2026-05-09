# Rex 🦖

<!-- site:strip-start -->
> Auto-discover your local scripts and run them as a structured CLI.
<!-- site:strip-end -->

Rex is a CLI tool that auto-discovers executable scripts from configured directories and exposes
them as a structured command interface. Point it at any directory of scripts and it builds a
parent `rex` command on top of them — topics, subtopics, and standalone commands, all derived
from the directory layout.

I built Rex because I kept forgetting what I'd named a given automation script and ended up
digging through folders to find it. With Rex, finding and running the right one is a tab-complete
away.

<!-- site:strip-start -->
## Install

Homebrew (macOS and Linux):

```bash
brew install mnk400/tap/rex
```

Shell script (macOS and Linux):

```bash
curl -fsSL https://raw.githubusercontent.com/mnk400/rex/main/install.sh | bash
```

Manual:

```bash
git clone https://github.com/mnk400/rex.git
export PATH="$PATH:$(pwd)/rex/bin"
```
<!-- site:strip-end -->

## Setup

Point Rex at a directory of scripts:

```bash
rex dirs add ~/scripts
```

Rex automatically discovers topics and commands from any directories you've added. Multiple
directories are supported and merged into the same namespace.

## How Rex works

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
└── stock-stats.sh              # → rex stock-stats (standalone)
```

- **Topics / subtopics** — nested subdirectories become command groups, up to `max_depth`.
- **Commands** — executable scripts inside a topic dir become subcommands. The leaf topic
  prefix is auto-stripped if you've added it to the filename (e.g. `nas-mount.sh` → `mount`).
- **Standalone** — executables in the root of a configured directory become top-level commands.

## Usage

```bash
rex                                        # Show help
rex list                                   # List all commands
rex <topic> <command> [args...]            # Run a topic command
rex <topic> <subtopic> <command> [args...] # Run a subtopic command (if max_depth allows)
rex <command> [args...]                    # Run a standalone command
rex new <command>                          # Create a standalone script
rex new <topic> [subtopic...] <command>    # Create a topic/subtopic script
rex edit <command>                         # Open a script in $EDITOR
rex edit <topic> [subtopic...] <command>   # Open a topic/subtopic script in $EDITOR
```

### Managing directories

```bash
rex dirs                  # List configured directories
rex dirs add <path>       # Add a scripts directory
rex dirs remove <path>    # Remove a scripts directory
```

## Documentation

- [Config](./docs/config.md) — config file, `max_depth`, multi-directory edge cases
- [Script integration](./docs/scripts.md) — descriptions, Raycast compat, `rex.ignore`, shell completions

## License

MIT — see [LICENSE](./LICENSE).
