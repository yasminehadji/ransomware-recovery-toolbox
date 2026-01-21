#!/bin/bash

wd="$(pwd)/.sh-toolbox"
wf="$wd/archives"

if [ ! -d "$wd" ];then
	echo "dossier inexistant"
	exit 1
fi

if [ ! -e "$wf" ];then
	echo "fichier inexistant"
	exit 2
fi

tail -n +2 "$wf" | awk -F ':' '{ nom=$1;
date=$2; key=$3; if (key=="") key="inconnue"; else key="connue"; print " Nom : " nom " date : " date " clé : "key }'



#bonus 4 si une archive mentionnée dans le fichier archives n’existe pas / on parcourt les noms d archives se trouvant dans  le fichier archives 
  
for i in $(tail -n +2 "$wf" | awk -F ':' '{print $1}'); do
    if [ ! -f "$wd/$i" ]; then
        echo "Erreur : $i mentionnée dans .archives mais absente dans le dossier"
        exit 3
    fi
done




#bonus 5  si une archive existe sans être mentionnée dans le fichier archives
# Création d'une liste des archives mentionnées dans le fichier archives

archives_list=$(tail -n +2 "$wf" | awk -F ':' '{print $1}')

# Parcours de toutes les archives réelles dans le dossier
for file in "$wd"/*; do
    # Vérifier si le fichier est mentionné dans archives_list

    filename=$(basename "$file")
    found=0

    # Ignorer le fichier archives lui-même

    [ "$filename" = "archives" ] && continue
    for a in $archives_list; do
        if [ "$filename" = "$a" ]; then
            found=1
            break
        fi
    done
    if [ $found -eq 0 ]; then
        echo "Avertissement : $filename existe dans le dossier mais n'est pas mentionné dans $wf"
         exit 3 
    fi
done
exit 0

		


