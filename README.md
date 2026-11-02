# cv-adapte

Un skill [Claude Code](https://claude.com/claude-code) qui prépare un dossier de candidature adapté à une offre d'emploi : **CV en PDF compatible ATS**, **mail d'accompagnement** et **lettre de motivation** courts, relus par un recruteur simulé.

Tu lui donnes une offre. Il lit tes CV et ton portfolio, trouve ce que l'offre demande et où tu le prouves, rédige, puis fait critiquer le résultat par un sous-agent qui n'a aucun contexte, comme un vrai recruteur qui cherche pourquoi écarter le dossier.

## Ce qu'il fait

1. **Premier lancement** : vérifie les dépendances, te demande ton CV de base, ton portfolio (facultatif), GitHub, LinkedIn, ton style de CV et tes contraintes (pays, statut, télétravail, disponibilité). Il construit une fiche de faits que tu valides.
2. **Analyse de l'offre** : exigences éliminatoires, compétences clés, mots-clés exacts, ce que le recruteur craint.
3. **Éligibilité, puis score d'adéquation** : il s'arrête si une contrainte de l'offre est incompatible avec les tiennes ou si l'écart est trop grand, et te le dit avant d'écrire quoi que ce soit.
4. **Projets à montrer** : seuls les projets publics avec lien vérifié sont mis en avant ; les projets confidentiels ne sont jamais montrés.
5. **CV** : une page, une colonne, polices système, sans image ni tableau, trois styles (`classique`, `moderne`, `compact`). Contrôle ATS du PDF (texte extractible, sections, mots-clés trouvés ou absents).
6. **Mail et lettre** : courts, passés par [`humanizer-fr`](https://github.com/jooray/humanizer) si installé, sinon par un repli intégré.
7. **Relecture à contexte neuf** par un sous-agent, puis corrections. Une relecture par défaut, deux au maximum.
8. **Suivi** des candidatures dans un fichier CSV, avec une date de relance.

## Principes

- **Ne rien inventer.** Chaque fait du CV vient de tes documents. Une exigence sans preuve est signalée comme écart, jamais comblée.
- **Questions interactives avec recommandation vérifiée.** Chaque recommandation cite sa source ; sans source, le skill écrit « non vérifié ».
- **ATS d'abord, design ensuite.** Les règles de lisibilité machine ne changent pas d'un style à l'autre.
- **Aucune donnée personnelle dans le skill.** Tout est dans `~/.config/cv-adapte/config.json` et dans ton dossier de CV.
- Il prépare, **tu envoies** : rien n'est envoyé à ta place.

## Installation

Prérequis : Claude Code, Node.js 18 ou plus, `poppler-utils` (`pdftotext`, `pdfinfo`, `pdftoppm`).

```bash
git clone https://github.com/lemramimel/cv-adapte ~/.claude/skills/cv-adapte
~/.claude/skills/cv-adapte/scripts/setup.sh check
```

`setup.sh check` installe `playwright-core` et télécharge Chromium si besoin (une fois). Puis, dans Claude Code, envoie une offre d'emploi ou tape `/cv-adapte`. Le premier lancement te guide.

Testé sous Linux. macOS devrait fonctionner si Chromium est disponible (`CHROMIUM_PATH`) ; Windows n'a pas été testé.

## Vérifier l'installation

```bash
~/.claude/skills/cv-adapte/scripts/selftest.sh
```

Le test utilise une personne et une offre fictives (`references/exemple/`) : configuration, rendu PDF des trois styles, contrôle ATS, absence de données personnelles dans le skill.

## Structure

| Chemin | Rôle |
|---|---|
| `SKILL.md` | Le skill : flux, règles, questions interactives |
| `scripts/setup.sh` | Dépendances et configuration |
| `scripts/render_pdf.mjs` | HTML vers PDF A4 avec Chromium |
| `scripts/ats_check.sh` | Contrôle ATS du PDF |
| `scripts/selftest.sh` | Test sur jeu d'essai fictif |
| `references/template-cv.html` | Gabarit de CV compatible ATS |
| `references/styles/` | Les trois styles |
| `references/reviewer-prompt.md` | Prompt du relecteur à contexte neuf |
| `references/exemple/` | Jeu d'essai fictif |

## Limites

- Les textes sont écrits en français par défaut ; la langue suit celle de l'offre.
- Le skill améliore la présentation de faits réels, il ne remplace pas ton jugement : relis tout avant d'envoyer.
- Un ATS réel reste une boîte noire ; le contrôle intégré simule l'extraction de texte, il ne garantit pas un score.

## Licence

MIT.
