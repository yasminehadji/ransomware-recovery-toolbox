# Documentation des scripts Bash – SAE Sécurité

Cette documentation explique le fonctionnement, l’utilisation et le rôle de chacun des scripts développés dans le cadre de la SAE. Elle décrit également les codes de retour, les messages affichés et les prérequis nécessaires.

## 1. init-toolbox.sh

### Objectif du script
Ce script initialise l’environnement de travail de l’outil en créant automatiquement :
- un dossier `.sh-toolbox` (s’il n’existe pas),
- un fichier `archives` contenant le nombre d’archives importées.

### Fonctionnement
1. Vérifie l’existence du dossier `.sh-toolbox`.
2. Le crée s’il est absent.
3. Vérifie l’existence du fichier `archives`.
4. Le crée s’il est absent et y inscrit 0.
5. Vérifie qu’aucun autre fichier ou dossier supplémentaire ne se trouve dans `.sh-toolbox`.

### Codes retour
- **0** : Initialisation correcte lorsque dossier + fichier existants.
- **1** : Impossible de créer le dossier ou fichier.
- **2** : Présence d’éléments non autorisés dans `.sh-toolbox`.

### Exemple d’exécution
```bash
./init-toolbox.sh
```

### Output possible :
```text
creation du dossier
le dossier a etais cree
le fichier a etais cree
le dossier et le fichier existe
ERREUR:il ya un ou  plusieur (fichier/dossier) en plus de archives dans votre
dossier
```

## 2. import-archive.sh

### Objectif
Importer une archive `.tar.gz` dans l’environnement de travail. Ce script :
- copie l’archive dans `.sh-toolbox`,
- demande confirmation si elle existe déjà (sauf mode `-f`),
- met à jour le fichier `archives`.

### Fonctionnement
1. Vérifie l'existence de `.sh-toolbox`.
2. Vérifie l'existence de l’archive passée en paramètre.
3. Copie l’archive dans `.sh-toolbox`.
4. Si elle existe déjà : demande validation utilisateur sauf si `-f`.
5. Met à jour :
    1. première ligne du fichier `archives` (nombre total),
    2. nouvelle ligne descriptive : `nom_archive:date_ajout:clé`

### Modes disponibles
- **Normal** : confirmation nécessaire pour écraser.
- **Forcé (-f)** : écrasement automatique.
- **Multi-import** : possibilité d’ajouter plusieurs archives en un appel.

### Exemple d’exécution
```bash
./import-archive.sh client1.tar.gz
./import-archive.sh -f client1.tar.gz
./import-archive.sh client1.tar.gz client2.tar.gz
```

### Codes retour
- **0** : Copie effectuée ou copie annulée.
- **1** : `.sh-toolbox` inexistant.
- **2** : Archive introuvable.

> **Note (bonus)** : Dans la version bonus, le script peut recevoir plusieurs paramètres. Si l’un des fichiers indiqués n’existe pas, le script affiche un message d’erreur, puis utilise `continue` à la place de `exit 2` afin de poursuivre la vérification des autres paramètres.

- **3** : Erreur lors de la copie.
- **4** : Erreur mise à jour du fichier `archives`.

## 3. ls-toolbox.sh

### Objectif
Afficher la liste des archives enregistrées dans le fichier “archives”.

### Fonctionnement
1. Vérifie la présence de `.sh-toolbox` et du fichier `archives`.
2. Lit toutes les lignes (sauf la première) du fichier `archives`.
3. Affiche pour chaque archive : `Nom – date d’ajout – clé connue ou inconnue`

### Exemple d’exécution
```bash
./ls-toolbox.sh
```

### Output possible :
```text
Nom : client1.tar.gz date : 20251104-131504 clé : inconnue
```

### Codes retour
- **0** : Affichage réussi.
- **1** : `.sh-toolbox` absent.
- **2** : fichier `archives` absent.
- **3 (bonus)** : incohérences trouvées.

## 4. restore-toolbox.sh (bonus)

### Objectif
Réparer automatiquement l’environnement `.sh-toolbox` en cas d’erreur ou incohérence.

### Problèmes détectés
- Dossier `.sh-toolbox` manquant.
- Fichier `archives` manquant.
- Archive mentionnée mais non présente physiquement.
- Archive présente physiquement mais non listée dans `archives`.

### Fonctionnement
Pour chaque anomalie trouvée, le script demande confirmation avant action :
- création du dossier,
- création du fichier,
- suppression d’une ligne invalide,
- ajout d’une archive manquante.

### Exemple d’exécution
```bash
./restore-toolbox.sh
```

## 5. check-archive.sh

### Objectif
Analyser une archive afin d’identifier :
- la dernière connexion SSH de l’utilisateur admin,
- la liste des fichiers modifiés après cette date,
- (bonus) les fichiers non modifiés mais identiques en nom et taille.

### Fonctionnement
1. Vérifie `.sh-toolbox` et `archives`.
2. Affiche la liste des archives et propose un choix.
3. Décompresse dans un dossier temporaire.
4. Recherche la dernière connexion admin dans : `var/log/auth.log`
5. Parcourt `data/` pour identifier :
    - fichiers modifiés après l’attaque,
    - fichiers non modifiés identiques (bonus).
    - Le fichier doit être en lecture seule et ne doit pas appartenir à l’utilisateur (bonus)

### Exemple d’utilisation
```bash
./check-archive.sh
```

### Output possible :
```text
la liste des fichier est :
arch1
arch1
client1-20250901-1503.tar.gz
quel archives voulez vous utiliser?( de 1 a n)
3
archive selectionnée : client1-20250901-1503.tar.gz
......
Dernière connexion admin : Jul 15 15:26:24
Fichiers modifiés après la dernière connexion admin :
.......
```

### Codes retour
- **0** : tout s’est bien passé.
- **1** : `.sh-toolbox` absent.
- **2** : fichier `archives` absent.
- **3** : décompression échouée.
- **4** : fichier log manquant.
- **5** : dossier `data/` vide.
