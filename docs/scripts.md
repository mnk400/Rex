# Script integration

How Rex picks up metadata from your scripts, and how to wire up shell completions.

## Description metadata

Rex reads the `Description:` comment from the top of a script and shows it in `rex list`:

```bash
#!/bin/bash
# Description: Mount NAS to local filesystem
```

If your existing scripts are written for Raycast, Rex is compatible — `@raycast.description`
is read automatically with no changes needed.

## Hiding a script

Add this comment anywhere near the top of a script to hide it from Rex:

```bash
# rex.ignore
```

The script stays on disk and is still executable directly; Rex just won't surface it under any
topic or in `rex list`.

## Shell completions

Tab completion covers topics, subtopics, commands, and built-in subcommands. Enable it by
sourcing the generator from your shell profile:

```bash
# bash (~/.bashrc)
eval "$(rex completions bash)"

# zsh (~/.zshrc)
eval "$(rex completions zsh)"
```
