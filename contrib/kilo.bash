# kilo-ble — first-class Kilo integration for ble.sh (the Bash line editor).
#
# Pattern borrowed from Bash-it/bash-it `blesh.plugin.bash` (the canonical way
# to wire an app into ble.sh): guard double-load on BLE_VERSION, attach ble with
# `--attach=prompt`, then import integrations conditionally. On top of that we
# add the Kilo-specific units: an env-sanity fix for the "$USER is empty"
# warning ble.sh raises in tmux-spawned panes, and a `kilo` prompt unit.
#
# Usage (after ble.sh load — put the line in ~/.bashrc):
#   bleopt prompt_rps1='\q{contrib/kilo-info}'
#
# Ctrl-x k opens Kilo in the current directory from the line editor.

if [[ -n "${BLE_VERSION-}" ]]; then
  _log_warning "ble.sh is already loaded!" 2>/dev/null || :
  return
fi

_kilo_ble_path=${XDG_DATA_HOME:-$HOME/.local/share}/blesh/ble.sh
if [[ -f $_kilo_ble_path ]]; then
  source "$_kilo_ble_path" --attach=prompt
  ble-import -d contrib/kilo/tooling
else
  _log_error "Could not find ble.sh in $_kilo_ble_path" 2>/dev/null || :
  _log_error "git clone https://github.com/akinomyoga/ble.sh && make -C ble.sh install" 2>/dev/null || :
fi
unset _kilo_ble_path