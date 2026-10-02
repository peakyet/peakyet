#!/bin/zsh
# Render each named frame headlessly and sample the pixel region where the template
# paints its "overfull" badge. Redness > 0 means the badge is visible: that frame does
# not fit its 1280x720 page. Usage: ./scripts/check_overfull.sh 1 2 3 ... 30
set -e
here=$(cd "$(dirname "$0")/.." && pwd)
P=$here/optimal-transport-deck.html
bad=0
for n in "$@"; do
  f=/tmp/otchk-$n.png
  firefox --headless --screenshot=$f --window-size=1440,900 "file://$P#/$n" >/dev/null 2>&1
  d=$(magick $f -crop 160x30+1280+47 +repage -colorspace sRGB -format "%[fx:mean.r-mean.g]" info:)
  # A clean frame samples the frame's own tint (about -0.02); the badge is solid red.
  if (( ${d:-0} > 0.05 )); then
    printf "frame %-3s BAD   redness %s\n" "$n" "$d"
    bad=$((bad+1))
  else
    printf "frame %-3s ok    redness %s\n" "$n" "$d"
  fi
done
echo "--- $bad overfull frame(s) of $#"
exit $((bad > 0))
