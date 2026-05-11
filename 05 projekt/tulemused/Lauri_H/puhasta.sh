#!/bin/bash

set -euo pipefail

# --- Funktsioon: abi ---
show_help() {
  echo "Kasutus: $0 [--dry-run] <kaust> <päevad>"
  echo ""
  echo "  <kaust>   - sihtkaust"
  echo "  <päevad>  - mitu päeva vanad failid kustutatakse"
  echo ""
  echo "  --dry-run - näitab, mida teeks, aga ei tee midagi"
  exit 0
}

# --- Argumentide kontroll ---
DRY_RUN=false

if [[ "${1:-}" == "--help" ]]; then
  show_help
fi

if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
  shift
fi

if [[ $# -ne 2 ]]; then
  echo "Viga: vaja 2 argumenti"
  show_help
  exit 1
fi

DIR="$1"
DAYS="$2"

# --- Kontroll: kaust olemas ---
if [[ ! -d "$DIR" ]]; then
  echo "Viga: kausta ei eksisteeri"
  exit 2
fi

# --- Kontroll: päevad on number ---
if ! [[ "$DAYS" =~ ^[0-9]+$ ]]; then
  echo "Viga: päevade arv peab olema positiivne täisarv"
  exit 2
fi

# --- Ohtlike kaustade blokk ---
case "$DIR" in
  "/"|"/home"|"/usr"|"/bin"|"/etc"|"$HOME")
    echo "Viga: ohtlik kaust, katkestan!"
    exit 2
    ;;
esac

echo "Töötlen kausta: $DIR"
echo "Failid vanemad kui $DAYS päeva"
echo ""

# --- Leia failid ---
FILES=$(find "$DIR" -type f -mtime +"$DAYS")

if [[ -z "$FILES" ]]; then
  echo "Vanemaid faile ei leitud."
  exit 0
fi

echo "Leitud failid:"
echo "$FILES"
echo ""

# --- Dry run ---
if [[ "$DRY_RUN" == true ]]; then
  echo "[DRY-RUN] Midagi ei kustutata."
  exit 0
fi

# --- Arhiivi nimi ---
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
ARCHIVE="archive_$TIMESTAMP.tar.gz"

echo "Loon arhiivi: $ARCHIVE"

# --- Arhiveerimine ---
if tar -czf "$ARCHIVE" $FILES; then
  echo "Arhiveerimine õnnestus."
else
  echo "Viga: arhiveerimine ebaõnnestus. Midagi ei kustutata."
  exit 3
fi

# --- Kustutamine ---
echo "Kustutan failid..."

find "$DIR" -type f -mtime +"$DAYS" -delete

echo "Valmis!"
exit 0