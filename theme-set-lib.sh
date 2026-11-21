#!/bin/bash

# Omarchy 4 runs each theme-set hook in a fresh shell. Load the current
# semantic palette and provide the compatibility helpers used by this pack.
hooklette=${BASH_SOURCE[1]:-}
[[ -z $hooklette || -x $hooklette ]] || exit 0

THEME_DIR="$HOME/.local/state/omarchy/current/theme"
COLORS_FILE="$THEME_DIR/colors.toml"

success() {
  printf '\033[0;32m[SUCCESS]\033[0m %s\n' "$1"
}

skipped() {
  printf '\033[0;34m[SKIPPED]\033[0m %s not found. Skipping.\n' "$1"
  exit 0
}

warning() {
  printf '\033[0;33m[WARNING]\033[0m %s\n' "$1"
}

error() {
  printf '\033[0;31m[ERROR]\033[0m %s\n' "$1" >&2
  exit 1
}

[[ -f $COLORS_FILE ]] || error "colors.toml not found at $COLORS_FILE"

declare -A HOOK_THEME_COLORS=()
while IFS=$'\t' read -r key value; do
  [[ -n $key && -n $value ]] && HOOK_THEME_COLORS[$key]="$value"
done < <(omarchy theme color --file "$COLORS_FILE" --all)

theme_color() {
  local key=$1
  local value=${HOOK_THEME_COLORS[$key]:-}

  [[ -n $value ]] || error "Theme color '$key' could not be resolved"
  printf '%s' "$value"
}

theme_hex() {
  local value
  value=$(theme_color "$1")
  [[ $value =~ ^#[0-9A-Fa-f]{6}$ ]] || error "Theme color '$1' is not a six-digit hex color: $value"
  printf '%s' "${value#\#}"
}

hex2rgb() {
  local hex=${1#\#}
  [[ $hex =~ ^[0-9A-Fa-f]{6}$ ]] || error "Invalid hex color: $1"
  printf '%d, %d, %d' "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
}

rgb2hex() {
  printf '%02x%02x%02x' "$1" "$2" "$3"
}

change_shade() {
  local hex=${1#\#}
  local shade=$2
  local red green blue

  [[ $hex =~ ^[0-9A-Fa-f]{6}$ && $shade =~ ^-?[0-9]+$ ]] || error "Invalid shade arguments: $1 $2"

  red=$((16#${hex:0:2} + shade))
  green=$((16#${hex:2:2} + shade))
  blue=$((16#${hex:4:2} + shade))

  (( red < 0 )) && red=0
  (( green < 0 )) && green=0
  (( blue < 0 )) && blue=0
  (( red > 255 )) && red=255
  (( green > 255 )) && green=255
  (( blue > 255 )) && blue=255

  rgb2hex "$red" "$green" "$blue"
}

require_restart() {
  local app=$1

  if pgrep -x "$app" >/dev/null 2>&1; then
    omarchy-notification-send "Theme updated" "$app must be restarted to apply the new theme." >/dev/null 2>&1 || true
  fi
}

theme_mode=$(theme_color mode)
primary_foreground=$(theme_hex foreground)
primary_background=$(theme_hex background)
cursor_color=$(theme_hex cursor)
selection_foreground=$(theme_hex selection_foreground)
selection_background=$(theme_hex selection_background)
normal_black=$(theme_hex color0)
normal_red=$(theme_hex color1)
normal_green=$(theme_hex color2)
normal_yellow=$(theme_hex color3)
normal_blue=$(theme_hex color4)
normal_magenta=$(theme_hex color5)
normal_cyan=$(theme_hex color6)
normal_white=$(theme_hex color7)
bright_black=$(theme_hex color8)
bright_red=$(theme_hex color9)
bright_green=$(theme_hex color10)
bright_yellow=$(theme_hex color11)
bright_blue=$(theme_hex color12)
bright_magenta=$(theme_hex color13)
bright_cyan=$(theme_hex color14)
bright_white=$(theme_hex color15)

rgb_primary_foreground=$(hex2rgb "$primary_foreground")
rgb_primary_background=$(hex2rgb "$primary_background")
rgb_normal_black=$(hex2rgb "$normal_black")
rgb_normal_red=$(hex2rgb "$normal_red")
rgb_normal_green=$(hex2rgb "$normal_green")
rgb_normal_yellow=$(hex2rgb "$normal_yellow")
rgb_normal_blue=$(hex2rgb "$normal_blue")
rgb_normal_magenta=$(hex2rgb "$normal_magenta")
rgb_normal_cyan=$(hex2rgb "$normal_cyan")
rgb_normal_white=$(hex2rgb "$normal_white")
rgb_bright_black=$(hex2rgb "$bright_black")
rgb_bright_red=$(hex2rgb "$bright_red")
rgb_bright_green=$(hex2rgb "$bright_green")
rgb_bright_yellow=$(hex2rgb "$bright_yellow")
rgb_bright_blue=$(hex2rgb "$bright_blue")
rgb_bright_magenta=$(hex2rgb "$bright_magenta")
rgb_bright_cyan=$(hex2rgb "$bright_cyan")
rgb_bright_white=$(hex2rgb "$bright_white")
