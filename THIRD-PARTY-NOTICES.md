# Mentions relatives aux composants tiers

CreateurSFX distribue les composants tiers suivants **sans modification**. Chacun reste soumis à sa propre licence et à son propre copyright. Les empreintes SHA-256 permettent de vérifier que les binaires correspondent aux versions amont officielles.

---

## 1. 7-Zip — `7za.exe`

- **Composant :** 7-Zip, version console autonome (`7za.exe`), 26.02 (x64).
- **Auteur / copyright :** Copyright © 1999–2026 Igor Pavlov.
- **Licence :** GNU LGPL (version 2.1 ou ultérieure).
- **Site officiel / sources :** https://www.7-zip.org
- **SHA-256 :** `35d4d69d7cd6cb44558f208c3b1334268013f9daf82d2dda848893a1c30c59c2`

**Note sur la restriction unRAR.** Le cœur de 7-Zip est sous GNU LGPL ; seule une partie du code de gestion des archives RAR (dans `7z.dll`) est soumise à la « GNU LGPL + restriction unRAR ». La version console autonome `7za.exe` embarquée ici est distribuée sous GNU LGPL. La restriction unRAR interdit d'utiliser le code unRAR pour recréer l'algorithme de compression RAR, propriétaire.

---

## 2. 7-Zip SFX Modified — `7zsd_LZMA2_x64.sfx`

- **Composant :** module auto-extractible « 7-Zip SFX Modified » (7zSD), variante LZMA2 x64, version 1.7.0.3900.
- **Auteurs / copyright :** module SFX © 2005–2016 Oleg N. Scherbakov ; bâti sur 7-Zip © 1999–2015 Igor Pavlov.
- **Licence :** GNU LGPL (version 2.1 ou ultérieure).
- **Sources amont :** l'URL exacte de téléchargement de ce binaire n'a pas été
  conservée dans l'historique du projet. Ne redistribue pas ce module dans une
  release publique tant que sa provenance, sa licence et son code source
  correspondant n'ont pas été documentés.
- **SHA-256 :** `93f8885f762ba1babe37376d0c0d6d7ee6670162c524a8e5cb1ca2f3f144fbd4`

---

## Information GNU LGPL (7-Zip et 7-Zip SFX Modified)

Les composants 7-Zip et 7-Zip SFX Modified sont des logiciels libres ; tu peux les redistribuer et/ou les modifier selon les termes de la GNU Lesser General Public License telle que publiée par la Free Software Foundation, en version 2.1 ou (à ton choix) toute version ultérieure.

Ces logiciels sont distribués dans l'espoir qu'ils seront utiles, mais **SANS AUCUNE GARANTIE**, sans même la garantie implicite de VALEUR MARCHANDE ou d'ADÉQUATION À UN USAGE PARTICULIER. Voir la GNU Lesser General Public License pour plus de détails.

Une copie de la GNU LGPL 2.1 est disponible à l'adresse
https://www.gnu.org/licenses/old-licenses/lgpl-2.1.html. Le texte intégral
doit être inclus dans toute archive de distribution qui redistribue ces
composants.

Le code source correspondant doit être fourni ou rendu accessible selon les
obligations de la LGPL. Pour le module SFX Modified, cette obligation ne peut
pas être vérifiée tant que sa provenance n'est pas identifiée.

---

## Ressources graphiques non couvertes

Les fichiers `14773.ico` et `fond.jpg` utilisés par l'interface **ne sont couverts ni par ce document ni par la licence du projet**. Leur licence d'origine doit être vérifiée avant toute redistribution, ou ces fichiers doivent être remplacés par des ressources sous licence libre explicite.
