#!/usr/bin/env bash
# Test du skill sans données personnelles : config, rendu PDF, contrôle ATS, absence de fuite de données.
# Usage : selftest.sh
set -u
here="$(cd "$(dirname "$0")" && pwd)"; ex="$here/../references/exemple"
fail=0; ok(){ echo "ok    $1"; }; ko(){ echo "ECHEC $1"; fail=1; }
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT

"$here/setup.sh" check >/dev/null 2>&1 && ok "dépendances" || ko "dépendances (setup.sh check)"

# config isolée
XDG_CONFIG_HOME="$tmp/cfg" "$here/setup.sh" config "$tmp/cv" https://example.com/camille https://github.com/camille-exemple >/dev/null
XDG_CONFIG_HOME="$tmp/cfg" "$here/setup.sh" show | grep -q camille-exemple && ok "config écrite et relue" || ko "config"

# rendu + ATS
node "$here/render_pdf.mjs" "$ex/cv-exemple.html" "$tmp/cv.pdf" >/dev/null 2>&1 && ok "rendu PDF" || ko "rendu PDF"
pages=$(pdfinfo "$tmp/cv.pdf" 2>/dev/null | awk '/Pages/{print $2}')
[ "${pages:-0}" = 1 ] && ok "1 page" || ko "pages = ${pages:-?}"
out="$("$here/ats_check.sh" "$tmp/cv.pdf" "$ex/mots_cles-exemple.txt" 2>&1)"
echo "$out" | grep -q "MANQUE  email" && ko "email non détecté" || ok "email et téléphone détectés"
echo "$out" | grep -qE "Trouvés : (7|8) / 8" && ok "mots-clés de l'offre fictive" || { ko "mots-clés"; echo "$out" | grep -E "ABSENT|Trouv"; }
echo "$out" | grep -q "ALERTE" && ko "peu de texte extractible" || ok "texte extractible"

# nom de fichier
[ "$(python3 "$here/nom_fichier.py" "Éloïse" "Développeur IA – alternance (12 mois)")" = "CV_Eloise_Developpeur_IA_Alternance_12_Mois.pdf" ] && ok "convention de nom de fichier" || ko "nom_fichier.py"

# styles : chacun doit rester sur 1 page et lisible par l'ATS
for st in classique moderne compact; do
  node "$here/render_pdf.mjs" "$ex/cv-exemple.html" "$tmp/$st.pdf" "$here/../references/styles/$st.css" >/dev/null 2>&1 || { ko "rendu style $st"; continue; }
  n=$(pdfinfo "$tmp/$st.pdf" | awk '/Pages/{print $2}'); w=$(pdftotext -layout "$tmp/$st.pdf" - | wc -w)
  [ "$n" = 1 ] && [ "$w" -gt 150 ] && ok "style $st (1 page, $w mots)" || ko "style $st (pages=$n, mots=$w)"
done

# fuite de données : aucune valeur de la config réelle ne doit figurer dans le skill
real="${XDG_CONFIG_HOME:-$HOME/.config}/cv-adapte/config.json"
if [ -f "$real" ]; then
  for v in $(python3 -c "import json,sys;d=json.load(open('$real'));print(*[str(x) for x in d.values() if x and str(x).startswith(('http','/'))])" 2>/dev/null); do
    short="${v#https://}"; short="${short#http://}"
    if grep -rIl --exclude-dir=node_modules --exclude-dir=.git --exclude=package-lock.json --exclude=README.md --exclude=LICENSE -F "$short" "$here/.." 2>/dev/null | grep -q .; then ko "donnée personnelle trouvée dans le skill : $short"; else ok "pas de fuite : $short"; fi
  done
fi
[ "$fail" = 0 ] && echo "TOUT EST OK" || echo "ECHECS"
exit "$fail"
