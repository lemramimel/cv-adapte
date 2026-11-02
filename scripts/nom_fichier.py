#!/usr/bin/env python3
"""Usage : nom_fichier.py <prenom> <poste> [extension]
Construit le nom d'un CV : CV_<Prenom>_<Poste>.pdf
Sans accent, mots séparés par des tirets bas, chaque mot en majuscule initiale, poste limité à 5 mots."""
import re, sys, unicodedata

def propre(texte):
    sans_accent = unicodedata.normalize("NFKD", texte).encode("ascii", "ignore").decode()
    return [m for m in re.split(r"[^A-Za-z0-9]+", sans_accent) if m]

def mettre_en_forme(mot):
    return mot if mot.isupper() and len(mot) <= 4 else mot.capitalize()  # IA, UX, SQL restent en capitales

if len(sys.argv) < 3:
    sys.exit("Usage : nom_fichier.py <prenom> <poste> [extension]")
prenom = "".join(mettre_en_forme(m) for m in propre(sys.argv[1])[:1])
poste = "_".join(mettre_en_forme(m) for m in propre(sys.argv[2])[:5])
ext = sys.argv[3] if len(sys.argv) > 3 else "pdf"
if not prenom or not poste:
    sys.exit("prénom ou poste vide")
print(f"CV_{prenom}_{poste}.{ext}")
