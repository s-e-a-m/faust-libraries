#!/usr/bin/env bash
# test-publish.sh — verifica publish.sh contro un sito finto in una dir temporanea.
set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/_libraries" "$TMP/_data"
: > "$TMP/_data/navigation.yml"

"$HERE/publish.sh" "$TMP" > "$TMP/out.txt" 2>&1 || { echo "publish.sh è uscito con errore:"; cat "$TMP/out.txt"; exit 1; }

fail=0
ok()   { echo "  ok   $1"; }
bad()  { echo "  FAIL $1"; fail=1; }

if [ -f "$TMP/_libraries/basic.md" ]; then ok "basic pubblicata"; else bad "basic pubblicata"; fi
if [ -f "$TMP/_libraries/math.md" ]; then ok "math pubblicata"; else bad "math pubblicata"; fi
if [ ! -f "$TMP/_libraries/filters.md" ]; then ok "filters esclusa dal gate"; else bad "filters esclusa dal gate"; fi
if [ ! -f "$TMP/_libraries/dwt.md" ]; then ok "dwt esclusa dal gate"; else bad "dwt esclusa dal gate"; fi

if grep -q '^permalink: /faust-libraries/basic/$' "$TMP/_libraries/basic.md"; then ok "permalink corretto"; else bad "permalink corretto"; fi
if grep -q '^generated_from: faust-libraries$' "$TMP/_libraries/basic.md"; then ok "provenienza presente"; else bad "provenienza presente"; fi

sed -n '/^<!-- GENERATO/,$p' "$TMP/_libraries/basic.md" | tail -n +2 > "$TMP/corpo.md"
if diff -q "$TMP/corpo.md" "$HERE/../build/seam.basic.md" >/dev/null; then ok "corpo identico al generato"; else bad "corpo identico al generato"; fi

if grep -q 'copertura: 2/20' "$TMP/out.txt"; then ok "rapporto di copertura"; else bad "rapporto di copertura"; fi

if [ $fail -eq 0 ]; then echo "TEST PUBLISH OK"; else echo "TEST PUBLISH FAIL"; exit 1; fi
