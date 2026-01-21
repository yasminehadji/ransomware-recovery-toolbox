# Documentation de la partie intégration (bonus)

## Compilation des binaires

Avant d'utiliser les scripts de restauration, il est nécessaire de compiler les programmes C :
```bash
make -C src
mv src/decipher src/findkey .
```

---

## Script restore-archive.sh

### Fonctionnement général
Ce script utilise les variables exportées par `check-archive.sh` pour restaurer les fichiers chiffrés d'une archive.

### Intégration avec check-archive.sh
Le script source `check-archive.sh` pour récupérer automatiquement :
- `$ARCHIVE_SELECTED` : nom de l'archive sélectionnée
- `$ATTACK_TS` : timestamp de l'attaque (en secondes)
- `$DATA_DIR` : chemin vers le dossier data décompressé
- `$MODIFIED_FILES` : fichier temporaire listant les fichiers modifiés
- `$TMP_DIR` : dossier temporaire d'extraction

### Appels aux scripts existants
```bash
./init-toolbox.sh      # Vérifie/compile les binaires
./restore-toolbox.sh   # Vérifie la cohérence des archives
```

### Processus de restauration

#### 1. Détection et recherche de clé
Pour chaque fichier chiffré (listé dans `$MODIFIED_FILES`) :
- Recherche du fichier clair correspondant (même nom, modifié avant l'attaque)
- Appel de `./findkey` avec les versions base64 des deux fichiers
- Stockage temporaire de la clé dans `/tmp/key_restore`

#### 2. Gestion du type de clé
La clé est analysée pour déterminer son type :

**Clé imprimable** (caractères affichables uniquement) :
- Test : `[[ $key =~ ^[[:print:]]+$ ]]`
- Stockage : directement dans le fichier `archives` (colonne 3)
- Format : `archive.tar.gz:date:CLE:s`

**Clé non-imprimable** (contient des caractères binaires) :
- Création d'un dossier : `.sh-toolbox/nom_archive/` (sans .tar.gz)
- Stockage : dans le fichier `KEY` de ce dossier
- Format : `archive.tar.gz:date::f`

#### 3. Mise à jour du fichier archives
Utilisation de `sed` avec des expressions régulières pour modifier la ligne correspondante :
```bash
safe_archive=$(echo "$archive_select" | sed 's/[][\.*^$/]/\\&/g')
sed -Ei "2,\$ s|^($safe_archive:[^:]*:).*|\1$key:s|" "$wd/archives"
```

#### 4. Déchiffrement des fichiers
- Récupération de la clé selon son type (s ou f)
- Pour chaque fichier dans `$MODIFIED_FILES` :
  - Calcul du chemin relatif depuis `$TMP_DIR`
  - Demande de confirmation si le fichier existe déjà
  - Appel de `./decipher CLE fichier_base64`
  - Extraction du contenu déchiffré via `awk`
  - Écriture dans le dossier de destination

### Codes de retour
- `0` : restauration réussie
- `1` : dossier .sh-toolbox inexistant
- `2` : échec création dossier destination
- `3` : échec mise à jour du fichier archives
- `4` : échec restauration d'un fichier

---

## Améliorations de init-toolbox.sh

### Compilation automatique des binaires

Ajout d'une boucle de vérification et compilation pour `decipher` et `findkey` .

### Nouveaux codes de retour
- `10` : fichier source (.c) manquant
- `11` : compilateur GCC non disponible
- `12` : échec de la compilation

### Fonctionnement
1. Vérifie si le binaire existe et est exécutable (`-x`)
2. Si absent, cherche le fichier source dans `./src/`
3. Vérifie la disponibilité de `gcc`
4. Compile automatiquement le programme
5. Affiche un message de confirmation

---

## Structure du fichier archives (format étendu)
```
nombre_archives
archive1.tar.gz:date_import:cle_ou_vide:type
archive2.tar.gz:date_import:cle_ou_vide:type
```

**Colonne 4 (type)** :
- `s` : clé stockée dans le fichier archives (string)
- `f` : clé stockée dans un fichier externe (file)

### Exemples
```
2
client1-20250411-1311.tar.gz:20251104-131504:CleSAE2025:s
client2-20250411-1341.tar.gz:20251104-134407::f
```

---

## Arborescence complète du projet
```
.
├── .sh-toolbox/
│   ├── archives                           # Fichier index
│   ├── client1-20250411-1311.tar.gz      # Archive 1
│   ├── client2-20250411-1341.tar.gz      # Archive 2
│   └── client2-20250411-1341/            # Dossier clé
│       └── KEY                            # Clé non-imprimable
├── src/
│   ├── Makefile                           # Makefile
│   ├── base64_lib.c
│   ├── base64_lib.c
│   ├── decipher.c
│   ├── findkey.c
│   ├── key_lib.c
│   ├── key_lib.h
│   ├── vignere_lib.c
│   └── vignere_lib.h
├── check-archive.sh
├── import-archive.sh
├── init-toolbox.sh
├── ls-toolbox.sh
├── restore-toolbox.sh
├── restore-archive.sh
├── decipher                               # Binaire compilé
└── findkey                                # Binaire compilé
```

---

## Flux de données entre les scripts
```
restore-archive.sh
    ↓ source
check-archive.sh
    → exporte: ARCHIVE_SELECTED, ATTACK_TS, DATA_DIR, MODIFIED_FILES, TMP_DIR
    ↓
restore-archive.sh
    ↓ appelle
init-toolbox.sh (compile decipher + findkey)
    ↓ appelle
restore-toolbox.sh (vérifie cohérence)
    ↓
Traitement des fichiers chiffrés
    → ./findkey → détection type clé → mise à jour archives
    → ./decipher → restauration fichiers
```
