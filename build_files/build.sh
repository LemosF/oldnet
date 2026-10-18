#!/usr/bin/bash
set -euo pipefail

# --- Branding (stage 1: name only; "based on Bazzite" is allowed) ---
OSR=/usr/lib/os-release
sed -i \
  -e 's/^NAME=.*/NAME="OldNet OS"/' \
  -e 's/^PRETTY_NAME=.*/PRETTY_NAME="OldNet OS (based on Bazzite)"/' \
  -e "s/^ID=.*/ID=oldnet/" \
  -e 's/^HOME_URL=.*/HOME_URL="https:\/\/github.com\/oldnet-os\/oldnet"/' \
  -e 's/^LOGO=.*/LOGO=oldnet/' \
  "$OSR"
grep -q '^ID_LIKE=' "$OSR" || echo 'ID_LIKE="fedora"' >> "$OSR"
echo "VARIANT_ID=${IMAGE_NAME}" >> "$OSR"

# Later: themes, widgets, packages go in numbered scripts called from here.
