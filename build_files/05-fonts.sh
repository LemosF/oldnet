#!/usr/bin/bash
# Fonts (both SIL OFL 1.1): IBM Plex Mono from Fedora, Chakra Petch from Google Fonts.
set -euo pipefail

dnf5 -y install ibm-plex-mono-fonts
dnf5 clean all

# Chakra Petch is not packaged in Fedora. Pinned to one google/fonts commit and
# checked against known hashes, so a changed upstream file fails the build.
CHAKRA_COMMIT=a4c8c2a0f77efa06765d596d64d077af1d7f0dae
CHAKRA_URL="https://raw.githubusercontent.com/google/fonts/${CHAKRA_COMMIT}/ofl/chakrapetch"
FONT_DIR=/usr/share/fonts/chakra-petch
LICENSE_DIR=/usr/share/licenses/chakra-petch

mkdir -p "$FONT_DIR" "$LICENSE_DIR"
work=$(mktemp -d)
cat > "$work/SHA256SUMS" <<'EOF'
65fbf76d95651697275e19db4d717c0e95a789ddd3476478b05292104db278a0  ChakraPetch-Bold.ttf
bf012ce1894ffcf7d32d3e6548b90df7c40f30161b5cc295eb54ff61c21fab19  ChakraPetch-BoldItalic.ttf
1bbaf8f6f9f32dcabb723071ae7fca72f5c66a106f2613f2bd9210722debec36  ChakraPetch-ExtraLight.ttf
f927e3d4d9ac40165f30238079fa887056691ac3b3dd5c6a1f4b5e50c3320a88  ChakraPetch-ExtraLightItalic.ttf
3aeea48f0ffab0d6ad8d3cd0cb9c0ceb98ecbcf363521ce56fceea51ecbb1d1f  ChakraPetch-Italic.ttf
13a106a367b903fb509ed11e7c921589a0d42c22540510d3ca8f6c7343bef76b  ChakraPetch-Light.ttf
67e426488e221d5d9e5a3b62a34b45f1f534dabd1078bdc77fcdfe43630cbee0  ChakraPetch-LightItalic.ttf
d480f4f97405fac3600652e2e14fd0b14339031c0af4da11582994878f04d919  ChakraPetch-Medium.ttf
3a9185b6735897aeb38fdd132aae761a9092001c7615ac9e2238131bf9b099ed  ChakraPetch-MediumItalic.ttf
98fcd638baa5c81ff0316b7538ce330ee3b23b1302726de3526d5933a8ecf986  ChakraPetch-Regular.ttf
45264de3204ddbd5fb3e14a2402acd5c630d16650ae5fc221d2c52da46a6734b  ChakraPetch-SemiBold.ttf
4e11c1bec71511bbea8a3bc3f4cebff479bb9681961d691a36f99e5234d8fe89  ChakraPetch-SemiBoldItalic.ttf
13831d02389d917d22fcfa6c79f98f8acbf61d230add0e73a4d4dc5f3bfb9e56  OFL.txt
EOF

while read -r _ name; do
  curl -fsSL --retry 3 -o "$work/$name" "$CHAKRA_URL/$name"
done < "$work/SHA256SUMS"
(cd "$work" && sha256sum -c SHA256SUMS)

install -m 0644 "$work"/*.ttf "$FONT_DIR/"
install -m 0644 "$work/OFL.txt" "$LICENSE_DIR/OFL.txt"
rm -rf "$work"
fc-cache -f "$FONT_DIR"
# No pipe into grep -q here: with pipefail, grep exiting early makes fc-list fail on SIGPIPE.
match=$(fc-match -f '%{family}' 'Chakra Petch')
[[ "$match" == *"Chakra Petch"* ]] || { echo "Chakra Petch not visible to fontconfig (got: $match)"; exit 1; }
echo "Chakra Petch: installed"
