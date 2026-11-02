#!/usr/bin/env bash
# Usage :
#   setup.sh check                                  vérifie les dépendances, installe ce qui peut l'être
#   setup.sh config <dossier_cv> [portfolio] [github]   écrit ~/.config/cv-adapte/config.json
#   setup.sh set <clé> <valeur>                     modifie une clé (ex. style moderne, photo non)
#   setup.sh show                                   affiche la config (code de sortie 1 si absente)
set -u
here="$(cd "$(dirname "$0")" && pwd)"
cfg_dir="${XDG_CONFIG_HOME:-$HOME/.config}/cv-adapte"; cfg="$cfg_dir/config.json"

case "${1:-}" in
check)
  ok=1
  command -v node >/dev/null && echo "ok  node $(node -v)" || { echo "MANQUE  node (>= 18)"; ok=0; }
  command -v pdftotext >/dev/null && echo "ok  poppler (pdftotext, pdfinfo, pdftoppm)" || { echo "MANQUE  poppler-utils (sudo apt install poppler-utils)"; ok=0; }
  if [ ! -d "$here/node_modules/playwright-core" ]; then
    echo "..  installation de playwright-core"; (cd "$here" && npm install --silent) || ok=0
  else echo "ok  playwright-core"; fi
  if ls "$HOME/.cache/ms-playwright"/chromium-*/chrome-linux*/chrome >/dev/null 2>&1 || [ -n "${CHROMIUM_PATH:-}" ]; then
    echo "ok  chromium"
  else
    echo "..  installation de chromium (une fois, ~150 Mo)"
    (cd "$here" && npx --no-install playwright-core install chromium) || { echo "MANQUE  chromium"; ok=0; }
  fi
  [ "$ok" = 1 ] && echo "PRET" || echo "INCOMPLET"
  [ "$ok" = 1 ]
  ;;
config)
  dir="${2:?dossier_cv manquant}"; mkdir -p "$cfg_dir" "$dir"
  python3 - "$cfg" "$dir" "${3:-}" "${4:-}" <<'PY'
import json,sys,os
cfg,d,p,g=sys.argv[1:5]
json.dump({"cv_dir":os.path.expanduser(d),"portfolio_url":p,"github_url":g},open(cfg,"w"),ensure_ascii=False,indent=2)
print("config écrite :",cfg)
PY
  ;;
set)
  key="${2:?clé manquante}"; val="${3-}"
  python3 - "$cfg" "$key" "$val" <<'PY'
import json,sys
cfg,k,v=sys.argv[1:4]
d=json.load(open(cfg)); d[k]=v; json.dump(d,open(cfg,"w"),ensure_ascii=False,indent=2); print(k,"=",v)
PY
  ;;
show)
  [ -f "$cfg" ] && cat "$cfg" || { echo "PAS DE CONFIG"; exit 1; }
  ;;
*) echo "Usage : setup.sh check | config <dossier_cv> [portfolio] [github] | set <clé> <valeur> | show"; exit 2;;
esac
