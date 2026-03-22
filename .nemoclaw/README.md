# NemoClaw state (runtime)

This directory holds NemoClaw plugin state: blueprint cache, credentials, sandbox registry, and run history.

`~/.nemoclaw` is a **symlink** to here so everything stays under `/path/to/nemoclaw` repo root.

**Do not commit secrets.** This tree is listed in `.gitignore` except for this file.
