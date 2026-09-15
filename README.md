# CreateurSFX

**Créateur de packages auto-extractibles (SFX) au format exécutable — sans installation, en PowerShell.**

CreateurSFX est un petit outil graphique Windows qui emballe un dossier dans un unique fichier `.exe` auto-extractible, avec icône personnalisée, métadonnées de version, et exécution automatique d'une commande après décompression. Il s'appuie sur le module SFX de 7-Zip et n'exige **aucune installation** : un script, une fenêtre, un glisser-déposer.

---

## Pourquoi cet outil

La plupart des générateurs SFX existants sont soit des binaires compilés opaques, soit des outils en ligne de commande, soit des projets abandonnés. CreateurSFX vise trois choses que les alternatives couvrent rarement :

- **Zéro installation** — un simple script PowerShell + les binaires fournis. Rien à installer, rien à enregistrer.
- **Interface glisser-déposer** — dépose ton dossier source, ton icône et ta destination directement dans la fenêtre.
- **Métadonnées de version personnalisables** — `CompanyName`, `ProductName`, `FileDescription`, `FileVersion`, `ProductVersion` sont injectées dans l'exécutable généré. La majorité des outils grand public se contentent de coller une icône.

Le script est lisible et non compilé : tu peux vérifier exactement ce qu'il fait avant de l'exécuter.

---

## Fonctionnalités

- Compression **7z / LZMA2** au niveau maximal (`-mx=9`).
- Icône `.ico` personnalisée injectée dans l'exécutable final.
- Choix du mode de lancement : **fenêtre visible** ou **console cachée** (`hidcon:`).
- Exécution automatique d'une commande après extraction dans un dossier temporaire.
- Métadonnées de version (companyname, product, description, versions fichier/produit).
- Configuration SFX écrite en **UTF-8 sans BOM** (requis par le stub 7-Zip).

---

## Prérequis

- Windows 64 bits.
- PowerShell 5.1 ou ultérieur (inclus dans Windows).
- Les fichiers suivants, placés **dans le même dossier que le script** :
  - `7za.exe` (7-Zip console)
  - le module SFX LZMA2 x64 intégré au script
- Les ressources d'interface : `14773.ico` et `fond.jpg` (voir l'avertissement plus bas au sujet de leur licence).

> ℹ️ **Architecture :** les binaires fournis et les exécutables générés sont en **64 bits**. Ils ne s'exécuteront pas sur un Windows 32 bits. Pour une cible héritée x86, il faudrait le module `7zsd_LZMA2_x86.sfx` correspondant.

---

## Utilisation

1. Lance le script :
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\setup.ps1
   ```
2. Renseigne dans la fenêtre :
   - **Répertoire source** : le dossier à empaqueter.
   - **Icône** : un fichier `.ico`.
   - **Commande** : le programme à lancer après décompression (chemin relatif au contenu extrait).
   - **Lancement** : *Visible* ou *Caché*.
   - **Destination** : chemin de l'`.exe` de sortie.
3. Clique sur **OK**. L'exécutable auto-extractible est créé à l'emplacement indiqué.

Le fichier généré, lorsqu'il est lancé, décompresse son contenu dans un dossier temporaire, exécute la commande spécifiée, puis nettoie les fichiers temporaires.

---

## Sécurité et confiance

Ce projet **ne modifie pas** les binaires tiers qu'il embarque : ce sont les versions officielles amont, telles quelles. Tu peux le vérifier avec les empreintes SHA-256 ci-dessous.

| Fichier | Provenance | SHA-256 |
|---|---|---|
| `7za.exe` | 7-Zip 26.02 (x64), Igor Pavlov | `35d4d69d7cd6cb44558f208c3b1334268013f9daf82d2dda848893a1c30c59c2` |
| `7zsd_LZMA2_x64.sfx` | 7-Zip SFX Modified 1.7.0.3900, Oleg Scherbakov | `93f8885f762ba1babe37376d0c0d6d7ee6670162c524a8e5cb1ca2f3f144fbd4` |

Vérification sous PowerShell :
```powershell
Get-FileHash .\7za.exe -Algorithm SHA256
```

> ⚠️ **Faux positifs antivirus.** Les stubs SFX 7-Zip combinés à une exécution automatique après extraction sont un schéma parfois signalé par certains moteurs antivirus, y compris pour des usages parfaitement légitimes. Les exécutables produits par cet outil peuvent donc déclencher des alertes. Pour une distribution large, une **signature de code (Authenticode)** de tes `.exe` réduit nettement ces alertes.

---

## Composants tiers et licences

CreateurSFX embarque des logiciels tiers, chacun sous sa propre licence. Voir **[THIRD-PARTY-NOTICES.md](./THIRD-PARTY-NOTICES.md)** pour le détail complet (7-Zip et le module SFX sous GNU LGPL).

---

## Licence

Le code original de CreateurSFX est distribué sous licence **MIT** (voir `LICENSE`).

---

## Avertissement sur les ressources graphiques

Les fichiers d'interface `14773.ico` et `fond.jpg` **ne sont pas couverts** par la licence de ce projet. Avant toute redistribution publique, vérifie que leur licence d'origine autorise la redistribution (beaucoup d'icônes « gratuites » sont réservées à un usage personnel), ou remplace-les par des ressources clairement libres (les tiennes, du CC0, ou un jeu d'icônes sous licence redistribuable explicite).

---

## Crédits

- **CreateurSFX** — © Charles-Antoine Buguet.
- Module SFX : *7-Zip / 7z SFX Modified* — Igor Pavlov & Oleg N. Scherbakov (GNU LGPL).
