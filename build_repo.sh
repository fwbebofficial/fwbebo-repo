#!/bin/bash
set -e
cd "$(dirname "$0")"
BASE_URL="https://fwbebofficial.github.io/fwrange-repo"
pkg_icon() {
  case "$1" in
    com.fwrange.payrangehook) echo "assets/payrangehook.png" ;;
    com.qiop1379.iflooder)   echo "assets/iflooder.png" ;;
  esac
}
pkg_depiction() {
  case "$1" in
    com.fwrange.payrangehook) echo "depictions/com.fwrange.payrangehook.json" ;;
    com.qiop1379.iflooder)   echo "depictions/com.qiop1379.iflooder.json" ;;
  esac
}
echo "Generating Packages..."
rm -f Packages Packages.gz
for deb in debs/*.deb; do
  [ -f "$deb" ] || continue
  echo "  → $(basename "$deb")"
  size=$(wc -c < "$deb" | tr -d ' ')
  sha256=$(shasum -a 256 "$deb" | awk '{print $1}')
  filename="debs/$(basename "$deb")"
  pkg_id=$(dpkg-deb --field "$deb" Package 2>/dev/null)
  for field in Package Name Version Architecture Description Author Maintainer Section Depends Homepage; do
    val=$(dpkg-deb --field "$deb" "$field" 2>/dev/null)
    [ -n "$val" ] && echo "$field: $val" >> Packages
  done
  icon=$(pkg_icon "$pkg_id")
  depiction=$(pkg_depiction "$pkg_id")
  [ -n "$icon" ]      && echo "Icon: $BASE_URL/$icon"                >> Packages
  [ -n "$depiction" ] && echo "SileoDepiction: $BASE_URL/$depiction" >> Packages
  echo "Filename: $filename" >> Packages
  echo "Size: $size"         >> Packages
  echo "SHA256: $sha256"     >> Packages
  echo ""                    >> Packages
done
gzip -k9 Packages
echo "Done."
