// Usage : node render_pdf.mjs <entree.html> <sortie.pdf> [style.css]
// style.css (optionnel) : feuille de style injectée après le CSS du gabarit (voir references/styles/).
// Rend le HTML en PDF A4 avec le Chromium déjà installé par Playwright.
import { chromium } from "playwright-core";
import { readdirSync, existsSync, readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join, resolve } from "node:path";

const [, , entree, sortie, styleCss] = process.argv;
if (!entree || !sortie) {
  console.error("Usage : node render_pdf.mjs <entree.html> <sortie.pdf>");
  process.exit(2);
}

function trouverChromium() {
  if (process.env.CHROMIUM_PATH) return process.env.CHROMIUM_PATH;
  const racine = join(homedir(), ".cache", "ms-playwright");
  if (!existsSync(racine)) return undefined;
  const dossier = readdirSync(racine)
    .filter((d) => d.startsWith("chromium-"))
    .sort()
    .pop();
  return dossier ? join(racine, dossier, "chrome-linux64", "chrome") : undefined;
}

const browser = await chromium.launch({ executablePath: trouverChromium() });
const page = await browser.newPage();
await page.goto("file://" + resolve(entree), { waitUntil: "networkidle" });
if (styleCss) await page.addStyleTag({ content: readFileSync(resolve(styleCss), "utf8") });
await page.pdf({ path: resolve(sortie), format: "A4", printBackground: true, preferCSSPageSize: true });
await browser.close();
console.log("PDF écrit :", resolve(sortie));
