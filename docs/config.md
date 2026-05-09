# Config

Config lives at `~/.config/rex/config` (or `$XDG_CONFIG_HOME/rex/config`).

Supported entries:

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

## Notes

- Default `max_depth` is `1` (single topic level).
- A directory only registers as a topic if it has a non-ignored executable reachable within
  `max_depth`. Directories deeper than `max_depth` won't surface — raise `max_depth` to expose them.
- When a command and a subtopic share a name (e.g. both `nas/nas-backup.sh` and `nas/backup/`),
  the command always wins.
- Multiple script directories are merged: topics and commands from all configured directories
  appear under the same `rex` namespace.
