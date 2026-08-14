#!/bin/bash
# veroeffentliche.sh <folge-07|dispatch-06> — Quellenverzeichnis und
# Methodenseite einer Produktion oeffentlich machen.
#
# Ersetzt den frueheren Pastebin-Schritt (abgeloest 14.8.2026). Prueft am
# Ende an der ROHDATEI gegen die lokale Groesse: der Web-Editor hatte beim
# ersten Versuch stillschweigend alle Zeilenumbrueche geschluckt, und das
# sieht man einer Erfolgsmeldung nicht an.
set -e
[ $# -eq 1 ] || { echo "Aufruf: $0 <folge-07|dispatch-06>"; exit 1; }
P="$1"
HIER="$(cd "$(dirname "$0")" && pwd)"
Q="$HIER/../$P/quellen"
[ -d "$Q" ] || { echo "Kein Quellenordner: $Q"; exit 1; }

for art in sources method; do
  src="$Q/$P-$art.txt"
  [ -f "$src" ] || { echo "FEHLT: $src"; exit 1; }
  cp "$src" "$HIER/$(echo "$P" | sed 's/^folge-/episode-/')-$art.txt"
done

cd "$HIER"
git add -A
git diff --cached --quiet && { echo "Nichts geaendert."; exit 0; }
git commit -q -m "$P: sources and method note"
git push -q
echo "Gepusht. Gegenprobe an der Rohdatei:"

fehler=0
for art in sources method; do
  f="$(echo "$P" | sed 's/^folge-/episode-/')-$art.txt"
  lokal=$(wc -c < "$f" | tr -d ' ')
  live=$(curl -s "https://raw.githubusercontent.com/clcodemail1-lab/the-buried-world-sources/main/$f" | wc -c | tr -d ' ')
  [ "$lokal" = "$live" ] && st="ok" || { st="ABWEICHUNG"; fehler=1; }
  printf "  %-28s lokal %6s  live %6s  %s\n" "$f" "$lokal" "$live" "$st"
  echo "  https://github.com/clcodemail1-lab/the-buried-world-sources/blob/main/$f"
done
[ $fehler -eq 0 ] || { echo "🚨 Groessen weichen ab -- NICHT verlinken."; exit 1; }
echo "🚨 README-Tabelle noch um die Folge ergaenzen."
