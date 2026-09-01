#!/bin/bash
# Run after adding/updating any .deb in debs/
# Usage: ./build_repo.sh

set -e
cd "$(dirname "$0")"

echo "Generating Packages index..."
rm -f Packages Packages.gz

for deb in debs/*.deb; do
  [ -f "$deb" ] || continue
  echo "  → $(basename "$deb")"

  size=$(wc -c < "$deb" | tr -d ' ')
  sha256=$(shasum -a 256 "$deb" | awk '{print $1}')
  filename="debs/$(basename "$deb")"

  # dpkg-deb --field outputs clean "Key: Value" lines (no leading spaces)
  for field in Package Name Version Architecture Description Author Maintainer Section Depends Homepage; do
    val=$(dpkg-deb --field "$deb" "$field" 2>/dev/null)
    [ -n "$val" ] && echo "$field: $val" >> Packages
  done

  echo "Filename: $filename"   >> Packages
  echo "Size: $size"           >> Packages
  echo "SHA256: $sha256"       >> Packages
  echo ""                      >> Packages
done

gzip -k9 Packages
echo ""
echo "Done — Packages and Packages.gz updated."
echo ""
echo "Next steps:"
echo "  git add debs/ Packages Packages.gz Release && git commit -m 'release' && git push"
