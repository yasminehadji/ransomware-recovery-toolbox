# Documentation : Système de Chiffrement Vigenère Base64 (Compilation Séparée)

## Organisation du projet

### Structure des fichiers
```
.
├── Makefile                  # Orchestration de la compilation
├── cipher.c                  # Programme de chiffrement
├── decipher.c                # Programme de déchiffrement
├── findkey.c                 # Programme d'extraction de clé
├── base64_lib.c / .h         # Bibliothèque conversion Base64
├── vignere_lib.c / .h        # Bibliothèque chiffrement Vigenère
├── key_lib.c / .h            # Bibliothèque détection de période
└── exemple.txt               # Fichier de test
```

### Architecture 

**Bibliothèque Base64** (`base64_lib`)
- `base64_index(char)` : convertit un caractère Base64 → index (0-63)
- `base64_char(int)` : convertit un index (0-63) → caractère Base64

**Bibliothèque Vigenère** (`vignere_lib`)
- `vigenere_base64()` : chiffrement Vigenère sur Base64
- `vigenere_base64_decode()` : déchiffrement Vigenère sur Base64
- `decode_vigenere()` : extraction de clé brute par comparaison

**Bibliothèque Clé** (`key_lib`)
- `find_period()` : détecte la période minimale d'une clé répétée

---

## Compilation

### Méthode 1 : Compilation des exécutables
```bash
make all
```

**Génère :**
- `cipher` : exécutable de chiffrement
- `decipher` : exécutable de déchiffrement
- `findkey` : exécutable d'extraction de clé

### Méthode 2 : Processus complet automatisé
```bash
make process INPUT=fichier.txt KEY=MaCleBase64
```

**Actions effectuées :**
1. Compile tous les programmes
2. Encode `INPUT` en Base64 → `clair64`
3. Crée une copie → `exempleres`
4. Chiffre `exempleres` avec `KEY`
5. Sauvegarde le résultat → `chiffre64`
6. Déchiffre `exempleres`
7. Extrait la clé depuis `clair64` et `chiffre64`

**Exemple concret :**
```bash
make process INPUT=exemple.txt KEY=CleSAE2025A
```

### Nettoyage
```bash
make clean
```

Supprime tous les fichiers générés (exécutables, `.o`, fichiers temporaires).

---

## Utilisation des programmes

### 1. cipher - Chiffrement

**Syntaxe :**
```bash
./cipher <clé_base64> <fichier_base64>
```

**Comportement :**  
Applique le chiffrement Vigenère sur les caractères Base64 du fichier (en ignorant `=` et `\n`), puis écrase le fichier avec le résultat chiffré.

**Exemple :**
```bash
# Préparation : encoder un fichier texte en Base64
base64 message.txt > message_b64.txt

# Compilation
make cipher

# Chiffrement
./cipher "ABC123==" message_b64.txt
```

**Output :** le texte chiffré en Base64

---

### 2. decipher - Déchiffrement

**Syntaxe :**
```bash
./decipher <clé_base64> <fichier_chiffré>
```

**Comportement :**  
Inverse le chiffrement Vigenère pour retrouver le Base64 original, puis écrase le fichier avec le résultat.

**Exemple :**
```bash
# Compilation
make decipher

# Déchiffrement
./decipher "ABC123==" message_b64.txt
```

**Output :** le texte déchiffré en Base64

---

### 3. findkey - Extraction de clé

**Syntaxe :**
```bash
./findkey <fichier_clair_b64> <fichier_chiffré_b64>
```

**Comportement :**  
Compare les deux fichiers pour extraire la clé utilisée, détecte sa période minimale et l'affiche.

**Sorties :**
- `stdout` → clé minimale
- `stderr` → longueur de la clé

**Exemple :**
```bash
# Compilation
make findkey

# Extraction
./findkey clair64 chiffre64
```

**Output :**
```
ABC123        (sur stdout)
6             (sur stderr)
```
