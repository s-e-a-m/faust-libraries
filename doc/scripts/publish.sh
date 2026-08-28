#!/usr/bin/env bash
# publish.sh — trasporta le reference generate nel sito SEAM.
#
# Uso: publish.sh <percorso-del-sito>
#
# Pubblica SOLO le librerie che hanno almeno una funzione documentata alla
# fonte (banner Grame, che faustlib2md.awk rende come "### `(prefix.)nome`").
# Le altre restano fuori: una pagina di soli titoli è peggio di nessuna pagina.
# Non committa e non pusha: il controllo editoriale resta un gesto umano.

set -uo pipefail

SITE="${1:-}"
[ -n "$SITE" ] || { echo "uso: publish.sh <percorso-del-sito>" >&2; exit 1; }

HERE="$(cd "$(dirname "$0")" && pwd)"
BUILD="$HERE/../build"
COLL="$SITE/_libraries"

[ -d "$SITE" ]  || { echo "publish: sito non trovato: $SITE" >&2; exit 1; }
[ -d "$BUILD" ] || { echo "publish: manca $BUILD — lancia prima 'make -C doc doc'" >&2; exit 1; }

REV="$(git -C "$HERE" rev-parse --short HEAD)"
TODAY="$(date +%F)"

mkdir -p "$COLL"

published=""
skipped=""
total=0

for f in "$BUILD"/seam.*.md; do
  total=$((total + 1))
  base="$(basename "$f" .md)"     # seam.basic
  name="${base#seam.}"            # basic
  nfun="$(grep -c '^### `(' "$f")"
  if [ "$nfun" -eq 0 ]; then
    skipped="$skipped $name"
    continue
  fi
  {
    printf -- '---\n'
    printf 'title: "Faust Libraries · %s"\n' "$name"
    printf 'permalink: /faust-libraries/%s/\n' "$name"
    printf 'toc: true\n'
    printf 'generated_from: faust-libraries\n'
    printf 'generated_rev: %s\n' "$REV"
    printf 'generated_at: %s\n' "$TODAY"
    printf -- '---\n\n'
    printf '<!-- GENERATO — non modificare qui: la fonte è faust-libraries/src/%s.lib -->\n' "$base"
    cat "$f"
  } > "$COLL/$name.md"
  published="$published $name"
  echo "  publish $name ($nfun funzioni)"
done

npub="$(echo "$published" | wc -w | tr -d ' ')"
echo "  copertura: $npub/$total"
[ -n "$skipped" ] && echo "  non documentate alla fonte:$skipped"
exit 0
