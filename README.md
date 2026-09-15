# CreateurSFX

**Créateur de packages auto-extractibles (SFX) au format exécutable — sans installation, en PowerShell.**

CreateurSFX est un petit outil graphique Windows qui emballe un dossier dans un unique fichier `.exe` auto-extractible, avec icône personnalisée et exécution automatique d'une commande après décompression. Il s'appuie sur le module SFX de 7-Zip et n'exige **aucune installation** : un script, une fenêtre, un glisser-déposer.

Dépôt : [https://github.com/CharlesAntoineBuguet/SFXCreator](https://github.com/CharlesAntoineBuguet/SFXCreator)

---

## Pourquoi cet outil

La plupart des générateurs SFX existants sont soit des binaires compilés opaques, soit des outils en ligne de commande, soit des projets abandonnés. CreateurSFX vise trois choses que les alternatives couvrent rarement :

- **Zéro installation** — un simple script PowerShell + `7za.exe`. Rien à installer, rien à enregistrer.
- **Interface glisser-déposer** — dépose le dossier source, l'icône et la destination directement dans la fenêtre.
- **Icône injectée nativement** — le stub SFX reçoit l'icône `.ico` via l'API Windows `UpdateResource` (aucun outil externe type `rcedit`).

Le script est lisible et non compilé : tu peux vérifier exactement ce qu'il fait avant de l'exécuter.

---

## Fonctionnalités

- Compression **7z** au niveau maximal (`-mx=9`).
- Icône `.ico` personnalisée injectée dans l'exécutable final (groupe d'icônes PE).
- Choix du mode de lancement : **fenêtre visible** ou **console cachée** (`hidcon:`).
- Exécution automatique d'une commande après extraction (dossier temporaire géré par le stub SFX).
- Configuration SFX écrite en **UTF-8 sans BOM** (requis par le stub 7-Zip).
- Module SFX **embarqué dans le script** (stub décodé à la volée, pas de fichier `.sfx` séparé à fournir).

---

## Prérequis

- Windows 64 bits.
- PowerShell 5.1 ou ultérieur (inclus dans Windows).
- Les fichiers suivants, placés **dans le même dossier que le script** :
- `setup.ps1`
- `7za.exe` (7-Zip console)
- `rcedit.exe`
- le module SFX LZMA2 x64 intégré au script
- `fond.jpg` (fond de la fenêtre)
- les ressources d'interface (`sphere4.ico` / `14773.ico`) (icônes de la fenêtre de l'outil)


> ℹ️ **Architecture :** `7za.exe` et le stub SFX embarqué sont en **64 bits**. Ils ne s'exécuteront pas sur un Windows 32 bits.

---

## Utilisation

Deux façons de lancer l'outil :

- **`SFXCreator.exe`** — lanceur prêt à l'emploi (double-clic). Pratique pour une utilisation quotidienne. Ce n'est pas le code source : c'est un exécutable de commodité qui démarre l'interface. Après toute modification de `setup.ps1`, de `7za.exe`, de `rcedit.exe` ou des ressources, il faut **reconstruire** cet exe, sinon le dépôt et le lanceur divergent.
- **`setup.ps1`** — source officielle, à relire et à auditer. C'est ce fichier qui définit réellement le comportement.

```powershell
powershell -ExecutionPolicy Bypass -File .\setup.ps1
```

Ensuite :

1. Lance le script.
2. Renseigne dans la fenêtre :
   - **Répertoire source** : le dossier à empaqueter (glisser-déposer accepté).
   - **Icône** : un fichier `.ico` pour l'exécutable généré.
   - **Commande** : le programme à lancer après décompression (chemin relatif au contenu extrait, par ex. `setup.exe` ou `monapp.bat`).
   - **Lancement** : *Visible* ou *Caché*.
   - **Destination** : chemin de l'`.exe` de sortie.

   - **Lancement** : *Visible* ou *Caché*.
   - **Destination** : chemin de l'`.exe` de sortie.

3. Clique sur **OK**. L'exécutable auto-extractible est créé à l'emplacement indiqué.

Le fichier généré, lorsqu'il est lancé, décompresse son contenu dans un dossier temporaire, exécute la commande spécifiée, puis laisse le stub SFX gérer le cycle de vie des fichiers temporaires.

### Construction (schéma)

```
[stub SFX + icône PE]  +  [config UTF-8 sans BOM]  +  [archive 7z]
                    =  package.exe
```

---

## Fichiers du dépôt

| Fichier | Rôle |
|---|---|
| `SFXCreator.exe` | Lanceur optionnel (double-clic). À régénérer si le script ou les ressources changent. |
| `setup.ps1` | Interface graphique et génération du SFX — source de vérité |
| `7za.exe` | Compresseur 7-Zip en ligne de commande |
| `fond.jpg` | Image de fond de la fenêtre |
| `sphere4.ico` | Icône de la fenêtre de l'outil (à fournir à côté du script) |
| `LICENSE` | Licence MIT du code CreateurSFX |
| `THIRD-PARTY-NOTICES.md` | Licences des composants tiers |

Le stub SFX (module 7-Zip SFX Modified, LZMA2 x64) est stocké en Base64 dans `setup.ps1` et écrit temporairement au moment de la génération.

---

## Sécurité et confiance

Ce projet **ne patch pas** `7za.exe` : c'est la version officielle amont, telle quelle. Tu peux le vérifier avec l'empreinte SHA-256 ci-dessous.

| Fichier | Provenance | SHA-256 |
|---|---|---|
| `7za.exe` | 7-Zip 26.02 (x64), Igor Pavlov | `35d4d69d7cd6cb44558f208c3b1334268013f9daf82d2dda848893a1c30c59c2` |

Vérification sous PowerShell :

```powershell
Get-FileHash .\7za.exe, .\rcedit.exe -Algorithm SHA256
```

> ⚠️ **Faux positifs antivirus.** Les stubs SFX 7-Zip combinés à une exécution automatique après extraction sont un schéma parfois signalé par certains moteurs antivirus, y compris pour des usages parfaitement légitimes. Les packages produits par l'outil, et éventuellement `SFXCreator.exe` lui-même s'il est aussi un SFX, peuvent donc déclencher des alertes. Pour une distribution large, une **signature de code (Authenticode)** des `.exe` réduit nettement ces alertes.

---

## Composants tiers et licences

CreateurSFX embarque des logiciels tiers, chacun sous sa propre licence. Voir **[THIRD-PARTY-NOTICES.md](./THIRD-PARTY-NOTICES.md)** (7-Zip et le module SFX sous GNU LGPL).

---

## Licence

Le code original de CreateurSFX est distribué sous licence **MIT** (voir `LICENSE`).

---

## Avertissement sur les ressources graphiques

Les fichiers d'interface `sphere4.ico` et `fond.jpg` **ne sont pas couverts** par la licence de ce projet. Avant toute redistribution publique, vérifie que leur licence d'origine autorise la redistribution, ou remplace-les par des ressources clairement libres (les tiennes, du CC0, ou un jeu d'icônes sous licence redistribuable explicite).

---

## Crédits

- **CreateurSFX** — © Charles-Antoine Buguet.
- Module SFX : *7-Zip / 7z SFX Modified* — Igor Pavlov & Oleg N. Scherbakov (GNU LGPL).
- Compresseur : *7-Zip* — Igor Pavlov (GNU LGPL).
