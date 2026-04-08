#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────
# Segnale & Rumore — Casi · build.sh
# Converte i file .md in docs/ in .html in docs-html/
# usando Pandoc + template e CSS coordinati.
# ──────────────────────────────────────────────────────────

set -euo pipefail

# sposta il contesto alla cartella in cui risiede lo script
cd "$(dirname "$0")"

SRC_DIR="docs"
OUT_DIR="docs-html"
TEMPLATE="assets/template.html"

if ! command -v pandoc >/dev/null 2>&1; then
  echo "✗ pandoc non trovato. Installa con: brew install pandoc"
  exit 1
fi

mkdir -p "$OUT_DIR"

count=0
for md in "$SRC_DIR"/*.md; do
  [ -e "$md" ] || { echo "✗ nessun .md in $SRC_DIR"; exit 1; }
  base="$(basename "$md" .md)"
  out="$OUT_DIR/$base.html"

  # estrae il primo H1/H2/H3 del markdown come title
  title="$(grep -m1 -E '^#{1,3} ' "$md" | sed -E 's/^#+ +//' | sed 's/[*_`]//g' || true)"
  [ -z "$title" ] && title="$base"

  pandoc "$md" \
    --from=gfm \
    --to=html5 \
    --standalone \
    --template="$TEMPLATE" \
    --metadata title="$title" \
    --output="$out"

  echo "✓ $md → $out"
  count=$((count+1))
done

echo ""
echo "Fatto: $count file convertiti in $OUT_DIR/"
