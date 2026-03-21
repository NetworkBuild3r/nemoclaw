# OpenClaw state (runtime)

This directory is the **real** OpenClaw data: `openclaw.json`, agent metadata, sessions, synced Telegram tokens, etc.

`~/.openclaw` is a **symlink** to here so everything NemoClaw-related stays under `/home/bnelson/nemoclaw`.

**Do not commit secrets.** This tree is listed in the repo root `.gitignore` except for this file.
