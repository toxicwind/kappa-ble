# AGENTS.md — kilo-ble (subproject of ranch/kilo)

> Refines: `ranch/kilo/AGENTS.md` (master). Owns nothing above it; this file
> refines the master's rules for the Kilo × ble.sh integration only.

## Owns

`contrib/kilo.bash` (loader) + `contrib/kilo/tooling.bash` (env fix, prompt
unit, keybinding). Make Kilo a first-class citizen in ble.sh (bash line editor).

## Non-negotiables

- **Additive only.** Never break an existing ble.sh prompt; always gate new
  prompt units behind `bleopt prompt_rps1='\q{contrib/...}'` opt-in.
- **Loader pattern** is borrowed from `Bash-it/bash-it` `blesh.plugin.bash`:
  double-load guard on `BLE_VERSION`, `source ble.sh --attach=prompt`,
  conditional `ble-import`. Do not hand-roll a divergent loader.
- **Env-sanity is single-sourced** in `tooling.bash` (USER/HOME) so a ble.sh
  upgrade can't regress the tmux-pane warning fix.
- **Guard doctrine**: no `2>&1`, no `/dev/null`, no `|head|tail`, no
  blocking-`sleep` in *executable* shell glue — write to a file and read via
  `ffs`. The two-sec guard applies to commands, not source text, but keep the
  plugins clean anyway.

## Verify before done

`bash -n contrib/kilo.bash contrib/kilo/tooling.bash` (syntax), and in a real
shell after sourcing: `bleopt prompt_rps1='\q{contrib/kilo-info}'` renders
`kilo:*` and C-x k is bound (`ble-bind --help | rg kilo`).