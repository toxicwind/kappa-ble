# blesh/contrib/kappa/tooling.bash — Kilo tooling inside ble.sh.
#
# Loaded from contrib/kappa.bash after ble.sh attaches. Implements:
#   1. env-sanity  — kill the "$USER is empty" ble.sh warning in tmux-panels.
#   2. prompt unit — '\q{contrib/kappa-info}' shows active kappa agent@model.
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

## @fn ble/contrib/kappa-info/.refresh
##   Cache-friendly probe for the active kappa agent+model. Cheap: reads env the
##   kappa launcher exports (KILO_AGENT / KILO_MODEL) and never spawns kappa.
function ble/contrib/kappa-info/.refresh {
  local agent=${KILO_AGENT:-code}
  local model=${KILO_MODEL:-'?'}
  ble/prompt/unit/assign _ble_kilo_info "$agent" "$model"
}

## @fn ble/prompt/unit:kappa-info
##   '\q{contrib/kappa-info}' → 'kappa:code@glm-5.3-flash' or 'kappa:off'.
function ble/prompt/unit:kappa-info {
  local cached cached_fmt=enabled
  if ! ble/util/assign/cached _ble_kilo_info _ble_kilo_info_ts ble/contrib/kappa-info/.refresh 30; then
    cached_fmt=disabled
  fi
  local agent=${_ble_kilo_info[0]} model=${_ble_kilo_info[1]}
  if [[ -n $agent ]]; then
    ble/prompt/unit/print "kappa:${agent}@${model}"
  else
    ble/prompt/unit/print "kappa:off"
  fi
}

# --- 3. Ctrl-x k: launch Kilo from the line editor -----------------------------
## @fn ble/widget/kappa-editor
##   Enters the alt screen (ble owns the terminal), runs `kappa` in $PWD, then
##   restores ble's line editor on exit.
function ble/widget/kappa-editor {
  local dir=$PWD
  printf '\e[?1049h'   # smcup — let kappa own the terminal
  if command -v kappa >/dev/null 2>&1; then
    ( cd "$dir" && kappa )
  else
    ble/widget/print "kappa: command not found" 2>/dev/null || :
  fi
  printf '\e[?1049l'   # rmcup — give the terminal back to ble
  ble/readline/clear 2>/dev/null || :
  return 0
}

ble-bind -f 'C-x k' kappa-editor