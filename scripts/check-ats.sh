#!/usr/bin/env bash
# ATS guarantees for the generated PDFs (run by `make check` and the CI).
# Usage: scripts/check-ats.sh dist/*.pdf
#
# The compilation with --pdf-standard ua-1 is not repeated here: the Makefile
# and deploy/Dockerfile always use it, so a failing compilation already fails
# the build before these checks run.
set -u

[ "$#" -gt 0 ] || { echo "usage: $0 file.pdf..." >&2; exit 2; }

fail=0
check() { # check <pdf> <description> <command...>
  local pdf=$1 what=$2; shift 2
  if "$@"; then echo "ok    $pdf: $what"; else echo "FAIL  $pdf: $what"; fail=1; fi
}

for pdf in "$@"; do
  text=$(pdftotext "$pdf" - 2>/dev/null)
  # The text layer must contain the keywords a parser looks for.
  check "$pdf" "text contains TypeScript" grep -q TypeScript <<<"$text"
  # Private Use Area (U+E000-U+F8FF) and U+FEFF show up as garbage in parsers;
  # icon fonts and copied-in text are the usual source.
  check "$pdf" "no Private Use Area character nor U+FEFF" \
    bash -c '! LC_ALL=C.UTF-8 grep -qP "[\x{E000}-\x{F8FF}\x{FEFF}]" <<<"$1"' _ "$text"
  # A tagged PDF carries its reading order and structure.
  check "$pdf" "PDF is tagged" bash -c 'pdfinfo "$1" 2>/dev/null | grep -q "^Tagged: *yes"' _ "$pdf"
done

exit "$fail"
