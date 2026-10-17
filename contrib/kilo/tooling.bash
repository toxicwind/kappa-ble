# blesh/contrib/kilo/tooling.bash — Kilo tooling inside ble.sh.
#
# Loaded from contrib/kilo.bash after ble.sh attaches. Implements:
#   1. env-sanity  — kill the "$USER is empty" ble.sh warning in tmux-panels.
#   2. prompt unit — '\q{contrib/kilo-info}' shows active kilo agent@model.
#   3. keybinding  — Ctrl-x k launches Kilo in $PWD from the line editor.

# --- 1. env sanity -----------------------------------------------------------
if [[ -z ${USER:-} ]]; then
  export USER=$(id -un 2>/dev/null || true)
fi
if [[ -z ${HOME:-} ]]; then
  export HOME=$(getent passwd "$USER" 2>/dev/null | cut -d: -f6 || true)
fi

# --- 2. Kilo prompt unit -------------------------------------------------------
_ble_kilo_info_ts=0
_ble_kilo_info=(code '?')

## @fn ble/contrib/kilo-info/.refresh
##   Cache-friendly probe for the active kilo agent+model. Cheap: reads env the
##   kilo launcher exports (KILO_AGENT / KILO_MODEL) and never spawns kilo.
function ble/contrib/kilo-info/.refresh {
  local agent=${KILO_AGENT:-code}
  local model=${KILO_MODEL:-'?'}
  ble/prompt/unit/assign _ble_kilo_info "$agent" "$model"
}

## @fn ble/prompt/unit:kilo-info
##   '\q{contrib/kilo-info}' → 'kilo:code@glm-5.3-flash' or 'kilo:off'.
function ble/prompt/unit:kilo-info {
  local cached cached_fmt=enabled
  if ! ble/util/assign/cached _ble_kilo_info _ble_kilo_info_ts ble/contrib/kilo-info/.refresh 30; then
    cached_fmt=disabled
  fi
  local agent=${_ble_kilo_info[0]} model=${_ble_kilo_info[1]}
  if [[ -n $agent ]]; then
    ble/prompt/unit/print "kilo:${agent}@${model}"
  else
    ble/prompt/unit/print "kilo:off"
  fi
}

# --- 3. Ctrl-x k: launch Kilo from the line editor -----------------------------
## @fn ble/widget/kilo-editor
##   Enters the alt screen (ble owns the terminal), runs `kilo` in $PWD, then
##   restores ble's line editor on exit.
function ble/widget/kilo-editor {
  local dir=$PWD
  printf '\e[?1049h'   # smcup — let kilo own the terminal
  if command -v kilo >/dev/null 2>&1; then
    ( cd "$dir" && kilo )
  else
    ble/widget/print "kilo: command not found" 2>/dev/null || :
  fi
  printf '\e[?1049l'   # rmcup — give the terminal back to ble
  ble/readline/clear 2>/dev/null || :
  return 0
}

ble-bind -f 'C-x k' kilo-editor