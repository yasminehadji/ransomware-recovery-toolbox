#!/bin/bash



wd="$(pwd)/.sh-toolbox"
wf="$wd/archives"

#verification de l'existance du dossier
if [ ! -d "$wd" ];then
	echo "le dossier .sh-toolbox n existe pas"
	exit 1
fi

#verification de l existance du fichier
if [ ! -e "$wf" ];then
	echo "le fichier archives n existe pas"
	exit 2
fi

#afficher la liste des archives  a partir de la  2eme ligne
echo "la liste des fichier est :"
./ls-toolbox.sh 
echo""
#selection de l archive
echo "quel archives voulez vous utiliser?( de 1 a n)"
read ligne

#verification du choix // si c un nbr
if ! [[ "$ligne" =~ ^[0-9]+$ ]]; then
    echo "Erreur : veuillez entrer un nombre valide"
    exit 1
fi

#on rajoute le +1 a fin d ignorer la premiere ligne
ligne=$((ligne+1))

#on extrait le nom de l archive choisie par l utilisateur 
archive=$(sed -n "${ligne}p" "$wf"| awk -F ':' '{ print $1}') #si le choix est 4 par exemple , le sed il affiche que la 4 eme ligne 

if [ -z "$archive" ]; then
    echo "Erreur : ce numéro n'existe pas"
    exit 3
fi
echo""
echo "archive selectionnée : $archive"

#on decompresse avec tar + les opetions -x qui extrait le fichier
#-z gzip decompresse -v affiche les extraits -f  

#je crée le dossier

mkdir -p "$(pwd)/temp"
# on decompresse et on le met dans le nv doss temporaire

tar -xzvf "$wd/$archive" -C "$(pwd)/temp"
if [ "$?" -ne 0 ];then
	echo "la decompression echouée"
	exit 3
fi
echo""
echo "decompression reussie"

# on verifie si le fichier log existe

log="$(pwd)/temp/var/log/auth.log"

if [ ! -e "$log" ];then
	echo "fichier log inexistant"
	exit 4
fi

#qst4
#on affiche la date et l heure de l attaque
  
date_attaque=$(grep "admin" "$log" |grep -E "(Accepted|session opened)" |tail -n 1 | awk '{print $1, $2, $3}')

if [ -z "$date_attaque" ]; then
    echo""
    echo "Aucune connexion admin trouvée dans les logs"
else
    echo""
    echo "Dernière connexion admin : $date_attaque"
fi

#qst5
#on parcourt les fichiers situé dans temp/data

data_dir="$(pwd)/temp/data"

#on verifie si le dossier existe et qu il n est pas vide
 
if [ ! -d "$data_dir" ] || [ -z "$(ls -A "$data_dir")" ]; then
        echo "Le dossier de données est vide"
        exit 5
fi
echo""
echo "Fichiers modifiés après la dernière connexion admin :"



#Conversion de la date d'attaque en secondes

YEAR=2025
date_attaque="$date_attaque $YEAR"
attack_ts=$(date -d "$date_attaque" +%s)



#bonus6



# 1. Stocke tous les fichiers modifiés dans un fichier temporaire créer avec mktemp

modified_files="$(mktemp)"
while IFS= read -r file; do
# On parcourt tous les fichiers réguliers (-type f) du dossier data et ses sous-dossiers

    [ -f "$file" ] || continue
# On récupère le timestamp de dernière modification du fichier en secondes 
# %Y dans stat donne exactement ça et on redirige les erreurs vers /dev/null au cas où.
    file_ts=$(stat -c "%Y" "$file" 2>/dev/null) || continue

   if [ "$file_ts" -ge "$attack_ts" ]; then
   # On compare ce timestamp avec celui de la dernière connexion de l admin 
    # Si le fichier a été modifié à partir du moment de l'attaque (>=) ou après, c est qu il est touché par l attaque 
    
    echo "$(basename "$file") du dossier $(basename "$(dirname "$file")")"
    # On sauvegarde le chemin complet du fichier modifié dans le fichier temporaire
        
    printf '%s\n' "$file" >> "$modified_files"
   fi
done <  <(find "$data_dir" -type f -printf "%T@ %p\n" | sort -rn | cut -d' ' -f2-)
# find cherche tous les fichiers réguliers dans data_dir
    # %T@: timestamp de modification en secondes 
    # %p: le path complet du fichier
    # et on les trie du plus recent au premier car les premier(aka modifié au mm moment de l attaque )
    #on coupe pour ne garder que le path du fichier 

#maintenant pour chaque fichier modifié on cherche les fichiers non modifiés correspondants
echo""
echo "Fichiers non modifiés correspondant aux fichiers modifiés :"

while IFS= read -r modfile; do
    mod_name=$(basename "$modfile")
#on extrait juste le nom du fichier modifié sans le chemin complet 


# maintenant pour chaque fichier modifié on cherche dans tout le dossier data 
#tous les fichiers qui portent le mm nom 
    while IFS= read -r f; do
    #on verifie que c un fichier existant 
        [ -f "$f" ] || continue

        #on ignore le fichier lui meme dans data 
        [ "$f" = "$modfile" ] && continue
       
       # On récupère le timestamp de modification du fichier
        file_ts=$(stat -c "%Y" "$f" 2>/dev/null) || continue


        # Si ce fichier a été modifié avant ou pendant la dernière connexion admin
        # c a d  qu'il n'a pas été touché après l'attaque
        if [ "$file_ts" -le "$attack_ts" ]; then
            echo "$f correspond à "
            echo "$modfile"
            echo""
        fi
   # on cherche uniquement les fichiers ayant exactement le même nom que le modifié avec find
    done < <(find "$data_dir" -type f -name "$mod_name")

done < "$modified_files"

#on exporte certaine variables

export ARCHIVE_SELECTED="$archive"      # le nom de l'archive décompressée choisi
export ATTACK_TS="$attack_ts"           # Timestamp de la dernière connexion admin
export DATA_DIR="$data_dir"             # Chemin vers le dossier data contenant les fichiers
export MODIFIED_FILES="$modified_files" # Chemin du fichier temporaire listant les modifiés
TMP_DIR="$(pwd)/temp"                   # Dossier temporaire où tout a été décompressé
export TMP_DIR                         