#!/usr/bin/bash
# OldNet Tabs: 5 virtual desktops, Meta+1..5 to switch, KWin rules that send
# apps to their tab. The widget itself is copied from widgets/ by the Containerfile.
set -euo pipefail

KWINRC=/etc/xdg/kwinrc
RULES=/etc/xdg/kwinrulesrc
SHORTCUTS=/etc/xdg/kglobalshortcutsrc

# Fixed ids so the KWin rules below can point at a desktop.
NAMES=(Desktop Mail Messages Games Code)
IDS=(
  0e1d0001-0000-4000-8000-0000000000a1
  0e1d0002-0000-4000-8000-0000000000a2
  0e1d0003-0000-4000-8000-0000000000a3
  0e1d0004-0000-4000-8000-0000000000a4
  0e1d0005-0000-4000-8000-0000000000a5
)

kwriteconfig6 --file "$KWINRC" --group Desktops --key Number 5
kwriteconfig6 --file "$KWINRC" --group Desktops --key Rows 1
for i in "${!NAMES[@]}"; do
  n=$((i + 1))
  kwriteconfig6 --file "$KWINRC" --group Desktops --key "Id_$n" "${IDS[$i]}"
  kwriteconfig6 --file "$KWINRC" --group Desktops --key "Name_$n" "${NAMES[$i]}"

  # Meta+N switches tab; free it from the task manager, which claims Meta+1..9 by default.
  kwriteconfig6 --file "$SHORTCUTS" --group kwin --key "Switch to Desktop $n" \
    "Meta+$n,Ctrl+F$n,Switch to Desktop $n"
  kwriteconfig6 --file "$SHORTCUTS" --group plasmashell --key "activate task manager entry $n" \
    "none,Meta+$n,Activate Task Manager Entry $n"
done

# Window rules: open each app on its tab once ("apply initially" = 3), the user can still move it.
# wmclassmatch: 1 = exact, 3 = regex. Regexes cover both RPM and Flatpak class names.
add_rule() { # group description match-type wmclass desktop-index
  kwriteconfig6 --file "$RULES" --group "$1" --key Description "$2"
  kwriteconfig6 --file "$RULES" --group "$1" --key wmclassmatch "$3"
  kwriteconfig6 --file "$RULES" --group "$1" --key wmclass "$4"
  kwriteconfig6 --file "$RULES" --group "$1" --key wmclasscomplete false
  kwriteconfig6 --file "$RULES" --group "$1" --key types 1
  kwriteconfig6 --file "$RULES" --group "$1" --key desktops "${IDS[$5]}"
  kwriteconfig6 --file "$RULES" --group "$1" --key desktopsrule 3
}
add_rule oldnet-mail     "OldNet: Thunderbird on the Mail tab"   3 '^(org\.mozilla\.)?[Tt]hunderbird$' 1
add_rule oldnet-messages "OldNet: NeoChat on the Messages tab"   3 '^(org\.kde\.)?neochat$'            2
# Exact "steam" = the client only; games run as steam_app_<id> and stay where launched.
add_rule oldnet-games    "OldNet: Steam client on the Games tab" 1 'steam'                             3
add_rule oldnet-code     "OldNet: VS Code on the Code tab"       3 '^(code|com\.visualstudio\.code)$'  4

existing=$(kreadconfig6 --file "$RULES" --group General --key rules)
ours="oldnet-mail,oldnet-messages,oldnet-games,oldnet-code"
all="${existing:+$existing,}$ours"
kwriteconfig6 --file "$RULES" --group General --key rules "$all"
kwriteconfig6 --file "$RULES" --group General --key count "$(tr ',' '\n' <<<"$all" | grep -c .)"

rm -f /usr/share/plasma/plasmoids/.gitkeep
