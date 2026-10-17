# kilo-ble — first-class Kilo × ble.sh integration

Subproject of the `ranch/kilo` monorepo. Makes Kilo a first-class citizen in
**ble.sh** (the Bash line editor that renders the prompt on this box).

## Goal

ble.sh currently drops a `ble.sh: insane environment: $USER is empty` warning
in tmux-spawned panes and has no awareness of Kilo. This subproject fixes that
and wires Kilo into the line editor:

1. **env-sanity** — ensure `USER`/`HOME` so ble.sh's prompt build never complains
   (the warning you saw when panes sourced ble).
2. **Kilo prompt unit** — `bleopt prompt_rps1='\q{contrib/kilo-info}'` shows the
   active agent@model (`kilo:code@glm-5.3-flash`) in the prompt.
3. **`Ctrl-x k`** — opens Kilo in `$PWD` from the line editor (smcup/rmcup,
   then ble resumes).

## Layout

```
contrib/kilo.bash              # loader — borrowed Bash-it blesh.plugin.bash pattern
contrib/kilo/tooling.bash      # env fix + prompt unit + keybinding
docs/                          # dd detail for the units
```

## Using

Add to `~/.bashrc` after ble.sh is available:

```bash
bleopt prompt_rps1='\q{contrib/kilo-info}'
# Ctrl-x k already bound by the contrib
```

## Pattern provenance

Loader pattern borrowed from `Bash-it/bash-it` → `blesh.plugin.bash` (found via
`forge borrow ...`): double-load guard on `BLE_VERSION`, `source ble.sh
--attach=prompt`, conditional `ble-import`. Units follow ble.sh's own
`prompt-git.bash` conventions (`ble-import contrib/prompt-defer`,
`ble/prompt/unit/assign`, `ble/util/assign/cached`).

## Rules

- Additive only. Never source the loader twice.
- Keep the env fix in one place (`tooling.bash`) so a future ble.sh upgrade
  doesn't regress it.
- No `head`/`tail`/`2>&1`-merging in *executable* shell glue (two-sec guard).