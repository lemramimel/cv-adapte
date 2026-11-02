#!/usr/bin/env bash
# Usage : ats_check.sh <cv.pdf> <mots_cles.txt>
# Simule ce que lit un ATS : extraction texte brute, nombre de pages, polices, mots-clés de l'offre trouvés / manquants.
set -u
pdf="${1:?cv.pdf manquant}"; kw="${2:?mots_cles.txt manquant}"
echo "== Pages / taille =="; pdfinfo "$pdf" | grep -E "Pages|Page size"
echo "== Polices (doivent être incorporées, pas d'image de texte) =="; pdffonts "$pdf" | head -8
txt="$(pdftotext -layout "$pdf" - 2>/dev/null)"
n=$(printf '%s' "$txt" | wc -w)
echo "== Texte extractible : $n mots =="
[ "$n" -lt 150 ] && echo "ALERTE : peu de texte extractible, le PDF est peut-être une image."
echo "== Sections standard =="
for s in "EXPÉRIENCE" "FORMATION" "COMPÉTENCES"; do
  printf '%s' "$txt" | grep -qi "$s" && echo "ok  $s" || echo "MANQUE  $s"
done
echo "== Coordonnées =="
printf '%s' "$txt" | grep -qE "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[a-z]{2,}" && echo "ok  email" || echo "MANQUE  email"
printf '%s' "$txt" | grep -qE "\+?[0-9][0-9 ]{8,}" && echo "ok  téléphone" || echo "MANQUE  téléphone"
echo "== Mots-clés de l'offre =="
ok=0; ko=0
while IFS= read -r k; do
  [ -z "$k" ] && continue
  if printf '%s' "$txt" | grep -qiF -- "$k"; then ok=$((ok+1)); else ko=$((ko+1)); echo "ABSENT  $k"; fi
done < "$kw"
echo "Trouvés : $ok / $((ok+ko))"
