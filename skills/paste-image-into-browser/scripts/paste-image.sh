#!/usr/bin/env bash
# Paste a local image into the currently targeted browser composer.
#
# Usage:
#   paste-image.sh <image-file> [click_x click_y]
#
# If click coordinates are given, performs a physical click there first
# (required once per window to give Chrome real input focus), then Ctrl+V.
# If omitted, only copies to clipboard and sends Ctrl+V — use when the
# composer is already physically focused.
set -euo pipefail

IMG="$1"
export DISPLAY="${DISPLAY:-:1}"

[[ -f "$IMG" ]] || { echo "No such file: $IMG" >&2; exit 1; }

case "${IMG,,}" in
  *.png)  MIME=image/png ;;
  *.jpg|*.jpeg) MIME=image/jpeg ;;
  *.webp) MIME=image/webp ;;
  *) echo "Unsupported image type: $IMG" >&2; exit 1 ;;
esac

# xclip forks and stays resident to serve the clipboard.
xclip -selection clipboard -t "$MIME" -i "$IMG"
sleep 0.3

# Verify clipboard actually holds the image type.
xclip -selection clipboard -t TARGETS -o | grep -q "$MIME" \
  || { echo "Clipboard does not hold $MIME" >&2; exit 1; }

if [[ $# -ge 3 ]]; then
  xdotool mousemove "$2" "$3" click 1
  sleep 0.6
fi

xdotool key --clearmodifiers ctrl+v
sleep 1.5
echo "pasted $IMG"
