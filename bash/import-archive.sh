#!/bin/bash

# verifier si ya pas d'argument ( on vois si on le laisse ou pas car cest pas demander 
if [ -z "$1" ]; then 
	echo "ERREUR, vous n'avez rien passer en paramettre"
	exit 1
fi

working_directory="$(pwd)/.sh-toolbox"
fichier="$1"
CLE_DECHIFFREMENT=""
#verifier que .sh-toolbox existe
if [ ! -d "$working_directory" ]; then 
	echo "ERREUR: .sh-toolbox existe pas "
	exit 1 
fi
#force=0 comportement normal
#force=1 on ecrase sans demander
force=0

#on parcour tout les parametre pour pouvoir copier plusieur archive a la fois

for fichier in "$@"; do

	#si le premier arg est -f on active le mode force 
	if [ "$fichier" = "-f" ];then 
		force=1
		continue
	fi	
	# Vérifie que le fichier est bien une archive .tar.gz
	if [[ ! "$fichier" =~ \.tar\.gz$ ]]; then
		echo "ERREUR: $fichier n'est pas au format .tar.gz"
		continue
	fi
	#verifier l'existance de l'archive 
	if [ ! -f "$fichier" ]; then 
		echo " erreur , l'archive $fichier  n'existe pas "
		continue
	fi

	nomfichier=$(basename "$fichier")
	cmp_archive=$(head -n 1 "$working_directory/archives")

	
	#si larchive nest pas dans .sh-toolbox on le copie et on l'ajoute dans le fichier archives
	
	if [ ! -e "$working_directory/$nomfichier" ]; then
       		cp -f "$fichier" "$working_directory/"
       		if [ "$?" -ne 0 ]; then 
	       		echo "une erreur est survenu lors de copier"
	       		exit 3
       		fi

			# Mise à jour du compteur dans le fichier archives
       		cmp_archive=$((cmp_archive+1))
       		sed -i "1s/.*/$cmp_archive/" "$working_directory/archives"
		 if [ "$?" -ne 0 ]; then
                        echo "une erreur est survenu lors de la mis a jour du fichier archives"
                        exit 4
        fi

		# Ajout de la nouvelle entrée

       		echo "$nomfichier":$(date +%Y%m%d-%H%M%S):"$CLE_DECHIFFREMENT" >> "$working_directory/archives"
		if [ "$?" -ne 0 ]; then
                        echo "une erreur est survenu lors de la mis a jour du fichier archives"
                        exit 4
                fi

# Sinon → l’archive existe déjà dans .sh-toolbox
else
	# si il a mis -f on force directement sans demander l'avis 
	if [ "$force" -eq 1 ];then
		reponse=0
	else
	# sinon on demande la confirmation

 		echo "le fichier $nomfichier  existe deja voulez vous vraiment l'ecraser ( <0> pour valider et <1> pour ne pas valider"
		read reponse
	fi	

	# Si refus on passe au paramètre suivant
	if [ "$reponse" -eq 1 ]; then
	       echo "copie annullé"	
	       continue
	else
		# Remplacement de l'archive
		cp -f "$fichier" "$working_directory/"
		if [ "$?" -ne 0 ]; then 
			echo "erreur lors du remplacement"
			exit 3
		fi
		# Mise à jour du compteur
		cmp_archive=$((cmp_archive+1))
		sed -i "1s/.*/$cmp_archive/" "$working_directory/archives"
		if [ "$?" -ne 0 ]; then
                        echo "une erreur est survenu lors de la mis a jour du fichier archives"
                        exit 4
        fi
		# Ajout de la nouvelle entrée
       	echo "$nomfichier":$(date +%Y%m%d-%H%M%S):"$CLE_DECHIFFREMENT" >> "$working_directory/archives"
		if [ "$?" -ne 0 ]; then
                        echo "une erreur est survenu lors de la mis a jour du fichier archives"
                        exit 4
                fi
	fi
fi
done
exit 0
# Tout s'est déroulé avec succès
