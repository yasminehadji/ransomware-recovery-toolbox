#!/bin/bash
wd="$(pwd)/.sh-toolbox"

#verifier que le dossier .sh-toolbox existe 

if [ ! -e "$wd" ]; then
    echo "le dossier .sh-toolbox semble ne plus exister dans le répertoire courant, voulez-vous le recréer ? (0 = oui / 1 = non)"
    read rep_user

    #creation du dossier si il existe plus  apres laccord de lutilisateur 
    if [ "$rep_user" -eq 0 ]; then
        mkdir "$wd"
    fi
fi


#verifier si le fichier archives existe

if [ ! -f "$wd/archives" ]; then
    echo "le fichier archives semble ne plus exister, voulez-vous le recréer ? (0 = oui / 1 = non)"
    read rep_user

    # le cree apres avoir laccord je lutilisateur qi il nexiste plus
    if [ "$rep_user" -eq 0 ]; then
        echo "0" > "$wd/archives"
    fi
fi


# VERIFIER QUE CHAQUE ENTREE DU FICHIER EXISTE #


#on commence la lecture du fichier archives a partir de la 2 eme ligne 
tail -n +2 "$wd/archives" | while IFS= read -r ligne; do
    trouver=0
    l=$(echo "$ligne" | awk -F ':' '{print $1}')
    for i in "$wd"/*; do

	#on parcour tout les fichier sans .sh-toolbox en ignorant le fichier archives lui meme 
        if [ "$i" = "$wd/archives" ]; then
            continue
        fi
        filename=$(basename "$i")
        if [ "$l" = "$filename" ]; then
            trouver=1
            break
        fi
    done
    
    #si ya un fichier dans archive qu_i nexiste pas vraiment
    if [ "$trouver" -eq 0 ]; then
        echo "$l n'existe pas dans .sh-toolbox, voulez-vous le supprimer ? (0 = oui / 1 = non)"
        read rep_user </dev/tty
	
	#</dev/tty cest pour forcer read a prendre la reponse du terminal par lenter standard 
	
	#on le suprime apres avoir eu laccored de lutilisateur 
        if [ "$rep_user" -eq 0 ]; then
            sed -i "\|^$l:|d" "$wd/archives"  #on suprime...
            cmp_archive=$(head -n 1 "$wd/archives") 
            cmp_archive=$((cmp_archive - 1)) 
            sed -i "1s/.*/$cmp_archive/" "$wd/archives" #on met a jour le nombre darchive dans archives 
        fi
    fi
done

# VERIFIER QUE CHAQUE FICHIER REEL EST MENTIONNE

for i in "$wd"/*; do
	#ingnore archives 
    if [ "$i" = "$wd/archives" ]; then
        continue
    fi
    
    trouver=0
    filename=$(basename "$i")
    
    # lit tout les ligne de archives sauf la premiere (grace au tail apres done)
    while IFS= read -r ligne; do
        l=$(echo "$ligne" | awk -F ':' '{print $1}')
        if [ "$l" = "$filename" ]; then
            trouver=1
            break
        fi
    done < <(tail -n +2 "$wd/archives")
    
    # Si le fichier existe réellement mais n’est pas dans archives
    if [ "$trouver" -eq 0 ]; then
        echo "$filename n'est pas dans le fichier archives, voulez-vous le rajouter ? (0 = oui / 1 = non)"
        read rep_user </dev/tty


	#on lajoute apres avoir eu laccord de lutilisateur 
	    if [ "$rep_user" -eq 0 ]; then
            CLE_DECHIFFREMENT=" "
            cmp_archive=$(head -n 1 "$wd/archives")
            cmp_archive=$((cmp_archive + 1)) # on met a jout le nombre darchiveq
            sed -i "1s/.*/$cmp_archive/" "$wd/archives" #on rajoute le fichier dans archives
            echo "$filename:$(date +%Y%m%d-%H%M%S):$CLE_DECHIFFREMENT" >> "$wd/archives"
        fi
    fi
done