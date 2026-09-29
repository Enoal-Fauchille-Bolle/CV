#!/usr/bin/env bash
# Lists the tags used in src/cv.yaml and the entries carrying each one.
#
# Usage: scripts/tags.sh            # human-readable table (make tags)
#        scripts/tags.sh --names    # one tag per line (used by the Makefile)
set -euo pipefail

cd "$(dirname "$0")/.."

# One "tag<TAB>id, id, ..." line per tag, from every `id:` / `tags: [...]` pair.
table=$(awk '
  /- id:/ { id = $3 }
  /^ +tags:/ {
    sub(/.*\[/, ""); sub(/\].*/, "")
    n = split($0, t, / *, */)
    for (i = 1; i <= n; i++) list[t[i]] = list[t[i]] (list[t[i]] ? ", " : "") id
  }
  END { for (k in list) print k "\t" list[k] }
' src/cv.yaml | sort)

if [ "${1:-}" = "--names" ]; then
  cut -f1 <<<"$table"
  exit 0
fi

echo "core   always shown, in every build"
echo "extra  hidden from the default build; a tag below brings its entries back"
echo
echo "Tag                Entries"
echo "-----------------  -------"
grep -v -e '^core	' -e '^extra	' <<<"$table" | awk -F'\t' '{ printf "%-17s  %s\n", $1, $2 }'
echo
echo "Build one:  make TAG=<tag>   (public)   or   make private TAG=<tag>"
