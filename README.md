<div align="center">

# kappa-ble

[![Shell](https://img.shields.io/badge/shell-bash-black?style=for-the-badge)](https://www.gnu.org/software/bash/)
[![ble.sh](https://img.shields.io/badge/line--editor-ble.sh-4cc2ff?style=for-the-badge)](https://github.com/akinomyoga/ble.sh)

**First-class [kappa](https://github.com/toxicwind/kappa) × ble.sh integration**

</div>

Makes the [kappa](https://github.com/toxicwind/kappa-code) CLI a first-class
citizen in [ble.sh](https://github.com/akinomyoga/ble.sh) — the Bash line
editor — fixing its tmux-pane env warning and wiring the agent into the prompt.

## What you get

- **env-sanity** — `USER`/`HOME` guaranteed so ble.sh never prints
  `insane environment: $USER is empty` in tmux-spawned panes
- **kappa prompt unit** — `bleopt prompt_rps1='\q{contrib/kappa-info}'` shows
  the active agent@model (`kappa:code@glm-5.3-flash`) in the prompt
- **`Ctrl-x k`** — open kappa in `$PWD` from the line editor (smcup/rmcup, then ble resumes)

## Install

Add to `~/.bashrc` after ble.sh is available:

```bash
bleopt prompt_rps1='\q{contrib/kappa-info}'
# Ctrl-x k already bound by the contrib
```

## Layout

```
contrib/kappa.bash              # loader — Bash-it blesh.plugin.bash pattern
contrib/kappa/tooling.bash      # env fix + prompt unit + keybinding
docs/                          # per-unit detail
```

## Pattern provenance

Loader borrowed from `Bash-it/bash-it` → `blesh.plugin.bash`: double-load guard
on `BLE_VERSION`, `source ble.sh --attach=prompt`, conditional `ble-import`.
Units follow ble.sh's own `prompt-git.bash` conventions
(`ble-import contrib/prompt-defer`, `ble/prompt/unit/assign`,
`ble/util/assign/cached`).

## Rules

- Additive only; never source the loader twice.
- Env fix stays single-sourced in `tooling.bash` so a ble.sh upgrade can't regress it.
- No stream-merging (`2>&1`) or output truncation (`| head`/`| tail`) in executable shell glue.
